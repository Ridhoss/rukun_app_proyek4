import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/rw_model.dart';
import 'package:rukun_app_proyek4/services/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_rtrw_service.dart';

class RTRWRepository {
  final CloudRtRwService service;
  final AuthLocalService local;

  RTRWRepository(this.service, this.local);

  Future<RwModel?> getRWById(int rwId) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getRtbyRwID(token, rwId));

    _validateStatus(result);

    final data = result['data'];

    if (data == null) return null;

    return RwModel.fromJson(data);
  }

  Future<String> _requireToken() async {
    final token = await local.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }

    return token;
  }

  Future<Map<String, dynamic>> _safeCall(
    Future<Map<String, dynamic>> Function() fn,
  ) async {
    try {
      return await fn();
    } on DioException catch (e) {
      final data = e.response?.data;

      String message;

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? "Terjadi kesalahan";
      } else if (data is String) {
        message = data;
      } else {
        message = "Terjadi kesalahan";
      }

      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _validateStatus(Map<String, dynamic> result) {
    if (result['status'] != 'success') {
      throw Exception(result['message'] ?? "Unknown error");
    }
  }
}
