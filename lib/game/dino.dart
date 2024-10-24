import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '/game/enemy.dart';
import '/game/dino_run.dart';
import '/game/audio_manager.dart';
import '/models/player_data.dart';

/// This enum represents the animation states of [Player].
enum PlayerAnimationStates {
  idle,
  run,
  kick,
  hit,
  sprint,
}

// This represents the player character of this game.
class Player extends SpriteAnimationGroupComponent<PlayerAnimationStates>
    with CollisionCallbacks, HasGameReference<JungleRun> {
  // A map of all the animation states and their corresponding animations.
  static final _animationMap = {
    PlayerAnimationStates.idle: SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
    ),
    PlayerAnimationStates.run: SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4) * 24, 0),
    ),
    PlayerAnimationStates.kick: SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6) * 24, 0),
    ),
    PlayerAnimationStates.hit: SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6 + 4) * 24, 0),
    ),
    PlayerAnimationStates.sprint: SpriteAnimationData.sequenced(
      amount: 7,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6 + 4 + 3) * 24, 0),
    ),
  };

  // The max distance from top of the screen beyond which
  double yMax = 0.0;

  // current speed along y-axis.
  double speedY = 0.0;

  // Controlls how long the hit animations will be played.
  final Timer _hitTimer = Timer(1);

  static const double gravity = 800;

  final PlayerData playerData;

  bool isHit = false;

  Player(Image image, this.playerData)
      : super.fromFrameData(image, _animationMap);

  @override
  void onMount() {
    // First reset all the important properties, because onMount()
    // will be called even while restarting the game.
    _reset();

    // Add a hitbox
    add(
      RectangleHitbox.relative(
        Vector2(0.5, 0.7),
        parentSize: size,
        position: Vector2(size.x * 0.5, size.y * 0.3) / 2,
      ),
    );
    yMax = y;

    /// Set the callback for [_hitTimer].
    _hitTimer.onTick = () {
      current = PlayerAnimationStates.run;
      isHit = false;
    };

    super.onMount();
  }

  @override
  void update(double dt) {
    // v = u + at
    speedY += gravity * dt;

    // d = s0 + s * t
    y += speedY * dt;

    /// This code makes sure that player never goes beyond [yMax].
    if (isOnGround) {
      y = yMax;
      speedY = 0.0;
      if ((current != PlayerAnimationStates.hit) &&
          (current != PlayerAnimationStates.run)) {
        current = PlayerAnimationStates.run;
      }
    }

    _hitTimer.update(dt);
    super.update(dt);
  }

  // Gets called when player collides with other Collidables.
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Call hit only if other component is an Enemy and player
    // is not already in hit state.
    if ((other is Enemy) && (!isHit)) {
      hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  // Returns true if player is on ground.
  bool get isOnGround => (y >= yMax);

  // Makes the player jump.
  void jump() {
    // Jump only if player is on ground.
    if (isOnGround) {
      speedY = -300;
      current = PlayerAnimationStates.idle;
      AudioManager.instance.playSfx('jump14.wav');
    }
  }

  // This method changes the animation state to
  /// [PlayerAnimationStates.hit], plays the hit sound
  /// effect and reduces the player life by 1.
  void hit() {
    isHit = true;
    AudioManager.instance.playSfx('hurt7.wav');
    current = PlayerAnimationStates.hit;
    _hitTimer.start();
    playerData.lives -= 1;
  }

  // This method reset some of the important properties
  // of this component back to normal.
  void _reset() {
    if (isMounted) {
      removeFromParent();
    }
    anchor = Anchor.bottomLeft;
    position = Vector2(32, game.virtualSize.y - 22);
    size = Vector2.all(24);
    current = PlayerAnimationStates.run;
    isHit = false;
    speedY = 0.0;
  }
}
