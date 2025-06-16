import 'dart:ui';

import 'package:flame/components.dart';

class MapSelector extends SpriteComponent {
  bool show = false;

  MapSelector(double s, Image image)
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
