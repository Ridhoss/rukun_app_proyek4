import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kk_service.dart';
import 'package:rukun_app_proyek4/services/auth_local_service.dart';

class KKRepository {
  final CloudKKService service;
  final AuthLocalService local;

  KKRepository(this.service, this.local);

  Future<List<Keluarga>> getAllKK() async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getAllKK(token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => Keluarga.fromJson(e)).toList();
  }

  Future<List<Keluarga>> getKKByRT(int rtId) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getKKByRT(rtId, token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => Keluarga.fromJson(e)).toList();
  }

  Future<Keluarga?> getKKById(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getKKById(id, token));

    _validateStatus(result);

    final data = result['data'];

    if (data == null) return null;

    return Keluarga.fromJson(data);
  }

  Future<void> createKK(Keluarga kk) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.createKK(kk.toJson(), token));

    _validateStatus(result);
  }

  Future<void> updateKK(int id, Map<String, dynamic> data) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.updateKK(id, data, token));

    _validateStatus(result);
  }

  Future<void> deleteKK(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.deleteKK(id, token));

    _validateStatus(result);
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
