import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static Connectivity? _connectivity;

  static void init(Connectivity connectivity) {
    _connectivity = connectivity;
  }

  static Future<bool> isOnline() async {
    if (_connectivity == null) return true;
    try {
      final result = await _connectivity!.checkConnectivity();
      return result.any((e) => e != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }

  static Future<bool> isOffline() async => !(await isOnline());
}
