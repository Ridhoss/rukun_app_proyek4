import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/core/network/dio_client.dart';

class CloudRtRwService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getRtbyRwID(String token, int idRw) async {
    final response = await _dio.get(
      '/api/v1/rukun-warga/$idRw',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }
}
