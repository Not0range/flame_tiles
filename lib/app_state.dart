import 'dart:math' as math;

import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  int _dices = 0;
  int get dices => _dices;
  set dices(int value) {
    _dices = value;
    notifyListeners();
  }

  int _currency = 0;
  int get currency => _currency;
  set currency(int value) {
    _currency = value;
    notifyListeners();
  }

  List<int> _inventory = _generateItems();
  List<int> get inventory => _inventory;
  set inventory(List<int> value) {
    _inventory = value;
    notifyListeners();
  }

  String? _description;
  String? get description => _description;
  set description(String? value) {
    _description = value;
    notifyListeners();
  }

  int? _currentDice;
  int? get currentDice => _currentDice;
  set currentDice(int? value) {
    _currentDice = value;
    notifyListeners();
  }

  void add(int value) {
    _inventory.add(value);
    notifyListeners();
  }

  void removeAt(int index) {
    _inventory.removeAt(index);
    notifyListeners();
  }
}

List<int> _generateItems() {
  final rand = math.Random();
  return List.generate(rand.nextInt(20) + 5, (_) => rand.nextInt(3));
}
