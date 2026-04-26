import 'package:dio/dio.dart';

class CloudAuthService {
  final Dio _dio;

  CloudAuthService(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/user/login', data: {
      'email': email,
      'password': password,
    });

    return response.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _dio.post('/user/register', data: data);

    return response.data;
  }

  Future<Map<String, dynamic>> getMe(String token) async {
    final response = await _dio.get(
      '/user/me',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    return response.data;
  }
}