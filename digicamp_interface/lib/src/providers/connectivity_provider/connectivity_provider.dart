import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult _result = ConnectivityResult.none;

  ConnectivityResult get result => _result;

  bool get isConnected =>
      _result == ConnectivityResult.ethernet ||
      _result == ConnectivityResult.wifi ||
      _result == ConnectivityResult.mobile;

  ConnectivityProvider() {
    _connectivity.checkConnectivity().then(_changeConnectivity);
    _connectivity.onConnectivityChanged.listen(_changeConnectivity);
  }

  void _changeConnectivity(ConnectivityResult result) {
    _result = result;
    notifyListeners();
  }
}
