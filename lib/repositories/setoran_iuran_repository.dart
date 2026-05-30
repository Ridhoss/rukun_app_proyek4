import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/setoran_iuran_rt_model.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_setoran_iuran_service.dart';

class SetoranIuranRtRepository {
  final CloudSetoranIuranRtService service;
  final AuthLocalService local;

  SetoranIuranRtRepository(this.service, this.local);

  Future<List<SetoranIuranRt>> getAllSetoran() async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getAllSetoran(token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => SetoranIuranRt.fromJson(e)).toList();
  }

  Future<SetoranIuranRt?> getSetoranById(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getSetoranById(id, token));

    _validateStatus(result);

    final data = result['data'];

    if (data == null) return null;

    return SetoranIuranRt.fromJson(data);
  }

  Future<List<SetoranIuranRt>> getSetoranByRT(int rtId) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getSetoranByRT(rtId, token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => SetoranIuranRt.fromJson(e)).toList();
  }

  Future<List<SetoranIuranRt>> getSetoranByIuranRT(
    int iuranId,
    int rtId,
  ) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.getSetoranByIuranRT(iuranId, rtId, token),
    );

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => SetoranIuranRt.fromJson(e)).toList();
  }

  Future<SetoranIuranRt?> getSetoranByPeriode(
    int iuranId,
    int rtId,
    String periode,
  ) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.getSetoranByPeriode(iuranId, rtId, periode, token),
    );

    _validateStatus(result);

    final data = result['data'];

    if (data == null) {
      return null;
    }

    return SetoranIuranRt.fromJson(data);
  }

  Future<void> createSetoran(SetoranIuranRt setoran) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.createSetoran(setoran.toJson(), token),
    );

    _validateStatus(result);
  }

  Future<void> updateSetoran(int id, SetoranIuranRt setoran) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.updateSetoran(id, setoran.toJson(), token),
    );

    _validateStatus(result);
  }

  Future<void> approveSetoran(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.approveSetoran(id, token));

    _validateStatus(result);
  }

  Future<void> rejectSetoran(int id, String catatan) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.rejectSetoran(id, catatan, token),
    );

    _validateStatus(result);
  }

  Future<void> deleteSetoran(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.deleteSetoran(id, token));

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
