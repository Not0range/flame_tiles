import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../tiles_game.dart';

Widget gameOverlay(BuildContext context, TilesGame game) {
  final state = Provider.of<AppState>(context);

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => state.dices += 1,
              iconSize: 40,
              color: Colors.white,
              icon: Badge(
                label: Text('${state.dices}'),
                alignment: Alignment.bottomRight,
                child: Icon(Icons.casino_outlined),
              ),
            ),
            IconButton(
              onPressed: () => game.overlays.toggle('Inventory', priority: 1),
              iconSize: 40,
              color: Colors.white,
              icon: Icon(Icons.backpack_outlined),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {},
              iconSize: 40,
              color: Colors.white,
              icon: Badge(
                label: Text('${state.currency}'),
                alignment: Alignment.bottomLeft,
                child: Icon(Icons.diamond),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget diceButtonOverlay(BuildContext context, TilesGame game) {
  final d = Provider.of<AppState>(context).dices;

  return Align(
    alignment: FractionalOffset(0.5, 0.8),
    child: TextButton.icon(
      onPressed: d > 0 ? () => game.dice() : null,
      label: Text('Dice!'),
      icon: Icon(Icons.casino),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.amber),
        iconSize: WidgetStatePropertyAll(32),
        textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 24)),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        ),
      ),
    ),
  );
}
