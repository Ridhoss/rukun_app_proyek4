import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_surat_service.dart';

class SuratRepository {
  final CloudSuratService service;
  final AuthLocalService local;

  SuratRepository(this.service, this.local);

  Future<List<PengajuanSurat>> getAllSurat() async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getAllSurat(token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => PengajuanSurat.fromJson(e)).toList();
  }

  Future<List<PengajuanSurat>> getSuratSaya() async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getSuratSaya(token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => PengajuanSurat.fromJson(e)).toList();
  }

  Future<PengajuanSurat?> getSuratById(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getSuratById(id, token));

    _validateStatus(result);

    final data = result['data'];

    if (data == null) return null;

    return PengajuanSurat.fromJson(data);
  }

  Future<List<PengajuanSurat>> getSuratByRt(int rtId) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getSuratByRt(rtId, token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => PengajuanSurat.fromJson(e)).toList();
  }

  Future<List<PengajuanSurat>> getSuratByRw(int rwId) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getSuratByRw(rwId, token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => PengajuanSurat.fromJson(e)).toList();
  }

  Future<bool> createSurat(PengajuanSurat surat) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.createSurat(surat.toJson(), token),
    );

    _validateStatus(result);

    return true;
  }

  Future<void> updateSurat(int id, Map<String, dynamic> data) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.updateSurat(id, data, token));

    _validateStatus(result);
  }

  Future<void> deleteSurat(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.deleteSurat(id, token));

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
            data['message'] ?? data['meta']?['message'] ?? "Terjadi kesalahan";
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
