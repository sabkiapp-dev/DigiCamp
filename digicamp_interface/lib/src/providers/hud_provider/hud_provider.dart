import 'package:flutter/material.dart';

class HudProvider extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void showProgress() {
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }
  }

  void hideProgress() {
    if (_isLoading) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
