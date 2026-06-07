import 'package:dio/dio.dart';
import '../api/dio_client.dart';

class CloudWargaService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getAllWarga(
    String token, {
    Map<String, dynamic>? queryParameters,
    String? search,
  }) async {
    final params = <String, dynamic>{
      if (queryParameters != null) ...queryParameters,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final response = await _dio.get(
      '/warga',
      queryParameters: params.isNotEmpty ? params : null,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getWargaById(int id, String token) async {
    final response = await _dio.get(
      '/warga/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getWargaByKeluarga(
    int keluargaId,
    String token,
  ) async {
    final response = await _dio.get(
      '/warga/keluarga/$keluargaId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> createWarga(
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await _dio.post(
      '/warga',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> updateWarga(
    int id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await _dio.put(
      '/warga/$id',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> deleteWarga(int id, String token) async {
    final response = await _dio.delete(
      '/warga/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }
}
