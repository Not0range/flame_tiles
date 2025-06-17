import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'overlays/description.dart';
import 'overlays/dice_board.dart';
import 'overlays/game_overlay.dart';
import 'overlays/inventory.dart';
import 'tiles_game.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: _mainGame()));
}

Widget _mainGame() {
  return GameWidget<TilesGame>(
    game: TilesGame(),
    overlayBuilderMap: {
      'DiceButton': diceButtonOverlay,
      'GameOverlay': gameOverlay,
      'Inventory': inventoryOverlay,
      'Description': descriptionOverlay,
      'Diceboard': diceBoardOverlay,
    },
    initialActiveOverlays: ['DiceButton', 'GameOverlay'],
  );
}
