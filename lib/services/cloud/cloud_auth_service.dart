import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/services/api/dio_client.dart';

class CloudAuthService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String nik, String password) async {
    final response = await _dio.post(
      '/user/login',
      data: {'nik': nik, 'password': password},
    );

    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String nik,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _dio.post(
      '/user/register',
      data: {
        "nik": nik,
        "password": password,
        "confirm_password": confirmPassword,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getMe(String token) async {
    final response = await _dio.get(
      '/user/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getUserByWargaId(int id, String token) async {
    final response = await _dio.get(
      '/user/warga/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> adminChangePassword(
    int userId,
    String password,
    String token,
  ) async {
    final response = await _dio.put(
      '/user/admin/change-password/$userId',
      data: {"new_password": password},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> changePassword(
    String password,
    String newpassword,
    String token,
  ) async {
    final response = await _dio.put(
      '/user/change-password',
      data: {"old_password": password, "new_password": newpassword},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }
}
