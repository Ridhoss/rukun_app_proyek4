import 'package:rukun_app_proyek4/services/cloud/cloud_auth_service.dart';

class AuthRepository {
  final CloudAuthService service;

  AuthRepository(this.service);

  Future<Map<String, dynamic>> login(String email, String password) {
    return service.login(email, password);
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) {
    return service.register(data);
  }

  Future<Map<String, dynamic>> getMe(String token) {
    return service.getMe(token);
  }
}