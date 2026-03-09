import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tower/features/game/domain/repositories/match_repository.dart';
import 'package:tower/features/game/data/entities/match.dart';
import 'package:tower/features/game/presentation/widgets/match_game.dart';

/// Halaman wrapper Flutter untuk menampilkan MatchGame (Flame).
///
/// Belum dihubungkan ke routing utama, sehingga tidak
/// mengubah flow game yang sudah ada.
class MatchPage extends StatefulWidget {
  final String matchId;
  final String playerId;
  final String playerName;
  final String team; // 'A' or 'B'
  final MatchRepository matchRepository;

  const MatchPage({
    super.key,
    required this.matchId,
    required this.playerId,
    required this.playerName,
    required this.team,
    required this.matchRepository,
  });

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  late final MatchGame _game;

  MatchTower? _selectedTower;
  int _currentValue = 0;
  int _moves = 0;
  bool _busy = false;
  static const int _minValue = 0;
  static const int _maxValue = 200000;
  Timer? _heartbeat;

  @override
  void initState() {
    super.initState();
    _game = MatchGame(
      matchId: widget.matchId,
      matchRepository: widget.matchRepository,
      onTowerTap: _onTowerTap,
    );
    _heartbeat = Timer.periodic(const Duration(seconds: 5), (_) async {
      await widget.matchRepository.updateLastSeen(
        widget.matchId,
        widget.playerId,
      );
      await widget.matchRepository.checkAfkAndReleaseClaims(widget.matchId);
    });
  }

  Future<void> _onTowerTap(MatchTower tower) async {
    if (_busy) return;
    // Hanya menara available yang bisa dicoba klaim.
    if (tower.status != 'available') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menara sudah diklaim atau selesai.')),
      );
      return;
    }

    setState(() => _busy = true);
    final ok = await widget.matchRepository.tryClaimTower(
      widget.matchId,
      tower.id,
      widget.playerId,
    );
    setState(() => _busy = false);

    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menara sudah diklaim pemain lain.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _selectedTower = tower;
      _currentValue = tower.currentValue;
      _moves = tower.moves;
    });
  }

  void _closeOverlay() {
    setState(() {
      _selectedTower = null;
    });
  }

  Future<void> _restartTower() async {
    final tower = _selectedTower;
    if (tower == null) return;

    setState(() {
      _currentValue = tower.initialValue;
      _moves = 0;
    });
    await widget.matchRepository.updateTowerProgress(
      widget.matchId,
      tower.id,
      currentValue: _currentValue,
      moves: _moves,
    );
  }

  Future<void> _applyOperation(int Function(int) op) async {
    final tower = _selectedTower;
    if (tower == null) return;

    final newValue = op(_currentValue);
    // Numeric constraints: 0 <= value <= 200000
    if (newValue < _minValue || newValue > _maxValue) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Operasi tidak valid (di luar batas nilai).'),
        ),
      );
      return;
    }
    setState(() {
      _currentValue = newValue;
      _moves++;
    });

    await widget.matchRepository.updateTowerProgress(
      widget.matchId,
      tower.id,
      currentValue: _currentValue,
      moves: _moves,
    );

    // Kondisi menang: currentValue == target match
    // Target diambil lewat watchMatch di bawah (snapshot).
  }

  Future<void> _completeTower(int target) async {
    final tower = _selectedTower;
    if (tower == null) return;
    if (_currentValue != target) return;

    await widget.matchRepository.completeTower(
      widget.matchId,
      tower.id,
      playerId: widget.playerId,
      team: widget.team,
      currentValue: _currentValue,
      moves: _moves,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Menara selesai!')));
    _closeOverlay();
  }

  @override
  void dispose() {
    _heartbeat?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<MatchState?>(
          stream: widget.matchRepository.watchMatch(widget.matchId),
          builder: (context, snapshot) {
            final match = snapshot.data;
            final target = match?.target ?? 0;
            final canPlus10 =
                _currentValue + 10 >= _minValue &&
                _currentValue + 10 <= _maxValue;
            final canTimes2 =
                _currentValue * 2 >= _minValue &&
                _currentValue * 2 <= _maxValue;

            return Stack(
              children: [
                GameWidget(game: _game),
                if (_selectedTower != null)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Menara ${_selectedTower!.id}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Target: $target'),
                              Text(
                                'Nilai awal: ${_selectedTower!.initialValue}',
                              ),
                              const SizedBox(height: 8),
                              Text('Nilai saat ini: $_currentValue'),
                              Text('Langkah: $_moves'),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: canPlus10
                                        ? () => _applyOperation((v) => v + 10)
                                        : null,
                                    child: const Text('+10'),
                                  ),
                                  ElevatedButton(
                                    onPressed: canTimes2
                                        ? () => _applyOperation((v) => v * 2)
                                        : null,
                                    child: const Text('×2'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: _restartTower,
                                    child: const Text('Restart'),
                                  ),
                                  ElevatedButton(
                                    onPressed: _currentValue == target
                                        ? () => _completeTower(target)
                                        : null,
                                    child: const Text('Selesai'),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _closeOverlay,
                                  child: const Text('Tutup'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
