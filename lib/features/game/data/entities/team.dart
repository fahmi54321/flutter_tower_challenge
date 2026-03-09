class Team {
  final String? id;
  final String name;
  final int target;
  final List<int?> players;

  const Team({
    this.id,
    required this.name,
    required this.target,
    required this.players,
  });

  Team copyWith({String? id, String? name, int? target, List<int?>? players}) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      target: target ?? this.target,
      players: players ?? this.players,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'target': target,
      // store players as list of nullable ints (null remains null)
      'players': players.map((e) => e).toList(),
    };
  }

  factory Team.fromMap(Map<String, dynamic> map, {String? id}) {
    final rawPlayers = map['players'] as List<dynamic>? ?? [];
    final players = rawPlayers.map<int?>((e) {
      if (e == null) return null;
      if (e is int) return e;
      if (e is String) return int.tryParse(e);
      return null;
    }).toList();

    return Team(
      id: id,
      name: map['name'] as String? ?? 'Unknown',
      target: (map['target'] as num?)?.toInt() ?? 1000,
      players: players,
    );
  }

  String toJson() => toMap().toString();
}

// Helpful default teams used for initial seeding/local fallback
const List<Team> sampleTeams = [
  Team(name: "Team A", target: 1000, players: [200, 450, 700, null, null]),
  Team(name: "Team B", target: 1000, players: [300, 500, null, null, null]),
];

// Starting value for newly joined player towers
const int startingValue = 0;

