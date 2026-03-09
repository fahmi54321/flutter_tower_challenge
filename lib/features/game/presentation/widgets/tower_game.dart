import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class TowerGame extends FlameGame {
  static late TowerGame instance;

  int value = 160;
  int target = 1000;

  late TextComponent towerText;

  TowerGame() {
    instance = this;
  }

  @override
  Future<void> onLoad() async {
    camera.viewport.debugColor = Colors.green.shade300;

    towerText = TextComponent(
      text: "$value",
      position: Vector2(size.x / 2 - 20, size.y / 2),
      scale: Vector2.all(3),
    );

    add(towerText);
  }

  void addTen() {
    value += 10;
    updateUI();
  }

  void multiplyTwo() {
    value *= 2;
    updateUI();
  }

  void updateUI() {
    if (value >= target) {
      // Cap value at target instead of resetting — reaching the target should be a win.
      value = target;
      // TODO: trigger win animation or callback here
    }

    towerText.text = "\$value";
  }
}
