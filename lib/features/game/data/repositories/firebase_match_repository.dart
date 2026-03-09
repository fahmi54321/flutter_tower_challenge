import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:tower/features/game/data/entities/match.dart';
import 'package:tower/features/game/domain/repositories/match_repository.dart';

class FirebaseMatchRepository implements MatchRepository {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('matches');
  final Random _rand = Random();

  @override
  Future<MatchState> createMatch({
    required int target,
    int durationSeconds = 300,
  }) async {
    final matchRef = _ref.push();

    final towers = List.generate(20, (index) {
      final initial = _randomInitialValue();
      final towerId = index.toString();
      return MatchTower(
        id: towerId,
        initialValue: initial,
        currentValue: initial,
        status: 'available',
        claimedByPlayerId: null,
        completedByPlayerId: null,
        moves: 0,
      );
    });

    final match = MatchState(
      id: matchRef.key!,
      target: target,
      durationSeconds: durationSeconds,
      startedAt: null,
      players: const [],
      towers: towers,
      scoreTeamA: 0,
      scoreTeamB: 0,
    );

    await matchRef.set(match.toMap());
    return match;
  }

  @override
  Future<MatchState?> fetchMatch(String id) async {
    final snapshot = await _ref.child(id).get();
    if (!snapshot.exists) return null;
    final map = Map<String, dynamic>.from(snapshot.value as Map);
    return MatchState.fromMap(id, map);
  }

  @override
  Stream<MatchState?> watchMatch(String id) {
    return _ref.child(id).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      return MatchState.fromMap(id, map);
    });
  }

  @override
  Future<bool> tryClaimTower(
    String matchId,
    String towerId,
    String playerId,
  ) async {
    final towerRef = _ref.child(matchId).child('towers').child(towerId);

    final result = await towerRef.runTransaction((current) {
      if (current == null) {
        return Transaction.abort();
      }
      final data = Map<String, dynamic>.from(current as Map);
      final status = data['status'] as String? ?? 'available';
      final claimedBy = data['claimedByPlayerId'] as String?;

      if (status != 'available' && claimedBy != playerId) {
        return Transaction.abort();
      }

      data['status'] = 'claimed';
      data['claimedByPlayerId'] = playerId;
      return Transaction.success(data);
    });

    return result.committed;
  }

  @override
  Future<void> releaseTower(
    String matchId,
    String towerId,
    String playerId,
  ) async {
    final towerRef = _ref.child(matchId).child('towers').child(towerId);
    await towerRef.runTransaction((current) {
      if (current == null) {
        return Transaction.abort();
      }
      final data = Map<String, dynamic>.from(current as Map);
      final claimedBy = data['claimedByPlayerId'] as String?;
      if (claimedBy != playerId) {
        return Transaction.abort();
      }
      data['status'] = 'available';
      data['claimedByPlayerId'] = null;
      data['currentValue'] = data['initialValue'];
      data['moves'] = 0;
      data['completedByPlayerId'] = null;
      return Transaction.success(data);
    });
  }

  @override
  Future<void> updateTowerProgress(
    String matchId,
    String towerId, {
    required int currentValue,
    required int moves,
  }) async {
    final towerRef = _ref.child(matchId).child('towers').child(towerId);
    await towerRef.update({'currentValue': currentValue, 'moves': moves});
  }

  @override
  Future<void> completeTower(
    String matchId,
    String towerId, {
    required String playerId,
    required String team,
    required int currentValue,
    required int moves,
  }) async {
    final matchRef = _ref.child(matchId);

    await matchRef.runTransaction((current) {
      if (current == null) return Transaction.abort();
      final data = Map<String, dynamic>.from(current as Map);

      final towersMap = Map<String, dynamic>.from(data['towers'] as Map? ?? {});
      final towerData = Map<String, dynamic>.from(
        towersMap[towerId] as Map? ?? {},
      );

      towerData['status'] = 'completed';
      towerData['currentValue'] = currentValue;
      towerData['moves'] = moves;
      towerData['completedByPlayerId'] = playerId;
      towersMap[towerId] = towerData;

      int scoreA = (data['scoreTeamA'] as num?)?.toInt() ?? 0;
      int scoreB = (data['scoreTeamB'] as num?)?.toInt() ?? 0;
      if (team == 'A') {
        scoreA++;
      } else {
        scoreB++;
      }

      data['towers'] = towersMap;
      data['scoreTeamA'] = scoreA;
      data['scoreTeamB'] = scoreB;

      return Transaction.success(data);
    });
  }

  @override
  Future<void> updateLastSeen(String matchId, String playerId) async {
    await _ref.child(matchId).child('players').child(playerId).update({
      'lastSeenAt': ServerValue.timestamp,
    });
  }

  @override
  Future<void> checkAfkAndReleaseClaims(String matchId) async {
    final snapshot = await _ref.child(matchId).get();
    if (!snapshot.exists) return;

    final map = Map<String, dynamic>.from(snapshot.value as Map);
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final dynamic playersRaw = map['players'];
    Map<dynamic, dynamic> rawPlayersMap = {};
    if (playersRaw is Map) {
      rawPlayersMap = playersRaw;
    } else if (playersRaw is List) {
      for (var i = 0; i < playersRaw.length; i++) {
        final v = playersRaw[i];
        if (v == null) continue;
        rawPlayersMap[i.toString()] = v;
      }
    }

    final dynamic towersRaw = map['towers'];
    Map<dynamic, dynamic> rawTowersMap = {};
    if (towersRaw is Map) {
      rawTowersMap = towersRaw;
    } else if (towersRaw is List) {
      for (var i = 0; i < towersRaw.length; i++) {
        final v = towersRaw[i];
        if (v == null) continue;
        rawTowersMap[i.toString()] = v;
      }
    }

    for (final entry in rawTowersMap.entries) {
      final towerId = entry.key.toString();
      final towerData = Map<String, dynamic>.from(entry.value as Map);
      final status = towerData['status'] as String? ?? 'available';
      final claimedBy = towerData['claimedByPlayerId'] as String?;

      if (status != 'claimed' || claimedBy == null) continue;

      final playerRaw = rawPlayersMap[claimedBy];
      if (playerRaw == null) continue;
      final playerMap = Map<String, dynamic>.from(playerRaw as Map);
      final lastSeenAt = (playerMap['lastSeenAt'] as num?)?.toInt();
      if (lastSeenAt == null) continue;

      final sinceLast = nowMs - lastSeenAt;
      // Jika pemain AFK > 45 detik, lepaskan klaim tower.
      if (sinceLast > 45000) {
        await releaseTower(matchId, towerId, claimedBy);
      }
    }
  }

  int _randomInitialValue() {
    // Nilai awal acak 5..100
    return 5 + _rand.nextInt(96);
  }
}
