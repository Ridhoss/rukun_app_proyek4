import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/auth_response_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_auth_service.dart';

class AuthRepository {
  final CloudAuthService service;

  AuthRepository(this.service);

  Future<AuthResponse> login(String nik, String password) async {
    final result = await _safeCall(
      () => service.login(nik, password),
    );

    _validateStatus(result);

    return AuthResponse.fromJson(result['data']);
  }

  Future<void> register({
    required String nik,
    required String password,
    required String confirmPassword,
  }) async {
    final result = await _safeCall(
      () => service.register(
        nik: nik,
        password: password,
        confirmPassword: confirmPassword,
      ),
    );

    _validateStatus(result);
  }

  Future<User> getMe(String token) async {
    final result = await _safeCall(
      () => service.getMe(token),
    );

    _validateStatus(result);

    return User.fromJson(result['data']);
  }

  Future<Map<String, dynamic>> _safeCall(
    Future<Map<String, dynamic>> Function() fn,
  ) async {
    try {
      return await fn();
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? "Terjadi kesalahan";

      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _validateStatus(Map<String, dynamic> result) {
    if (result['status'] != 'success') {
      throw Exception(result['message'] ?? "Unknown error");
    }
  }
}