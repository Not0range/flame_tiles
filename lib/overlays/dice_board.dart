import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../tiles_game.dart';

Widget diceBoardOverlay(BuildContext context, TilesGame game) {
  final dice = Provider.of<AppState>(context).currentDice;
  if (dice == null) return SizedBox.shrink();
  return _DiceBoard(game: game, dice: 0);
}

class _DiceBoard extends StatefulWidget {
  final TilesGame game;
  final int dice;

  const _DiceBoard({required this.game, required this.dice});

  @override
  State<StatefulWidget> createState() => _DiceBoardState();
}

const _diceSize = 100.0;

class _DiceBoardState extends State<_DiceBoard> {
  var _offset = Offset(0, 0);
  var _rotate = Rotate(0, 0);

  void _panUpdate(DragUpdateDetails details) {
    _offset += details.delta;
    setState(
      () => _rotate = Rotate(
        (_offset.dy * -math.pi / 180).clamp(-_halfPi * 0.9, _halfPi * 0.9),
        _offset.dx * math.pi / 180,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(child: SizedBox.expand()),
        GestureDetector(
          onPanUpdate: _panUpdate,
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _Dice(rotate: _rotate),
          ),
        ),
      ],
    );
  }
}

class _Dice extends StatefulWidget {
  final Rotate rotate;

  const _Dice({required this.rotate});

  @override
  State<_Dice> createState() => _DiceState();
}

class _DiceState extends State<_Dice> {
  final _children = _sides.toList();
  var _lastBeta = 0.0;

  @override
  void initState() {
    super.initState();
    _lastBeta = widget.rotate.alpha;
  }

  @override
  void didUpdateWidget(covariant _Dice oldWidget) {
    super.didUpdateWidget(oldWidget);

    final b = widget.rotate.beta % _2Pi;
    if (b > _halfPi &&
        b < 3 * _halfPi &&
        !(_lastBeta > _halfPi && _lastBeta < 3 * _halfPi)) {
      _lastBeta = b;
      _children.replaceRange(0, 2, [_sides[1], _sides[0]]);
    } else if (!(b > _halfPi && b < 3 * _halfPi) &&
        _lastBeta > _halfPi &&
        _lastBeta < 3 * _halfPi) {
      _lastBeta = b;
      _children.replaceRange(0, 2, [_sides[0], _sides[1]]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(widget.rotate.alpha)
        ..rotateY(widget.rotate.beta),
      alignment: Alignment.center,
      child: Center(child: Stack(children: _children)),
    );
  }
}

final _2Pi = 2 * math.pi;
final _halfPi = math.pi / 2;

final _sides = [
  Container(
    key: Key('Side6'),
    width: _diceSize,
    height: _diceSize,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: Colors.blue),
    transform: Matrix4.identity()
      ..translate(0, 0, _diceSize / 2)
      ..rotateY(-math.pi),
    transformAlignment: Alignment.center,
    child: Text('6'),
  ),
  Container(
    key: Key('Side1'),
    width: _diceSize,
    height: _diceSize,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: Colors.amber),
    transform: Matrix4.identity()..translate(0, 0, -_diceSize / 2),
    transformAlignment: Alignment.center,
    child: Text('1'),
  ),
];

class Rotate {
  final double alpha;
  final double beta;

  const Rotate(this.alpha, this.beta);
}
