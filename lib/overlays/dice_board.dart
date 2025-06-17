import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../tiles_game.dart';

Widget diceBoardOverlay(BuildContext context, TilesGame game) {
  final dice = Provider.of<AppState>(context).currentDice;
  if (dice == null) return SizedBox.shrink();
  return _DiceBoard(game: game, dice: dice);
}

class _DiceBoard extends StatefulWidget {
  final TilesGame game;
  final int dice;

  const _DiceBoard({required this.game, required this.dice});

  @override
  State<StatefulWidget> createState() => _DiceBoardState();
}

class _DiceBoardState extends State<_DiceBoard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
