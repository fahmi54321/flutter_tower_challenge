import 'package:tower/features/game/data/entities/match.dart';

abstract class MatchRepository {
  Future<MatchState> createMatch({required int target, int durationSeconds});

  Future<MatchState?> fetchMatch(String id);

  Stream<MatchState?> watchMatch(String id);

  Future<bool> tryClaimTower(String matchId, String towerId, String playerId);

  Future<void> releaseTower(String matchId, String towerId, String playerId);

  Future<void> updateTowerProgress(
    String matchId,
    String towerId, {
    required int currentValue,
    required int moves,
  });

  Future<void> completeTower(
    String matchId,
    String towerId, {
    required String playerId,
    required String team,
    required int currentValue,
    required int moves,
  });

  Future<void> updateLastSeen(String matchId, String playerId);

  Future<void> checkAfkAndReleaseClaims(String matchId);
}
