import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/dashboard_model.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_dashboard_service.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';

class DashboardRepository {
  final CloudDashboardService service;
  final AuthLocalService local;

  DashboardRepository(this.service, this.local);

  Future<DashboardModel> getDashboardRW() async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getDashboardRW(token));

    _validateStatus(result);

    final data = result['data'];

    return DashboardModel.fromJson(data);
  }

  Future<DashboardModel> getDashboardRT() async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getDashboardRT(token));

    _validateStatus(result);

    final data = result['data'];

    return DashboardModel.fromJson(data);
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
      final message = e.response?.data?['message'] ?? "Terjadi kesalahan";
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
