import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame_network_assets/flame_network_assets.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'components/decoration_object.dart';
import 'components/map_component.dart';
import 'utils/matrix_utils.dart';

class TilesGame extends FlameGame
    with ScrollDetector, ScaleDetector, MouseMovementDetector {
  late final IsometricTileMapComponent map;
  late final Ember ember;

  final _path = <Block>[];
  var _current = 0;

  double? _startZoom;

  @override
  FutureOr<void> onLoad() async {
    final networkAssets = FlameNetworkImages();
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

    final tilesImg = await networkAssets.load(mapJson['tileSet']['url']);
    final sprites = SpriteSheet(
      image: tilesImg,
      srcSize: Vector2.all(mapJson['tileSet']['srcSize']),
    );

    world.add(
      map = MapComponent(
        sprites,
        matrix,
        destTileSize: Vector2.all(mapJson['tileSet']['destSize']),
        tileHeight: mapJson['tileSet']['height'],
      ),
    );

    world.add(ember = Ember<TilesGame>(mapPosition: _path[0]));

    final decorations = mapJson['decorations'] as List<dynamic>;
    for (var d in decorations) {
      world.add(
        DecorationObject(
          await images.load(d['url']), //TODO replace to network image
          d['description'],
          position: Vector2(d['x'], d['y']),
          size: Vector2(d['width'], d['height']),
        ),
      );
    }

    camera.follow(ember);
  }

  @override
  Color backgroundColor() {
    return Colors.blue;
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    info.handled = false;
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
    overlays.remove('DiceButton');
    _startZoom = camera.viewfinder.zoom;
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
    if (!ember.movingInProgress) overlays.add('DiceButton');
    _startZoom = null;
  }

  void dice() {
    if (buildContext == null) return;

    final provider = Provider.of<AppState>(buildContext!, listen: false);
    if (provider.dices <= 0 || _current == _path.length - 1) {
      return;
    }

    final result = math.Random().nextInt(6);

    provider.currentDice = result;
    provider.dices -= 1;
    overlays.remove('DiceButton');
    overlays.add('Diceboard');
  }

  void diceResult() {
    if (buildContext == null) return;

    overlays.remove('Diceboard');
    final provider = Provider.of<AppState>(buildContext!, listen: false);
    if (provider.currentDice == null) return;

    final result = provider.currentDice! + 1;
    final path = _path.skip(_current + 1).take(result).toList(growable: false);
    ember.movePath(
      path,
      onComplete: () {
        overlays.add('DiceButton');
        _current += result;
      },
    );
    camera.follow(ember);
    provider.currentDice = null;
  }

  void resetCamera() {
    camera.follow(ember, maxSpeed: 1000);
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

    final effects = <Effect>[];
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
