import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kk_service.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/local/local_penduduk_cache_service.dart';

class KKRepository {
  final CloudKKService service;
  final AuthLocalService local;
  final PendudukLocalCacheService cache = PendudukLocalCacheService();

  KKRepository(this.service, this.local);

  Future<List<Keluarga>> getAllKK() async {
    try {
      final token = await _requireToken();

      final result = await _safeCall(() => service.getAllKK(token));

      _validateStatus(result);

      final List data = result['data'] ?? [];
      final items = data.map((e) => Keluarga.fromJson(e)).toList();

      await cache.cacheKeluargaList(items);

      return items;
    } catch (e) {
      final cached = await _getCachedKeluarga();
      if (cached.isNotEmpty && _canUseCache(e)) {
        return cached;
      }

      rethrow;
    }
  }

  Future<List<Keluarga>> getKKByRT(int rtId) async {
    try {
      final token = await _requireToken();

      final result = await _safeCall(() => service.getKKByRT(rtId, token));

      _validateStatus(result);

      final List data = result['data'] ?? [];
      final items = data.map((e) => Keluarga.fromJson(e)).toList();

      await cache.cacheKeluargaList(items);

      return items;
    } catch (e) {
      final cached = await _getCachedKeluargaByRt(rtId);
      if (cached.isNotEmpty && _canUseCache(e)) {
        return cached;
      }

      rethrow;
    }
  }

  Future<Keluarga?> getKKById(int id) async {
    try {
      final token = await _requireToken();

      final result = await _safeCall(() => service.getKKById(id, token));

      _validateStatus(result);

      final data = result['data'];

      if (data == null) return null;

      final item = Keluarga.fromJson(data);
      await cache.cacheKeluargaList([item]);

      return item;
    } catch (e) {
      final cached = await _getCachedKeluargaById(id);
      if (cached != null && _canUseCache(e)) {
        return cached;
      }

      rethrow;
    }
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
      final message =
          e.response?.data?['message'] ?? e.message ?? "Terjadi kesalahan";

      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<List<Keluarga>> _getCachedKeluarga() async {
    final raw = await cache.readKeluargaRaw();
    return raw.map(Keluarga.fromJson).toList();
  }

  Future<List<Keluarga>> _getCachedKeluargaByRt(int rtId) async {
    final raw = await cache.readKeluargaRaw();
    return raw
        .where((item) => (item['rt_id'] as num?)?.toInt() == rtId)
        .map(Keluarga.fromJson)
        .toList();
  }

  Future<Keluarga?> _getCachedKeluargaById(int id) async {
    final raw = await cache.readKeluargaRaw();
    for (final item in raw) {
      if ((item['id'] as num?)?.toInt() == id) {
        return Keluarga.fromJson(item);
      }
    }

    return null;
  }

  bool _canUseCache(Object error) {
    final message = error.toString().toLowerCase();

    return message.contains('socketexception') ||
        message.contains('connection') ||
        message.contains('network') ||
        message.contains('timed out') ||
        message.contains('failed host lookup') ||
        message.contains('no internet') ||
        message.contains('xmlhttprequest error');
  }

  void _validateStatus(Map<String, dynamic> result) {
    if (result['status'] != 'success') {
      throw Exception(result['message'] ?? "Unknown error");
    }
  }
}
