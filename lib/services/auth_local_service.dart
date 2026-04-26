import 'package:hive/hive.dart';
import 'hive_service.dart';

class AuthLocalService {
  final HiveService _hiveService;

  AuthLocalService(this._hiveService);

  Future<Box> _box() async {
    return await _hiveService.openBox('auth');
  }

  Future<void> saveToken(String token) async {
    final box = await _box();
    await box.put('token', token);
  }

  Future<String?> getToken() async {
    final box = await _box();
    return box.get('token');
  }

  Future<void> clear() async {
    final box = await _box();
    await box.clear();
  }
}