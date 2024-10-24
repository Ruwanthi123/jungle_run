import 'dart:math';
import 'package:flame/components.dart';
import '/game/enemy.dart';
import '/models/enemy_data.dart';
import '/game/dino_run.dart';

class EnemyFactory {
  // Method to create a new enemy based on the provided EnemyData.
  Enemy createEnemy(EnemyData enemyData, JungleRun game) {
    final enemy = Enemy(enemyData);
    enemy.anchor = Anchor.bottomLeft;
    enemy.size = enemyData.textureSize;
    enemy.position = Vector2(
      game.virtualSize.x + 32,
      game.virtualSize.y - 24,
    );

    if (enemyData.canFly) {
      final random = Random();
      final newHeight = random.nextDouble() * 2 * enemyData.textureSize.y;
      enemy.position.y -= newHeight;
    }

    return enemy;
  }
}
