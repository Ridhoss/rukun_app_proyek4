import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_warga_service.dart';
import 'package:rukun_app_proyek4/services/auth_local_service.dart';

class WargaRepository {
  final CloudWargaService service;
  final AuthLocalService local;

  WargaRepository(this.service, this.local);

  Future<List<Warga>> getAllWarga() async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getAllWarga(token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => Warga.fromJson(e)).toList();
  }

  Future<Warga?> getWargaById(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.getWargaById(id, token),
    );

    _validateStatus(result);

    final data = result['data'];

    if (data == null) return null;

    return Warga.fromJson(data);
  }

  Future<List<Warga>> getWargaByKeluarga(int keluargaId) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.getWargaByKeluarga(keluargaId, token),
    );

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => Warga.fromJson(e)).toList();
  }

  Future<Warga?> createWarga(Warga warga) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.createWarga(warga.toJson(), token),
    );

    _validateStatus(result);

    final data = result['data'];

    if (data == null) return null;

    return Warga.fromJson(data);
  }

  Future<Warga?> updateWarga(int id, Warga warga) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.updateWarga(id, warga.toJson(), token),
    );

    _validateStatus(result);

    final data = result['data'];

    if (data == null) return null;

    return Warga.fromJson(data);
  }

  Future<void> deleteWarga(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.deleteWarga(id, token),
    );

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