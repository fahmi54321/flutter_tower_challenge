class MatchPlayer {
  final String id;
  final String name;
  final String team; // 'A' or 'B'
  final int? lastSeenAt; // epoch millis
  final int completedTowers;
  final int totalMoves;
  final int totalTimeMillis;
  final int afkMillis;

  const MatchPlayer({
    required this.id,
    required this.name,
    required this.team,
    this.lastSeenAt,
    this.completedTowers = 0,
    this.totalMoves = 0,
    this.totalTimeMillis = 0,
    this.afkMillis = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'team': team,
      'lastSeenAt': lastSeenAt,
      'completedTowers': completedTowers,
      'totalMoves': totalMoves,
      'totalTimeMillis': totalTimeMillis,
      'afkMillis': afkMillis,
    };
  }

  factory MatchPlayer.fromMap(String id, Map<String, dynamic> map) {
    return MatchPlayer(
      id: id,
      name: map['name'] as String? ?? 'Unknown',
      team: map['team'] as String? ?? 'A',
      lastSeenAt: (map['lastSeenAt'] as num?)?.toInt(),
      completedTowers: (map['completedTowers'] as num?)?.toInt() ?? 0,
      totalMoves: (map['totalMoves'] as num?)?.toInt() ?? 0,
      totalTimeMillis: (map['totalTimeMillis'] as num?)?.toInt() ?? 0,
      afkMillis: (map['afkMillis'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Single tower definition that is shared identik
/// oleh kedua tim di satu pertandingan.
class MatchTower {
  final String id;
  final int initialValue;
  final int currentValue;
  final String status; // 'available', 'claimed', 'completed'
  final String? claimedByPlayerId;
  final String? completedByPlayerId;
  final int moves;

  const MatchTower({
    required this.id,
    required this.initialValue,
    required this.currentValue,
    required this.status,
    this.claimedByPlayerId,
    this.completedByPlayerId,
    this.moves = 0,
  });

  MatchTower copyWith({
    String? id,
    int? initialValue,
    int? currentValue,
    String? status,
    String? claimedByPlayerId,
    String? completedByPlayerId,
    int? moves,
  }) {
    return MatchTower(
      id: id ?? this.id,
      initialValue: initialValue ?? this.initialValue,
      currentValue: currentValue ?? this.currentValue,
      status: status ?? this.status,
      claimedByPlayerId: claimedByPlayerId ?? this.claimedByPlayerId,
      completedByPlayerId: completedByPlayerId ?? this.completedByPlayerId,
      moves: moves ?? this.moves,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'initialValue': initialValue,
      'currentValue': currentValue,
      'status': status,
      'claimedByPlayerId': claimedByPlayerId,
      'completedByPlayerId': completedByPlayerId,
      'moves': moves,
    };
  }

  factory MatchTower.fromMap(String id, Map<String, dynamic> map) {
    return MatchTower(
      id: id,
      initialValue: (map['initialValue'] as num?)?.toInt() ?? 0,
      currentValue: (map['currentValue'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'available',
      claimedByPlayerId: map['claimedByPlayerId'] as String?,
      completedByPlayerId: map['completedByPlayerId'] as String?,
      moves: (map['moves'] as num?)?.toInt() ?? 0,
    );
  }
}

class MatchState {
  final String id;
  final int target;
  final int durationSeconds; // e.g. 5 * 60
  final DateTime? startedAt;
  final List<MatchPlayer> players;
  final List<MatchTower> towers; // 20 active towers (shared)
  final int scoreTeamA;
  final int scoreTeamB;

  const MatchState({
    required this.id,
    required this.target,
    required this.durationSeconds,
    this.startedAt,
    required this.players,
    required this.towers,
    this.scoreTeamA = 0,
    this.scoreTeamB = 0,
  });

  MatchState copyWith({
    int? target,
    int? durationSeconds,
    DateTime? startedAt,
    List<MatchPlayer>? players,
    List<MatchTower>? towers,
    int? scoreTeamA,
    int? scoreTeamB,
  }) {
    return MatchState(
      id: id,
      target: target ?? this.target,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      startedAt: startedAt ?? this.startedAt,
      players: players ?? this.players,
      towers: towers ?? this.towers,
      scoreTeamA: scoreTeamA ?? this.scoreTeamA,
      scoreTeamB: scoreTeamB ?? this.scoreTeamB,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'target': target,
      'durationSeconds': durationSeconds,
      'startedAt': startedAt?.toIso8601String(),
      'players': {
        for (final p in players) p.id: p.toMap(),
      },
      'towers': {
        for (final t in towers) t.id: t.toMap(),
      },
      'scoreTeamA': scoreTeamA,
      'scoreTeamB': scoreTeamB,
    };
  }

  factory MatchState.fromMap(String id, Map<String, dynamic> map) {
    // players bisa tersimpan sebagai Map (id -> data) atau List.
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

    // towers juga bisa Map atau List.
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

    final players = rawPlayersMap.entries
        .map<MatchPlayer>((e) => MatchPlayer.fromMap(
              e.key.toString(),
              Map<String, dynamic>.from(e.value as Map),
            ))
        .toList();

    final towers = rawTowersMap.entries
        .map<MatchTower>((e) => MatchTower.fromMap(
              e.key.toString(),
              Map<String, dynamic>.from(e.value as Map),
            ))
        .toList();

    return MatchState(
      id: id,
      target: (map['target'] as num?)?.toInt() ?? 1000,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 300,
      startedAt: map['startedAt'] != null
          ? DateTime.tryParse(map['startedAt'] as String)
          : null,
      players: players,
      towers: towers,
      scoreTeamA: (map['scoreTeamA'] as num?)?.toInt() ?? 0,
      scoreTeamB: (map['scoreTeamB'] as num?)?.toInt() ?? 0,
    );
  }
}

