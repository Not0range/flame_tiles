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
                itemCount: 10,
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
  final icon = switch (child) {
    0 => Icons.ac_unit,
    1 => Icons.access_alarm,
    2 => Icons.dangerous,
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
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: (icon != null ? Icon(icon, size: 40) : null),
            ),
          ),
        ),
      ),
    ),
  );
}
