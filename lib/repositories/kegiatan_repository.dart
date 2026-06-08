import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kegiatan_service.dart';
import 'package:rukun_app_proyek4/services/local/local_kegiatan_cache_service.dart';
import 'package:rukun_app_proyek4/utils/connectivity_helper.dart';

class KegiatanRepository {
  final CloudKegiatanService service;
  final AuthLocalService local;
  final KegiatanLocalCacheService cache = KegiatanLocalCacheService();

  KegiatanRepository(this.service, this.local);

  // ── Read Methods (cache + online) ──────────────────────────────

  Future<List<Kegiatan>> getAllKegiatan() async {
    final token = await local.getToken();
    if (token == null) return _readCachedList();
    if (await ConnectivityHelper.isOffline()) return _readCachedList();

    try {
      final result = await _safeCall(() => service.getAllKegiatan(token));
      _validateStatus(result);
      final List data = result['data'] ?? [];
      final rawItems = data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      await cache.cacheKegiatanRawList(rawItems);
      return rawItems.map(Kegiatan.fromJson).toList();
    } catch (e) {
      final cached = await _readCachedList();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<Kegiatan?> getKegiatanById(int id) async {
    final token = await local.getToken();
    if (token == null) return _getCachedById(id);
    if (await ConnectivityHelper.isOffline()) return _getCachedById(id);

    try {
      final result = await _safeCall(() => service.getKegiatanById(id, token));
      _validateStatus(result);
      final data = result['data'];
      if (data == null) return null;
      final item = Kegiatan.fromJson(data);
      await cache.upsertKegiatanRaw(Map<String, dynamic>.from(data));
      return item;
    } catch (e) {
      final cached = await _getCachedById(id);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<List<Kegiatan>> getKegiatanByRW(int rwId) async {
    final token = await local.getToken();
    if (token == null) return _readCachedList(filterRwId: rwId);
    if (await ConnectivityHelper.isOffline()) {
      return _readCachedList(filterRwId: rwId);
    }

    try {
      final result = await _safeCall(() => service.getKegiatanByRW(rwId, token));
      _validateStatus(result);
      final List data = result['data'] ?? [];
      final rawItems = data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      await cache.cacheKegiatanRawList(rawItems);
      return rawItems.map(Kegiatan.fromJson).toList();
    } catch (e) {
      final cached = await _readCachedList(filterRwId: rwId);
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  // ── Write Methods (online-only) ────────────────────────────────

  Future<bool> createKegiatan(Kegiatan kegiatan) async {
    final token = await _requireToken();
    _requireOnline();

    final result = await _safeCall(
      () => service.createKegiatan(kegiatan.toJson(), token),
    );
    _validateStatus(result);

    final data = result['data'];
    if (data is Map) {
      await cache.upsertKegiatanRaw(Map<String, dynamic>.from(data));
    }
    return true;
  }

  Future<void> updateKegiatan(int id, Map<String, dynamic> data) async {
    final token = await _requireToken();
    _requireOnline();

    final result = await _safeCall(
      () => service.updateKegiatan(id, data, token),
    );
    _validateStatus(result);

    final resData = result['data'];
    if (resData is Map) {
      await cache.upsertKegiatanRaw(Map<String, dynamic>.from(resData));
    }
  }

  Future<void> deleteKegiatan(int id) async {
    final token = await _requireToken();
    _requireOnline();

    final result = await _safeCall(() => service.deleteKegiatan(id, token));
    _validateStatus(result);
    await cache.removeKegiatan(id);
  }

  // ── Helpers ────────────────────────────────────────────────────

  Future<String> _requireToken() async {
    final token = await local.getToken();
    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }
    return token;
  }

  void _requireOnline() {
    if (ConnectivityHelper.isLastKnownOffline) {
      throw Exception('Tidak dapat melakukan aksi ini saat offline');
    }
  }

  Future<List<Kegiatan>> _readCachedList({int? filterRwId}) async {
    final cached = await cache.readKegiatanRaw();
    var items = cached;
    if (filterRwId != null) {
      items = items.where(
        (item) => (item['rw_id'] as num?)?.toInt() == filterRwId,
      ).toList();
    }
    return items.map(Kegiatan.fromJson).toList();
  }

  Future<Kegiatan?> _getCachedById(int id) async {
    final cached = await cache.readKegiatanRaw();
    for (final item in cached) {
      if ((item['id'] as num?)?.toInt() == id) {
        return Kegiatan.fromJson(item);
      }
    }
    return null;
  }

  // ── Network ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _safeCall(
    Future<Map<String, dynamic>> Function() fn,
  ) async {
    try {
      return await fn();
    } on DioException {
      rethrow;
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
