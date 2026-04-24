import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/keluarga.dart';
import '../api/dio_client.dart';

class CloudKKService {
  final Dio _dio = DioClient().dio;

  Future<List<Keluarga>> getKKByRT(int rtId) async {
    final response = await _dio.get(
      '/keluarga',
      queryParameters: {'rt_id': rtId},
    );

    final List data = response.data['data'] ?? [];

    return data.map((e) => Keluarga.fromMap(e)).toList();
  }

  Future<Keluarga?> getKKById(int id) async {
    final response = await _dio.get('/keluarga/$id');

    final data = response.data['data'];

    if (data == null) return null;

    return Keluarga.fromMap(data);
  }

  Future<Keluarga?> createKK(Keluarga kk) async {
    final response = await _dio.post(
      '/keluarga',
      data: kk.toMap(),
    );

    final data = response.data['data'];

    return Keluarga.fromMap(data);
  }

  Future<Keluarga?> updateKK(int id, Keluarga kk) async {
    final response = await _dio.put(
      '/keluarga/$id',
      data: kk.toMap(),
    );

    final data = response.data['data'];

    return Keluarga.fromMap(data);
  }

  Future<void> deleteKK(int id) async {
    await _dio.delete('/keluarga/$id');
  }
}