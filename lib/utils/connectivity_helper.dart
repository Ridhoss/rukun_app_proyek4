import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static Connectivity? _connectivity;
  static bool _lastKnownOffline = false;

  static bool get isLastKnownOffline => _lastKnownOffline;

  static void init(Connectivity connectivity) {
    _connectivity = connectivity;
  }

  static Future<bool> isOnline() async {
    if (_connectivity == null) return true;
    try {
      final result = await _connectivity!.checkConnectivity();
      final online = result.any((e) => e != ConnectivityResult.none);
      _lastKnownOffline = !online;
      return online;
    } catch (_) {
      return true;
    }
  }

  static Future<bool> isOffline() async => !(await isOnline());
}
