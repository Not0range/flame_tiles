import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/painting.dart';

class IconButton extends AdvancedButtonComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    defaultLabel = TextComponent(
      text: 'Dice!',
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 24, color: BasicPalette.white.color),
      ),
    );
    defaultSkin = RoundedRectComponent()..setColor(BasicPalette.blue.color);
    downSkin = RoundedRectComponent()..setColor(BasicPalette.cyan.color);
  }
}

class RoundedRectComponent extends PositionComponent with HasPaint {
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0,
        0,
        width,
        height,
        topLeft: Radius.circular(height),
        topRight: Radius.circular(height),
        bottomRight: Radius.circular(height),
        bottomLeft: Radius.circular(height),
      ),
      paint,
    );
  }
}
