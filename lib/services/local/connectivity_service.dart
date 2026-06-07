import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  ConnectivityService(this._connectivity) {
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result.any((e) => e != ConnectivityResult.none);
    notifyListeners();

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((e) => e != ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
        debugPrint('[Connectivity] ${online ? "ONLINE" : "OFFLINE"}');
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
