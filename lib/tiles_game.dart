import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';

import 'components/map_selector.dart';
import 'utils/matrix_utils.dart';

class TilesGame extends FlameGame
    with MouseMovementDetector, TapDetector, ScrollDetector, ScaleDetector {
  late final IsometricTileMapComponent map;
  late final MapSelector selector;
  late final Ember ember;

  final List<Block> _path = List.empty(growable: true);
  var _current = 0;

  double? _startZoom;

  @override
  FutureOr<void> onLoad() async {
    final mapJson = jsonDecode(
      await rootBundle.loadString('assets/maps/map.json'),
    );

    final matrix = MatrixUtils.create2DMatrix(
      mapJson['sizes']['height'],
      mapJson['sizes']['width'],
    );

    final tiles = mapJson['tiles'] as List<dynamic>;
    for (var tile in tiles) {
      _path.add(Block(tile['x'], tile['y']));
      matrix[tile['y']][tile['x']] = 0;
    }

    final tilesImg = await images.load('tiles.png');
    final sprites = SpriteSheet(image: tilesImg, srcSize: Vector2.all(32));

    world.add(
      map = IsometricTileMapComponent(
        sprites,
        matrix,
        destTileSize: Vector2.all(64),
        tileHeight: 16,
      ),
    );

    final selectorImage = await images.load('selector.png');
    world.add(selector = MapSelector(64, selectorImage));
    world.add(ember = Ember<TilesGame>(mapPosition: _path[0]));
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final screenPosition =
        (info.eventPosition.widget - camera.viewport.size / 2) /
            camera.viewfinder.zoom +
        camera.viewfinder.position;
    final block = map.getBlock(screenPosition);
    selector.show = map.containsBlock(block) && map.blockValue(block) != -1;
    selector.position.setFrom(map.position + map.getBlockRenderPosition(block));
  }

  @override
  void onTapDown(TapDownInfo info) {
    final screenPosition =
        (info.eventPosition.widget - camera.viewport.size / 2) /
            camera.viewfinder.zoom +
        camera.viewfinder.position;
    final block = map.getBlock(screenPosition);
    if (!map.containsBlock(block)) return;

    // ember.moveTo(block);
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
    overlays.remove('GameOverlay');
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
    overlays.add('GameOverlay');
    _startZoom = null;
  }

  void dice() {
    overlays.remove('GameOverlay');
    final result = math.Random().nextInt(6) + 1;
    final path = _path.skip(_current).take(result).toList(growable: false);
    ember.movePath(
      path,
      onComplete: () {
        overlays.add('GameOverlay');
        _current += result;
      },
    );
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

  void movePath(List<Block> path, {void Function()? onComplete}) {
    if (path.isEmpty) return;

    final effects = List<Effect>.empty(growable: true);
    // final scopePosition = mapPosition;
    for (var i = 0; i < path.length - 1; i++) {
      final dest = map.getBlockCenterPosition(path[i]);
      effects.add(
        MoveEffect.to(
          dest,
          EffectController(speed: 100),
          onComplete: () {
            mapPosition = path[i];
          },
        ),
      );
    }
    effects.add(
      MoveEffect.to(
        map.getBlockCenterPosition(path[path.length - 1]),
        EffectController(speed: 100),
        onComplete: () {
          mapPosition = path[path.length - 1];
        },
      ),
    );

    animation?.stepTime = 0.1;
    add(
      SequenceEffect(
        effects,
        onComplete: () {
          animation?.stepTime = 0.15;
          onComplete?.call();
        },
      ),
    );
  }

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
