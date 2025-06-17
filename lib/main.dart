import 'package:flame/game.dart';
import 'package:flame_tiles/tiles_game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: _mainGame()));
}

Widget _mainGame() {
  return GameWidget<TilesGame>(
    game: TilesGame(),
    overlayBuilderMap: {
      'DiceButton': _diceButton,
      'GameOverlay': _gameOverlay,
      'Inventory': _inventoryOverlay,
    },
    initialActiveOverlays: ['DiceButton', 'GameOverlay'],
  );
}

Widget _diceButton(BuildContext context, TilesGame game) {
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

Widget _gameOverlay(BuildContext context, TilesGame game) {
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
                label: Text('${state.dices}'),
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

Widget _inventoryOverlay(BuildContext context, TilesGame game) {
  final count = (MediaQuery.of(context).size.width / 100).floor();
  final inventory = Provider.of<AppState>(context).inventory;

  return Stack(
    children: [
      AbsorbPointer(child: SizedBox.expand()),
      Container(
        margin: const EdgeInsets.all(16),
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

Widget _inventoryCell(int? child) {
  final icon = switch (child) {
    0 => Icons.ac_unit,
    1 => Icons.access_alarm,
    2 => Icons.dangerous,
    _ => null,
  };

  return Expanded(
    child: AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: icon != null ? Icon(icon, size: 40) : null,
      ),
    ),
  );
}
