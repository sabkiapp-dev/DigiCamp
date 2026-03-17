import 'package:flutter/material.dart';

class NavbarProvider extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  set index(int index) => changeIndex(index);

  /// Method to change navbar index
  void changeIndex(int index) {
    if (_index != index) {
      _index = index;
      notifyListeners();
    }
  }

  void changeIndexSilently(int index) {
    if (_index != index) {
      _index = index;
    }
  }
}
