import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../tiles_game.dart';

class DecorationObject extends SpriteComponent
    with HasGameReference<TilesGame>, TapCallbacks {
  final String description;

  DecorationObject(Image image, this.description, {super.position, super.size})
    : super(sprite: Sprite(image), priority: 1000, anchor: Anchor.center);

  @override
  void onTapUp(TapUpEvent event) {
    if (game.buildContext == null) return;
    final provider = Provider.of<AppState>(game.buildContext!, listen: false);
    provider.description = description;
    game.overlays.add('Description', priority: 1);
  }
}
