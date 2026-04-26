import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/auth_response_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_auth_service.dart';

class AuthRepository {
  final CloudAuthService service;

  AuthRepository(this.service);

  Future<AuthResponse> login(String nik, String password) async {
    try {
      final result = await service.login(nik, password);

      if (result['status'] != 'success') {
        throw Exception(result['message']);
      }

      return AuthResponse.fromJson(result['data']);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? "Terjadi kesalahan";

      throw Exception(message);
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    final result = await service.register(data);

    final meta = result['meta'];

    if (meta['code'] != 201) {
      throw Exception(meta['message']);
    }
  }

  Future<User> getMe(String token) async {
    final result = await service.getMe(token);

    final meta = result['meta'];
    final data = result['data'];

    if (meta['code'] != 200) {
      throw Exception(meta['message']);
    }

    return User.fromJson(data);
  }
}
