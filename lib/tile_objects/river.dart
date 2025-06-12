import 'package:flame/components.dart';

import '../tiles_game.dart';

class River<T extends TilesGame> extends SpriteAnimationComponent
    with HasGameReference<T> {
  int type;
  Block mapPosition;
  IsometricTileMapComponent get map => game.map;

  River({required this.mapPosition, required this.type, required double size})
    : super(size: Vector2.all(size), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = map.position + map.getBlockCenterPosition(mapPosition);
    final animData = SpriteAnimationData([
      SpriteAnimationFrameData(
        srcPosition: Vector2(0, type * 32),
        srcSize: Vector2.all(32),
        stepTime: 1,
      ),
      SpriteAnimationFrameData(
        srcPosition: Vector2(32, type * 32),
        srcSize: Vector2.all(32),
        stepTime: 1,
      ),
    ]);

    animation = await game.loadSpriteAnimation('river.png', animData);
  }
}
