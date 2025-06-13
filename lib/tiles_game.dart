import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiles/tile_objects/river.dart';

class TilesGame extends FlameGame
    with MouseMovementDetector, TapDetector, ScrollDetector, ScaleDetector {
  late final IsometricTileMapComponent map;
  late final Selector selector;

  late final Ember ember;
  Block emberPosition = Block(0, 0);

  double? _startZoom;

  @override
  FutureOr<void> onLoad() async {
    final tilesImg = await images.load('tiles.png');
    final sprites = SpriteSheet(image: tilesImg, srcSize: Vector2.all(32));
    // final matrix = MatrixUtils.generate2DMatrix(
    //   50,
    //   50,
    //   (_, __) => _rand.nextInt(5) - 1,
    // ); // MatrixUtils.create2DMatrix(50, 50, initialValue: 0);
    final matrix = [
      [3, 0, 0, 0, 3, -1, 0, 0, 0, 0],
      [-1, -1, -1, -1, 0, -1, 0, -1, -1, 0],
      [-1, -1, -1, -1, 0, -1, 0, -1, 0, 0],
      [0, 0, 0, 0, 0, -1, 0, -1, 0, -1],
      [0, -1, -1, -1, 3, -1, 0, -1, 0, 0],
      [0, -1, 0, 0, 0, 0, 0, -1, -1, 0],
      [0, -1, 0, -1, -1, -1, -1, -1, -1, 0],
      [0, -1, 0, -1, 0, 0, 0, 0, 0, 0],
      [0, -1, 0, -1, 0, -1, -1, -1, -1, -1],
      [0, 0, 0, -1, 0, 0, 0, 0, 0, 0],
    ];

    world.add(
      map = IsometricTileMapComponent(
        sprites,
        matrix,
        destTileSize: Vector2.all(64),
        tileHeight: 16,
      ),
    );

    final selectorImage = await images.load('selector.png');
    world.add(selector = Selector(64, selectorImage));
    world.add(ember = Ember<TilesGame>(mapPosition: Block(0, 0)));

    world.add(
      Ember<TilesGame>(mapPosition: Block(1, 1), size: Vector2.all(64)),
    );

    world.add(River<TilesGame>(mapPosition: Block(1, 0), type: 1, size: 64));
    world.add(River<TilesGame>(mapPosition: Block(2, 0), type: 1, size: 64));
    world.add(River<TilesGame>(mapPosition: Block(3, 0), type: 1, size: 64));
    world.add(River<TilesGame>(mapPosition: Block(4, 1), type: 0, size: 64));
    world.add(River<TilesGame>(mapPosition: Block(4, 2), type: 0, size: 64));
    world.add(River<TilesGame>(mapPosition: Block(4, 3), type: 0, size: 64));
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final screenPosition =
        (info.eventPosition.widget - camera.viewport.size / 2) /
            camera.viewfinder.zoom +
        camera.viewfinder.position;
    final block = map.getBlock(screenPosition);
    selector.show = map.containsBlock(block);
    selector.position.setFrom(map.position + map.getBlockRenderPosition(block));
  }

  @override
  void onTapDown(TapDownInfo info) {
    final screenPosition =
        (info.eventPosition.widget - camera.viewport.size / 2) /
            camera.viewfinder.zoom +
        camera.viewfinder.position;
    final block = map.getBlock(screenPosition);
    if (!map.containsBlock(block) || ember.movingInProgress) return;

    ember.moveTo(block);
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final d = info.scrollDelta.global.y;
    if (d > 0) {
      camera.viewfinder.zoom = math.max(0.5, camera.viewfinder.zoom - 0.1);
    } else if (d < 0) {
      camera.viewfinder.zoom = math.min(2, camera.viewfinder.zoom + 0.1);
    }
  }

  @override
  void onScaleStart(ScaleStartInfo info) {
    _startZoom = camera.viewfinder.zoom;
    selector.show = false;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    if (!info.scale.global.isIdentity()) {
      if (_startZoom == null) return;
      camera.viewfinder.zoom = (_startZoom! * info.scale.global.y).clamp(
        0.5,
        2,
      );
    } else {
      camera.moveBy(-info.delta.global / camera.viewfinder.zoom);
    }
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    _startZoom = null;
    selector.show = true;
  }
}

class Selector extends SpriteComponent {
  bool show = true;

  Selector(double s, Image image)
    : super(
        sprite: Sprite(image, srcSize: Vector2.all(32.0)),
        size: Vector2.all(s),
      );

  @override
  void render(Canvas canvas) {
    if (!show) {
      return;
    }

    super.render(canvas);
  }
}

const _emberSize = 30.0;

class Ember<T extends TilesGame> extends SpriteAnimationComponent
    with HasGameReference<T> {
  Block mapPosition;
  IsometricTileMapComponent get map => game.map;

  Ember({required this.mapPosition, Vector2? size, super.priority, super.key})
    : super(size: size ?? Vector2.all(_emberSize), anchor: Anchor(0.5, 0.75)) {
    priority = mapPosition.x + mapPosition.y;
  }

  @override
  Future<void> onLoad() async {
    position = map.position + map.getBlockCenterPosition(mapPosition);
    animation = await game.loadSpriteAnimation(
      'ember.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.15,
      ),
    );
  }

  bool get movingInProgress => children.any((c) => c is SequenceEffect);

  void moveTo(Block block, {void Function()? onComplete}) {
    if (block == mapPosition) return;

    if (block.x != mapPosition.x && block.y != mapPosition.y) {
      moveTo(Block(block.x, mapPosition.y), onComplete: () => moveTo(block));
      return;
    }

    scale = block.y != mapPosition.y ? Vector2(-1, 1) : Vector2.all(1);
    animation?.stepTime = 0.1;

    final effects = List<Effect>.empty(growable: true);
    final scopePosition = mapPosition;
    if (block.y != mapPosition.y) {
      final positive = mapPosition.y < block.y;
      for (
        var i = positive ? 1 : -1;
        positive ? i <= block.y - mapPosition.y : i >= block.y - mapPosition.y;
        i += positive ? 1 : -1
      ) {
        final dest = map.getBlockCenterPosition(
          Block(block.x, mapPosition.y + i),
        );
        effects.add(
          MoveEffect.to(
            dest,
            EffectController(speed: 100),
            onComplete: () {
              priority = block.x + scopePosition.y + i;
            },
          ),
        );
      }
      priority = scopePosition.x + scopePosition.y + (positive ? 1 : -1);
    } else {
      final positive = mapPosition.x < block.x;
      for (
        var i = positive ? 1 : -1;
        positive ? i <= block.x - mapPosition.x : i >= block.x - mapPosition.x;
        i += positive ? 1 : -1
      ) {
        final dest = map.getBlockCenterPosition(
          Block(mapPosition.x + i, block.y),
        );
        effects.add(
          MoveEffect.to(
            dest,
            EffectController(speed: 100),
            onComplete: () {
              priority = scopePosition.x + i + block.y;
            },
          ),
        );
      }
      priority = scopePosition.x + (positive ? 1 : -1) + scopePosition.y;
    }
    if (effects.isEmpty) return;

    add(
      SequenceEffect(
        effects,
        onComplete: () {
          animation?.stepTime = 0.15;
          onComplete?.call();
        },
      ),
    );
    mapPosition = block;
  }
}
