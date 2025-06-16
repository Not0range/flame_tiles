import 'package:flame/game.dart';
import 'package:flame_tiles/tiles_game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget<TilesGame>(
      game: TilesGame(),
      overlayBuilderMap: {
        'GameOverlay': (ctx, game) {
          return Align(
            alignment: FractionalOffset(0.5, 0.75),
            child: TextButton.icon(
              onPressed: () => game.dice(),
              label: Text('Dice!'),
              icon: Icon(Icons.casino),
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.amber),
              ),
            ),
          );
          // return Align(
          //   alignment: FractionalOffset(0.5, 0.7),
          //   child: Container(
          //     decoration: BoxDecoration(
          //       color: Colors.amber,
          //       borderRadius: BorderRadius.circular(16),
          //     ),
          //     padding: EdgeInsets.all(8),
          //     child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [Icon(Icons.casino), Text('Dice!')],
          //     ),
          //   ),
          // );
        },
      },
      initialActiveOverlays: ['GameOverlay'],
    ),
  );
}
