import 'package:firebase_database/firebase_database.dart';
import 'package:tower/features/game/data/entities/team.dart';
import 'package:tower/features/game/domain/repositories/team_repository.dart';

class FirebaseTeamRepository implements TeamRepository {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('teams');

  @override
  Stream<List<Team>> teamsStream() {
    return _ref.onValue.map((event) {
      if (!event.snapshot.exists) return <Team>[];

      final value = event.snapshot.value;
      if (value is! Map) return <Team>[];

      final Map<dynamic, dynamic> data = value;
      final List<Team> teams = [];

      data.forEach((key, value) {
        if (value is Map) {
          final map = Map<String, dynamic>.from(value);
          teams.add(Team.fromMap(map, id: key.toString()));
        }
      });

      return teams;
    });
  }

  @override
  Future<List<Team>> fetchTeams() async {
    final snapshot = await _ref.get();
    if (!snapshot.exists) return [];

    final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    final List<Team> teams = [];

    data.forEach((key, value) {
      final map = Map<String, dynamic>.from(value as Map);
      teams.add(Team.fromMap(map, id: key.toString()));
    });

    return teams;
  }

  @override
  Future<Team?> fetchTeamById(String id) async {
    final snapshot = await _ref.child(id).get();
    if (!snapshot.exists) return null;
    final map = Map<String, dynamic>.from(snapshot.value as Map);
    return Team.fromMap(map, id: id);
  }

  @override
  Future<void> createSampleIfEmpty() async {
    final snapshot = await _ref.get();
    if (snapshot.exists) return;

    final samples = sampleTeams;
    for (final team in samples) {
      final ref = _ref.push();
      await ref.set(team.toMap());

      // initialize per-player stats
      for (var i = 0; i < team.players.length; i++) {
        await ref.child('stats').child(i.toString()).set({
          'moves': 0,
          'restarts': 0,
        });
      }
    }
  }

  @override
  Future<void> updateTeam(Team team) async {
    if (team.id == null) throw Exception('Team id required to update');
    await _ref.child(team.id!).set(team.toMap());
  }

  @override
  Future<void> setTeams(List<Team> teams) async {
    final batch = FirebaseDatabase.instance.ref();
    for (final team in teams) {
      if (team.id != null) {
        await _ref.child(team.id!).set(team.toMap());
      } else {
        await _ref.push().set(team.toMap());
      }
    }
  }

  @override
  Future<Map<String, int>> fetchPlayerStats(
    String teamId,
    int playerIndex,
  ) async {
    final snapshot = await _ref
        .child(teamId)
        .child('stats')
        .child(playerIndex.toString())
        .get();
    if (!snapshot.exists) return {'moves': 0, 'restarts': 0};
    final map = Map<String, dynamic>.from(snapshot.value as Map);
    return {
      'moves': (map['moves'] as num?)?.toInt() ?? 0,
      'restarts': (map['restarts'] as num?)?.toInt() ?? 0,
    };
  }

  @override
  Future<void> updatePlayerStats(
    String teamId,
    int playerIndex,
    int moves,
    int restarts,
  ) async {
    await _ref.child(teamId).child('stats').child(playerIndex.toString()).set({
      'moves': moves,
      'restarts': restarts,
    });
  }
}
