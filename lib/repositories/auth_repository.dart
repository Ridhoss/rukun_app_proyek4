import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/auth_response_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_auth_service.dart';

class AuthRepository {
  final CloudAuthService service;
  final AuthLocalService local;

  AuthRepository(this.service, this.local);

  Future<AuthResponse> login(String nik, String password) async {
    final result = await _safeCall(() => service.login(nik, password));

    _validateStatus(result);

    final token = result['data']['token'];

    await local.saveToken(token);

    final me = await service.getMe(token);

    final user = User.fromJson(me['data']);

    return AuthResponse(token: token, user: user);
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

  Future<void> logout() async {
    await local.clearToken();
  }

  Future<String?> getToken() async {
    return await local.getToken();
  }

  Future<User> getMe(String token) async {
    final result = await _safeCall(() => service.getMe(token));

    _validateStatus(result);

    return User.fromJson(result['data']);
  }

  Future<User?> getUserByWargaId(int wargaId) async {
    final token = await local.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }

    final result = await _safeCall(
      () => service.getUserByWargaId(wargaId, token),
    );

    _validateStatus(result);

    final data = result['data'];

    if (data == null) return null;

    return User.fromJson(data);
  }

  Future<void> adminChangePassword(int userId, String password) async {
    final token = await local.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }

    final result = await _safeCall(
      () => service.adminChangePassword(userId, password, token),
    );

    _validateStatus(result);
  }

  Future<Map<String, dynamic>> _safeCall(
    Future<Map<String, dynamic>> Function() fn,
  ) async {
    try {
      return await fn();
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? "Terjadi kesalahan";

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
