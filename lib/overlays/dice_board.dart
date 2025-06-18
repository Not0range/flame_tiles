import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
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

const _diceSize = 100.0;

final _speedDividers = [2, 3, 4, 5, 6, 8, 10, 12, 15, 18, 20, 24, 30];

class _DiceBoardState extends State<_DiceBoard> {
  late Timer _timer;
  late Rotate _rotate = Rotate(0, _halfPi);
  var _animation = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant _DiceBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dice != oldWidget.dice) _startAnimation();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _animation = true;
    _rotate = _diceRotates[widget.dice];

    var iteration = 0;
    var index = 0;
    var speedDivider = _speedDividers[index];
    var a = _rotate.alpha;
    _timer = Timer.periodic(Duration(milliseconds: 30), (t) {
      if (iteration % (speedDivider * 2) == 0 && iteration > 0) {
        if (index == _speedDividers.length - 1) {
          _endAnimation(t);
          return;
        }
        speedDivider = _speedDividers[++index];
        iteration = 0;
      }
      iteration++;

      a += math.pi / speedDivider;
      setState(() {
        _rotate = Rotate(
          _halfPi * math.sin(a),
          _rotate.beta + math.pi / speedDivider,
        );
      });
    });
  }

  void _endAnimation(Timer t) {
    t.cancel();

    setState(() {
      _animation = false;
      _rotate = _diceRotates[widget.dice];
    });

    _timer = Timer(Duration(seconds: 2), () {
      widget.game.diceResult();
    });
  }

  void _skip() {
    _timer.cancel();
    if (_animation) {
      _endAnimation(_timer);
    } else {
      widget.game.diceResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(child: SizedBox.expand()),
        GestureDetector(
          onTap: _skip,
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedScale(
              scale: _animation ? 1 : 1.5,
              curve: Curves.bounceOut,
              duration: const Duration(milliseconds: 700),
              child: _Dice(rotate: _rotate),
            ),
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
  List<int> _indicies = [];
  var _position = 0;

  @override
  void initState() {
    super.initState();
    _position = ((widget.rotate.beta % _2pi) / _halfPi).floor();
    final a = widget.rotate.alpha % _2pi;
    if (a >= _halfPi && a < 3 * _halfPi) {
      _position += 4;
    }
    _orderSides();
  }

  @override
  void didUpdateWidget(covariant _Dice oldWidget) {
    super.didUpdateWidget(oldWidget);

    var pos = ((widget.rotate.beta % _2pi) / _halfPi).floor();
    final a = widget.rotate.alpha % _2pi;
    if (a >= math.pi && a < _2pi) {
      pos += 4;
    }
    if (_position != pos) {
      _position = pos;
      _orderSides();
    }
  }

  void _orderSides() {
    _indicies = [];

    final part = _position % 4;
    final top = _position < 4;
    switch (part) {
      case 0:
        _indicies.add(3);
        _indicies.add(5);
        _indicies.add(2);
        _indicies.add(0);
        break;
      case 1:
        _indicies.add(0);
        _indicies.add(3);
        _indicies.add(2);
        _indicies.add(5);
        break;
      case 2:
        _indicies.add(2);
        _indicies.add(0);
        _indicies.add(3);
        _indicies.add(5);
        break;
      case 3:
        _indicies.add(2);
        _indicies.add(5);
        _indicies.add(3);
        _indicies.add(0);
        break;
    }
    if (top) {
      _indicies.insert(0, 1);
      _indicies.insert(3, 4);
    } else {
      _indicies.insert(0, 4);
      _indicies.insert(3, 1);
    }
  }

  List<Widget> _buildSides() {
    return _indicies.map((e) => _sides[e]).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        // ..setEntry(3, 2, 0.00001)
        ..rotateX(widget.rotate.alpha)
        ..rotateY(widget.rotate.beta),
      alignment: Alignment.center,
      child: Center(child: Stack(children: _buildSides())),
    );
  }
}

const _2pi = 2 * math.pi;
const _halfPi = math.pi / 2;

const _diceRotates = [
  Rotate(0, 0), //1
  Rotate(-_halfPi, 0), //2
  Rotate(0, _halfPi), //3
  Rotate(0, -_halfPi), //3
  Rotate(_halfPi, 0), //5
  Rotate(0, math.pi), //6
];

final _sideDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: Colors.black, width: 1.5),
  borderRadius: BorderRadius.circular(8),
);
const _sidePadding = EdgeInsets.all(8);
final _sides = [
  Container(
    key: Key('Side1'),
    width: _diceSize,
    height: _diceSize,
    padding: _sidePadding,
    alignment: Alignment.center,
    decoration: _sideDecoration,
    transform: Matrix4.identity()..translate(0, 0, -_diceSize / 2),
    transformAlignment: Alignment.center,
    child: Center(child: const _DiceDot()),
  ),
  Container(
    key: Key('Side2'),
    width: _diceSize,
    height: _diceSize,
    padding: _sidePadding,
    alignment: Alignment.center,
    decoration: _sideDecoration,
    transform: Matrix4.identity()
      ..translate(0, _diceSize / 2)
      ..rotateX(_halfPi),
    transformAlignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DiceDot(),
        Align(alignment: Alignment.centerRight, child: const _DiceDot()),
      ],
    ),
  ),
  Container(
    key: Key('Side3'),
    width: _diceSize,
    height: _diceSize,
    padding: _sidePadding,
    alignment: Alignment.center,
    decoration: _sideDecoration,
    transform: Matrix4.identity()
      ..translate(_diceSize / 2)
      ..rotateY(-_halfPi),
    transformAlignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DiceDot(),
        Align(alignment: Alignment.center, child: const _DiceDot()),
        Align(alignment: Alignment.centerRight, child: const _DiceDot()),
      ],
    ),
  ),
  Container(
    key: Key('Side4'),
    width: _diceSize,
    height: _diceSize,
    padding: _sidePadding,
    alignment: Alignment.center,
    decoration: _sideDecoration,
    transform: Matrix4.identity()
      ..translate(-_diceSize / 2)
      ..rotateY(_halfPi),
    transformAlignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [_DiceDot(), _DiceDot()],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [_DiceDot(), _DiceDot()],
        ),
      ],
    ),
  ),
  Container(
    key: Key('Side5'),
    width: _diceSize,
    height: _diceSize,
    padding: _sidePadding,
    alignment: Alignment.center,
    decoration: _sideDecoration,
    transform: Matrix4.identity()
      ..translate(0, -_diceSize / 2)
      ..rotateX(-_halfPi),
    transformAlignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [_DiceDot(), _DiceDot()],
        ),
        const _DiceDot(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [_DiceDot(), _DiceDot()],
        ),
      ],
    ),
  ),
  Container(
    key: Key('Side6'),
    width: _diceSize,
    height: _diceSize,
    padding: _sidePadding,
    alignment: Alignment.center,
    decoration: _sideDecoration,
    transform: Matrix4.identity()
      ..translate(0, 0, _diceSize / 2)
      ..rotateY(-math.pi),
    transformAlignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [_DiceDot(), _DiceDot()],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [_DiceDot(), _DiceDot()],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [_DiceDot(), _DiceDot()],
        ),
      ],
    ),
  ),
];

class _DiceDot extends StatelessWidget {
  const _DiceDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _diceSize / 4,
      height: _diceSize / 4,
      decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
    );
  }
}

class Rotate {
  final double alpha;
  final double beta;

  const Rotate(this.alpha, this.beta);
}
