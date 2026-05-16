import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/services/api/dio_client.dart';

class CloudRtRwService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getRtbyRwID(String token, int idRw) async {
    final response = await _dio.get(
      '/rukun-warga/$idRw',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }
}
