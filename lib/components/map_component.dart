import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../tiles_game.dart';

class MapComponent extends IsometricTileMapComponent
    with HasGameReference<TilesGame>, TapCallbacks {
  final _rand = math.Random();

  MapComponent(
    super.tileset,
    super.matrix, {
    super.destTileSize,
    super.tileHeight,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  });

  @override
  void onTapUp(TapUpEvent event) {
    final block = getBlock(event.localPosition);
    if (!containsBlock(block) ||
        blockValue(block) == -1 ||
        game.buildContext == null) {
      return;
    }

    final provider = Provider.of<AppState>(game.buildContext!, listen: false);
    provider.description = switch (_rand.nextInt(2)) {
      0 => 'Just empty tile. Really...',
      1 => 'Another empty tile. Really...',
      _ => '???',
    };
    game.overlays.add('Description', priority: 1);
  }
}
