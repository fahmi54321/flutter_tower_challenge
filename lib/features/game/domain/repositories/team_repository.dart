import 'package:tower/features/game/data/entities/team.dart';

abstract class TeamRepository {
  Stream<List<Team>> teamsStream();
  Future<List<Team>> fetchTeams();
  Future<Team?> fetchTeamById(String id);
  Future<void> createSampleIfEmpty();
  Future<void> updateTeam(Team team);
  Future<void> setTeams(List<Team> teams);
  Future<Map<String, int>> fetchPlayerStats(String teamId, int playerIndex);
  Future<void> updatePlayerStats(
    String teamId,
    int playerIndex,
    int moves,
    int restarts,
  );
}
