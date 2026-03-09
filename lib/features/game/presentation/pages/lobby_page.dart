import 'package:flutter/material.dart';
import 'package:tower/features/game/domain/repositories/team_repository.dart';
import 'package:tower/features/game/domain/repositories/match_repository.dart';
import 'package:tower/features/game/data/entities/team.dart';
import '../widgets/tower_widget.dart';
import '../widgets/car_widget.dart';
import 'match_page.dart';

class LobbyPage extends StatefulWidget {
  final TeamRepository teamRepository;
  final MatchRepository matchRepository;

  const LobbyPage({
    super.key,
    required this.teamRepository,
    required this.matchRepository,
  });

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  List<Team> _teams = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
    _listenRealtime();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _loading = true;
    });

    await widget.teamRepository.createSampleIfEmpty();
    final teams = await widget.teamRepository.fetchTeams();

    setState(() {
      _teams = teams;
      _loading = false;
    });
  }

  void _listenRealtime() {
    widget.teamRepository.teamsStream().listen((teams) {
      if (!mounted) return;
      setState(() {
        _teams = teams;
        _loading = false;
      });
    });
  }

  Future<void> _joinSlot(Team team, int slotIndex) async {
    final idx = _teams.indexWhere((t) => t.id == team.id);
    if (idx == -1) return;

    final updatedPlayers = List<int?>.from(team.players);
    updatedPlayers[slotIndex] = startingValue;

    final updated = team.copyWith(players: updatedPlayers);

    // Persist to Firebase
    await widget.teamRepository.updateTeam(updated);

    // Refresh local list
    await _loadTeams();

    // Navigate to game page and reload teams when returning
    if (!mounted) return;
    await Navigator.pushNamed(
      context,
      '/game',
      arguments: {
        'teamId': updated.id,
        'teamName': updated.name,
        'playerIndex': slotIndex,
        'target': updated.target,
        'playerValue': updated.players[slotIndex],
        'players': updated.players,
      },
    );

    // If the game indicated changes (or always), reload teams to show latest state
    await _loadTeams();
  }

  Future<void> _startMatchDebug() async {
    // Contoh sederhana: buat match baru dengan target 1000
    final match = await widget.matchRepository.createMatch(target: 1000);
    if (!mounted) return;

    // Untuk sekarang, gunakan player dummy + tim A
    const playerId = 'debug-player-1';
    const playerName = 'Debug Player';
    const team = 'A';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchPage(
          matchId: match.id,
          playerId: playerId,
          playerName: playerName,
          team: team,
          matchRepository: widget.matchRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Lobby')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
          ),
          IconButton(
            icon: const Icon(Icons.sports_esports),
            onPressed: _startMatchDebug,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_teams.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team Race',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._teams.map((team) {
                      // Team race progress follows the first player
                      // that is not yet finished. If all finished,
                      // progress is full (1.0).
                      double progress = 0.0;
                      if (team.target > 0 && team.players.isNotEmpty) {
                        int? currentValue;

                        for (final p in team.players) {
                          if (p == null || p != team.target) {
                            currentValue = p ?? 0;
                            break;
                          }
                        }

                        if (currentValue == null) {
                          // All players finished
                          progress = 1.0;
                        } else {
                          progress = (currentValue / team.target).clamp(
                            0.0,
                            1.0,
                          );
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox(
                          height: 32,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final laneWidth = constraints.maxWidth;
                              final carX = laneWidth * progress;
                              return Stack(
                                children: [
                                  // Track
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      height: 4,
                                      width: laneWidth,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  // Team name at start
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Text(
                                        team.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Car
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                    left: carX.clamp(
                                      0.0,
                                      laneWidth - 28,
                                    ), // car width approx
                                    top: 0,
                                    child: const CarWidget(),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _teams.length,
              itemBuilder: (context, index) {
                final team = _teams[index];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Target tower
                            TowerWidget(
                              value: team.target,
                              target: team.target,
                              showCar: true,
                            ),

                            // Player towers
                            ...List.generate(team.players.length, (i) {
                              final player = team.players[i];

                              if (player == null) {
                                return TowerWidget(
                                  value: 0,
                                  target: team.target,
                                  showAdd: true,
                                  onTap: () => _joinSlot(team, i),
                                );
                              }

                              return TowerWidget(
                                value: player,
                                target: team.target,
                                filledPlayer: true,
                              );
                            }),
                          ],
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
