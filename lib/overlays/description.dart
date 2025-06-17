import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../tiles_game.dart';

Widget descriptionOverlay(BuildContext context, TilesGame game) {
  final text = Provider.of<AppState>(context).description;

  return Stack(
    children: [
      GestureDetector(
        onTap: () => game.overlays.toggle('Description'),
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(),
      ),
      Center(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white60,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: IconButton(
                  onPressed: () => game.overlays.toggle('Description'),
                  iconSize: 40,
                  icon: Icon(Icons.close),
                ),
              ),
              Text(
                text ?? '',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
