import 'package:dio/dio.dart';

class CloudAuthService {
  final Dio _dio;

  CloudAuthService(this._dio);

  Future<Map<String, dynamic>> login(String nik, String password) async {
    final response = await _dio.post(
      '/api/v1/user/login',
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
      '/api/v1/user/register',
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
      '/api/v1/user/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }
}
