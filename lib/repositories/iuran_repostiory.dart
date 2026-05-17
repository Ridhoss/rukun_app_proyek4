import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/models/iuran/iuransaya_model.dart';
import 'package:rukun_app_proyek4/models/iuran/rw/iuran_detail_rw_model.dart';
import 'package:rukun_app_proyek4/services/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_iuran_service.dart';

class IuranRepository {
  final CloudIuranService service;
  final AuthLocalService local;

  IuranRepository(this.service, this.local);

  Future<List<Iuran>> getAllIuran() async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getAllIuran(token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => Iuran.fromJson(e)).toList();
  }

  Future<List<IuranSaya>> getIuranSaya() async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getIuranSaya(token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => IuranSaya.fromJson(e)).toList();
  }

  Future<Iuran?> getIuranById(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getIuranById(id, token));

    _validateStatus(result);

    final data = result['data'];

    if (data == null) return null;

    return Iuran.fromJson(data);
  }

  Future<void> createIuran(Iuran iuran) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.createIuran(iuran.toJson(), token),
    );

    _validateStatus(result);
  }

  Future<void> updateIuran(int id, Iuran iuran) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.updateIuran(id, iuran.toJson(), token),
    );

    _validateStatus(result);
  }

  Future<void> updateStatusTransaksi(int id, Map<String, dynamic> data) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.updateStatusTransaksi(id, data, token),
    );

    _validateStatus(result);
  }

  Future<void> deleteIuran(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.deleteIuran(id, token));

    _validateStatus(result);
  }

  Future<List<Iuran>> getIuranByRWId(int idRw) async {
    final token = await _requireToken();

    final result = await _safeCall(() => service.getIuranByRW(idRw, token));

    _validateStatus(result);

    final List data = result['data'] ?? [];

    return data.map((e) => Iuran.fromJson(e)).toList();
  }

  Future<IuranRWDetail> getIuranRWDetail(int id) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.getIuranDetailWithRT(id, token),
    );

    _validateStatus(result);

    final data = result['data'];

    print("DATA TYPE: ${data.runtimeType}");
    print("DATA CONTENT: $data");

    if (data == null) {
      throw Exception("Data tidak ditemukan");
    }

    return IuranRWDetail.fromJson(data);
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

  void _validateStatus(Map<String, dynamic> res) {
    if (res["status"] != "success") {
      throw Exception(res["message"] ?? "Unknown error");
    }
  }
}
