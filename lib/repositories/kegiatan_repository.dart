import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kegiatan_service.dart';

class KegiatanRepository {
  final CloudKegiatanService service;
  final AuthLocalService local;

  KegiatanRepository(this.service, this.local);

  Future<List<Kegiatan>> getAllKegiatan() async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.getAllKegiatan(token),
    );

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => Kegiatan.fromJson(e)).toList();
  }

  Future<Kegiatan?> getKegiatanById(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.getKegiatanById(id, token),
    );

    _validateStatus(result);

    final data = result['data'];

    if (data == null) return null;

    return Kegiatan.fromJson(data);
  }

  Future<List<Kegiatan>> getKegiatanByRW(int rwId) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.getKegiatanByRW(rwId, token),
    );

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => Kegiatan.fromJson(e)).toList();
  }


  Future<bool> createKegiatan(Kegiatan kegiatan) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.createKegiatan(kegiatan.toJson(), token),
    );

    _validateStatus(result);

    return true;
  }

  Future<void> updateKegiatan(int id, Map<String, dynamic> data) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.updateKegiatan(id, data, token),
    );

    _validateStatus(result);
  }

  Future<void> deleteKegiatan(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.deleteKegiatan(id, token),
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
      final data = e.response?.data;

      String message = "Terjadi kesalahan";

      if (data is Map<String, dynamic>) {
        message =
            data['message'] ??
            data['meta']?['message'] ??
            "Terjadi kesalahan";
      } else if (data is String) {
        message = data;
      }

      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _validateStatus(Map<String, dynamic> result) {
    final meta = result['meta'];

    if (meta != null && meta['code'] != 200) {
      throw Exception(meta['message'] ?? "Unknown error");
    }

    if (result['status'] != null && result['status'] != 'success') {
      throw Exception(result['message'] ?? "Unknown error");
    }
  }
}