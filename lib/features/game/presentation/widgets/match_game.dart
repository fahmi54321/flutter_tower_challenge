import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tower/features/game/domain/repositories/match_repository.dart';
import 'package:tower/features/game/data/entities/match.dart';

/// Flame game board untuk mode pertandingan 2 tim (Phase 17).
///
/// Saat ini fokus pada:
/// - Render arena Tim A (atas) dan Tim B (bawah).
/// - Menampilkan 20 menara aktif sebagai grid per tim.
/// - Visual status menara: available / claimed / completed.
/// - Tampilan target dan skor tim.
class MatchGame extends FlameGame {
  final String matchId;
  final MatchRepository matchRepository;
  final void Function(MatchTower tower)? onTowerTap;

  MatchState? _state;
  late final TextComponent _targetTextTop;
  late final TextComponent _targetTextBottom;
  late final TextComponent _scoreTextTop;
  late final TextComponent _scoreTextBottom;

  MatchGame({
    required this.matchId,
    required this.matchRepository,
    this.onTowerTap,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _targetTextTop = TextComponent(
      text: 'Target: -',
      position: Vector2(8, 8),
      anchor: Anchor.topLeft,
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    _scoreTextTop = TextComponent(
      text: 'Score A: 0',
      position: Vector2(size.x - 8, 8),
      anchor: Anchor.topRight,
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    _targetTextBottom = TextComponent(
      text: 'Target: -',
      position: Vector2(8, size.y / 2 + 8),
      anchor: Anchor.topLeft,
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    _scoreTextBottom = TextComponent(
      text: 'Score B: 0',
      position: Vector2(size.x - 8, size.y / 2 + 8),
      anchor: Anchor.topRight,
      priority: 10,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    addAll([
      _targetTextTop,
      _scoreTextTop,
      _targetTextBottom,
      _scoreTextBottom,
    ]);

    // Background tint for both halves.
    add(
      RectangleComponent(
        size: Vector2(size.x, size.y / 2),
        position: Vector2.zero(),
        paint: Paint()..color = Colors.blueGrey.shade900,
      ),
    );
    add(
      RectangleComponent(
        size: Vector2(size.x, size.y / 2),
        position: Vector2(0, size.y / 2),
        paint: Paint()..color = Colors.deepPurple.shade900,
      ),
    );

    // Subscribe to match stream dan render saat data datang.
    matchRepository.watchMatch(matchId).listen((state) {
      if (state == null) return;
      _state = state;
      _rebuildBoard();
    });
  }

  void _rebuildBoard() {
    final s = _state;
    if (s == null) return;

    _targetTextTop.text = 'Target: ${s.target}';
    _targetTextBottom.text = 'Target: ${s.target}';
    _scoreTextTop.text = 'Score A: ${s.scoreTeamA}';
    _scoreTextBottom.text = 'Score B: ${s.scoreTeamB}';

    // Hapus semua komponen tower lama.
    children.whereType<_MatchTowerComponent>().forEach(remove);

    if (s.towers.isEmpty) return;

    // Layout: 4 kolom x 5 baris (20 tower) untuk tiap tim.
    const int columns = 4;
    const int rows = 5;

    final double arenaWidth = size.x;
    final double arenaHeight = size.y / 2;

    final double padding = 8;
    final double cellWidth =
        (arenaWidth - padding * 2) / columns - padding * 0.5;
    final double cellHeight =
        (arenaHeight - padding * 3) / rows - padding * 0.5;

    for (var i = 0; i < s.towers.length; i++) {
      final tower = s.towers[i];
      final col = i % columns;
      final row = i ~/ columns;

      // Top arena (Team A)
      final topX = padding + col * (cellWidth + padding * 0.5);
      final topY = 28 + padding + row * (cellHeight + padding * 0.5);

      add(
        _MatchTowerComponent(
          tower: tower,
          position: Vector2(topX, topY),
          size: Vector2(cellWidth, cellHeight),
          teamLabel: 'A',
          onTap: onTowerTap,
        ),
      );

      // Bottom arena (Team B)
      final bottomX = padding + col * (cellWidth + padding * 0.5);
      final bottomY =
          size.y / 2 + 28 + padding + row * (cellHeight + padding * 0.5);

      add(
        _MatchTowerComponent(
          tower: tower,
          position: Vector2(bottomX, bottomY),
          size: Vector2(cellWidth, cellHeight),
          teamLabel: 'B',
          onTap: onTowerTap,
        ),
      );
    }
  }
}

class _MatchTowerComponent extends PositionComponent with TapCallbacks {
  final MatchTower tower;
  final String teamLabel;
  final void Function(MatchTower tower)? onTap;

  _MatchTowerComponent({
    required this.tower,
    required Vector2 position,
    required Vector2 size,
    required this.teamLabel,
    this.onTap,
  }) : super(position: position, size: size);

  late final RectangleComponent _rect;
  late final TextComponent _text;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _rect = RectangleComponent(
      size: size,
      paint: Paint()..color = _statusColor(),
      priority: 1,
    );

    final label = _buildLabel();

    _text = TextComponent(
      text: label,
      anchor: Anchor.center,
      position: size / 2,
      priority: 2,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(_rect);
    add(_text);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onTap?.call(tower);
  }

  Color _statusColor() {
    switch (tower.status) {
      case 'completed':
        return Colors.grey;
      case 'claimed':
        return Colors.amber;
      case 'available':
      default:
        return Colors.green;
    }
  }

  String _statusIcon() {
    switch (tower.status) {
      case 'completed':
        return '✅';
      case 'claimed':
        return '🟡';
      case 'available':
      default:
        return '🟢';
    }
  }

  String _buildLabel() {
    final status = _statusIcon();
    return '$status ${tower.initialValue}';
  }
}
