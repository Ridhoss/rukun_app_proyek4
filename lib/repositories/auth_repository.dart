import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/auth_response_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/services/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_auth_service.dart';

class AuthRepository {
  final CloudAuthService service;
  final AuthLocalService local;

  AuthRepository(this.service, this.local);

  Future<AuthResponse> login(String nik, String password) async {
    final result = await _safeCall(() => service.login(nik, password));

    _validateStatus(result);

    final auth = AuthResponse.fromJson(result['data']);
    await local.saveToken(auth.token);

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

  Future<void> logout() async {
    await local.clear();
  }

  Future<String?> getToken() async {
    return await local.getToken();
  }

  Future<User> getMe(String token) async {
    final result = await _safeCall(() => service.getMe(token));

    _validateStatus(result);

    return User.fromJson(result['data']);
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

  //sementara dummy
  @override
  // ignore: override_on_non_overriding_member
  Future<Warga> getWarga(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return Warga(id: id, nama: "Pengurus", nik: "3201010101010001");
  }
}
