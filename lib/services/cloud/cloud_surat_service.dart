import 'package:dio/dio.dart';
import '../api/dio_client.dart';

class CloudSuratService {
  final Dio _dio = DioClient().dio;

  Options _authHeader(String token) {
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  // GET ALL
  Future<Map<String, dynamic>> getAllSurat(
    String token,
  ) async {
    final response = await _dio.get(
      '/pengajuan-surat',
      options: _authHeader(token),
    );

    return response.data;
  }

  // GET SURAT SAYA
  Future<Map<String, dynamic>> getSuratSaya(
    String token,
  ) async {
    final response = await _dio.get(
      '/pengajuan-surat/me',
      options: _authHeader(token),
    );

    return response.data;
  }

  // GET BY ID
  Future<Map<String, dynamic>> getSuratById(
    int id,
    String token,
  ) async {
    final response = await _dio.get(
      '/pengajuan-surat/$id',
      options: _authHeader(token),
    );

    return response.data;
  }

  // CREATE
  Future<Map<String, dynamic>> createSurat(
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await _dio.post(
      '/pengajuan-surat',
      data: data,
      options: _authHeader(token),
    );

    return response.data;
  }

  // UPDATE STATUS
  Future<Map<String, dynamic>> updateStatusSurat(
    int id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await _dio.put(
      '/pengajuan-surat/$id/status',
      data: data,
      options: _authHeader(token),
    );

    return response.data;
  }

  // DELETE
  Future<Map<String, dynamic>> deleteSurat(
    int id,
    String token,
  ) async {
    final response = await _dio.delete(
      '/pengajuan-surat/$id',
      options: _authHeader(token),
    );

    return response.data;
  }
}