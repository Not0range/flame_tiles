import 'package:flame/components.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../tiles_game.dart';

const _overlayMargin = 16.0;

Widget inventoryOverlay(BuildContext context, TilesGame game) {
  final width = MediaQuery.of(context).size.width - _overlayMargin * 2;
  final count = (width / 100).floor();
  final inventory = Provider.of<AppState>(context).inventory;

  return Stack(
    children: [
      GestureDetector(
        onTap: () => game.overlays.toggle('Inventory'),
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(),
      ),
      Container(
        margin: const EdgeInsets.all(_overlayMargin),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white60,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 4, 8),
              child: IconButton(
                onPressed: () => game.overlays.toggle('Inventory'),
                iconSize: 40,
                icon: Icon(Icons.close),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: (30 / count).ceil(),
                itemBuilder: (ctx, r) => Row(
                  children: List.generate(
                    count,
                    (c) => _inventoryCell(
                      ctx,
                      game,
                      inventory.elementAtOrNull(r * count + c),
                    ),
                    growable: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _inventoryCell(BuildContext context, TilesGame game, int? child) {
  final i = switch (child) {
    0 => SpriteAnimationWidget.asset(
      path: 'ember.png',
      data: SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.15,
      ),
    ),
    1 => SpriteAnimationWidget.asset(
      path: 'ember.png',
      data: SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.3,
      ),
    ),
    2 => SpriteWidget.asset(path: 'ember.png', srcSize: Vector2.all(16)),
    _ => null,
  };

  return Expanded(
    child: AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: child != null
                ? () {
                    Provider.of<AppState>(context, listen: false).description =
                        'Item type $child';
                    game.overlays.add('Description', priority: 2);
                  }
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: i,
            ),
          ),
        ),
      ),
    ),
  );
}
