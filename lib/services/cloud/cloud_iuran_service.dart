import 'package:dio/dio.dart';
import '../api/dio_client.dart';

class CloudIuranService {
  final Dio _dio = DioClient().dio;

  Options _authHeader(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Map<String, dynamic>> getAllIuran(String token) async {
    final response = await _dio.get('/iuran', options: _authHeader(token));

    return response.data;
  }

  Future<Map<String, dynamic>> getIuranSaya(String token) async {
    final response = await _dio.get('/iuran/me', options: _authHeader(token));

    return response.data;
  }

  Future<Map<String, dynamic>> getIuranById(int id, String token) async {
    final response = await _dio.get('/iuran/$id', options: _authHeader(token));

    return response.data;
  }

  Future<Map<String, dynamic>> createIuran(
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await _dio.post(
      '/iuran',
      data: data,
      options: _authHeader(token),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> updateIuran(
    int id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await _dio.put(
      '/iuran/$id',
      data: data,
      options: _authHeader(token),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> deleteIuran(int id, String token) async {
    final response = await _dio.delete(
      '/iuran/$id',
      options: _authHeader(token),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getIuranByRW(int idRw, String token) async {
    final response = await _dio.get(
      '/iuran/rw/$idRw',
      options: _authHeader(token),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getIuranDetailWithRT(int idIuran, String token) async {
    final response = await _dio.get(
      '/iuran/$idIuran/detail',
      options: _authHeader(token),
    );

    return response.data;
  }
}
