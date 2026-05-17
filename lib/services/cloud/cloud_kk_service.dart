import 'package:dio/dio.dart';
import '../api/dio_client.dart';

class CloudKKService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getAllKK(String token) async {
    final response = await _dio.get(
      '/keluarga',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getKKByRT(int rtId, String token) async {
    final response = await _dio.get(
      '/keluarga/rt/$rtId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getKKById(int id, String token) async {
    final response = await _dio.get(
      '/keluarga/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> createKK(
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await _dio.post(
      '/keluarga',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> updateKK(
    int id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await _dio.put(
      '/keluarga/$id',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> deleteKK(int id, String token) async {
    final response = await _dio.delete(
      '/keluarga/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }
}
