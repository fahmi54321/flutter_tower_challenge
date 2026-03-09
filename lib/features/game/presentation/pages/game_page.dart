// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tower/features/game/domain/repositories/team_repository.dart';
import 'package:tower/features/game/data/entities/team.dart';

import '../widgets/tower_widget.dart';
import '../widgets/press_button.dart';

class GamePage extends StatefulWidget {
  final String? teamId;
  final String teamName;
  final int playerIndex;

  final TeamRepository teamRepository;

  const GamePage({
    Key? key,
    this.teamId,
    required this.teamName,
    this.playerIndex = 0,
    required this.teamRepository,
  }) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Team? _team;
  int target = 1000;
  int value = 0;
  int moves = 0;
  int restarts = 0;
  bool _loading = true;
  Duration _towerAnimDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    setState(() {
      _loading = true;
    });

    if (widget.teamId != null) {
      final t = await widget.teamRepository.fetchTeamById(widget.teamId!);
      if (t == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final stats = await widget.teamRepository.fetchPlayerStats(
        widget.teamId!,
        widget.playerIndex,
      );

      if (!mounted) return;

      setState(() {
        _team = t;
        target = t.target;
        final playerVal = (t.players.length > widget.playerIndex)
            ? t.players[widget.playerIndex]
            : null;
        value = playerVal ?? startingValue;
        moves = stats['moves'] ?? 0;
        restarts = stats['restarts'] ?? 0;
        _loading = false;
      });
    } else {
      // No teamId provided, just use provided name and defaults
      if (!mounted) return;
      setState(() {
        target = 1000;
        value = startingValue;
        _loading = false;
      });
    }
  }

  Future<void> _persistStats() async {
    if (_team == null || widget.teamId == null) return;
    await widget.teamRepository.updatePlayerStats(
      widget.teamId!,
      widget.playerIndex,
      moves,
      restarts,
    );
  }

  Future<void> _persistValue(int newValue) async {
    if (_team == null || !mounted) return;
    final players = List<int?>.from(_team!.players);
    if (widget.playerIndex < players.length) {
      players[widget.playerIndex] = newValue;
    }
    final updated = _team!.copyWith(players: players);
    await widget.teamRepository.updateTeam(updated);
    if (!mounted) return;
    setState(() {
      _team = updated;
    });
  }

  void _showCannotExceed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operation would exceed target.')),
    );
  }

  Future<void> add10() async {
    _towerAnimDuration = const Duration(milliseconds: 300);
    final newValue = value + 10;
    if (newValue > target) {
      _showCannotExceed();
      return;
    }
    setState(() {
      value = newValue;
      moves++;
    });
    await _persistValue(value);
    await _persistStats();

    if (value == target) _onWin();
  }

  Future<void> multiply2() async {
    _towerAnimDuration = const Duration(milliseconds: 150);
    final newValue = value * 2;
    if (newValue > target) {
      _showCannotExceed();
      return;
    }
    setState(() {
      value = newValue;
      moves++;
    });
    await _persistValue(value);
    await _persistStats();

    if (value == target) _onWin();
  }

  Future<void> restart() async {
    setState(() {
      value = startingValue;
      moves = 0;
      restarts++;
    });
    await _persistValue(value);
    await _persistStats();
  }

  void _onWin() {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('You reached the target!')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Game - ${widget.teamName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: restart),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Text('7 Min')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Text('Restarts: $restarts')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Text('$moves Moves')),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),

            const Spacer(),

            /// Towers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TowerWidget(
                  value: target,
                  target: target,
                  showCar: true,
                  width: 70,
                  animationDuration: _towerAnimDuration,
                ),

                TowerWidget(
                  value: value,
                  target: target,
                  width: 120,
                  animationDuration: _towerAnimDuration,
                ),
              ],
            ),

            const SizedBox(height: 60),

            /// Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PressButton(
                  onPressed: add10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      '+10',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                PressButton(
                  onPressed: multiply2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      '×2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
