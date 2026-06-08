import 'dart:io';

import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_surat_service.dart';

import 'package:rukun_app_proyek4/services/local/local_surat_cache_service.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';
import 'package:rukun_app_proyek4/utils/connectivity_helper.dart';

class SuratRepository {
  final CloudSuratService service;
  final AuthLocalService local;
  final SuratLocalCacheService _cache = SuratLocalCacheService();
  final CloudinaryService _cloudinary;

  SuratRepository(this.service, this.local, this._cloudinary);

  // ── Read Methods (cache + online) ──────────────────────────────

  Future<List<PengajuanSurat>> getAllSurat() async {
    final token = await local.getToken();
    if (token == null) return _getCachedSuratAll();
    if (await ConnectivityHelper.isOffline()) return _getCachedSuratAll();

    try {
      final result = await _safeCall(() => service.getAllSurat(token));
      _validateStatus(result);
      final items = _mapSuratList(result['data']);
      await _cache.cacheSuratAllList(items);
      return items;
    } catch (e) {
      final cached = await _getCachedSuratAll();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<PengajuanSurat>> getSuratSaya() async {
    final token = await local.getToken();
    if (token == null) return _getCachedSuratSaya();
    if (await ConnectivityHelper.isOffline()) return _getCachedSuratSaya();

    try {
      final result = await _safeCall(() => service.getSuratSaya(token));
      _validateStatus(result);
      final items = _mapSuratList(result['data']);
      await _cache.cacheSuratSayaList(items);
      return items;
    } catch (e) {
      final cached = await _getCachedSuratSaya();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<PengajuanSurat?> getSuratById(int id) async {
    final token = await local.getToken();
    if (token == null) return _getCachedSuratById(id);
    if (await ConnectivityHelper.isOffline()) return _getCachedSuratById(id);

    try {
      final result = await _safeCall(() => service.getSuratById(id, token));
      _validateStatus(result);
      final data = result['data'];
      if (data == null) return null;
      final surat = PengajuanSurat.fromJson(Map<String, dynamic>.from(data));
      await _cache.upsertSuratAllRaw(surat.toJson());
      return surat;
    } catch (e) {
      final cached = await _getCachedSuratById(id);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<List<PengajuanSurat>> getSuratByRt(int rtId) async {
    final token = await local.getToken();
    if (token == null) return _getCachedSuratByRt(rtId);
    if (await ConnectivityHelper.isOffline()) return _getCachedSuratByRt(rtId);

    try {
      final result = await _safeCall(() => service.getSuratByRt(rtId, token));
      _validateStatus(result);
      final items = _mapSuratList(result['data']);
      await _cache.cacheSuratAllList(items);
      await _cache.cacheSuratRtList(rtId, items);
      return items;
    } catch (e) {
      final cached = await _getCachedSuratByRt(rtId);
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<PengajuanSurat>> getSuratByRw(int rwId) async {
    final token = await local.getToken();
    if (token == null) return _getCachedSuratByRw(rwId);
    if (await ConnectivityHelper.isOffline()) return _getCachedSuratByRw(rwId);

    try {
      final result = await _safeCall(() => service.getSuratByRw(rwId, token));
      _validateStatus(result);
      final items = _mapSuratList(result['data']);
      await _cache.cacheSuratAllList(items);
      await _cache.cacheSuratRwList(rwId, items);
      return items;
    } catch (e) {
      final cached = await _getCachedSuratByRw(rwId);
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  // ── Write Methods (online-only) ────────────────────────────────

  Future<bool> createSurat(PengajuanSurat surat) async {
    final token = await _requireToken();
    _requireOnline();

    final result = await _safeCall(
      () => service.createSurat(surat.toJson(), token),
    );
    _validateStatus(result);

    final created = _normalizeCreatedSurat(result['data'], fallback: surat);
    await _cache.upsertSuratAllRaw(created.toJson());
    await _cache.upsertSuratSayaRaw(created.toJson());
    return true;
  }

  Future<void> updateSurat(int id, Map<String, dynamic> data) async {
    final token = await _requireToken();
    _requireOnline();

    final result = await _safeCall(
      () => service.updateSurat(id, data, token),
    );
    _validateStatus(result);

    final current = await _getCachedSuratMapById(id) ?? {'id': id};
    final merged = Map<String, dynamic>.from(current)..addAll(data)..['id'] = id;
    await _cache.upsertSuratAllRaw(merged);
    if (current['warga_id'] != null || data['warga_id'] != null) {
      await _cache.upsertSuratSayaRaw(merged);
    }
  }

  Future<void> deleteSurat(int id) async {
    final token = await _requireToken();
    _requireOnline();

    final result = await _safeCall(() => service.deleteSurat(id, token));
    _validateStatus(result);

    await _cache.removeSuratAll(id);
    await _cache.removeSuratSaya(id);
  }

  // ── File Upload ────────────────────────────────────────────────

  Future<String> uploadFile(File file, {required String folder}) async {
    _requireOnline();
    final url = await _cloudinary.uploadFile(file, folder: folder);
    if (url == null) throw Exception('Upload file gagal');
    return url;
  }

  // ── Helpers ────────────────────────────────────────────────────

  Future<String> _requireToken() async {
    final token = await local.getToken();
    if (token == null) throw Exception('Token tidak ditemukan. Silakan login ulang.');
    return token;
  }

  void _requireOnline() {
    if (ConnectivityHelper.isLastKnownOffline) {
      throw Exception('Tidak dapat melakukan aksi ini saat offline');
    }
  }

  Future<int?> resolveSuratUploadId(int id) async {
    final raw = await _getCachedSuratMapById(id);
    final serverId = (raw?['id'] as num?)?.toInt();
    if (serverId == null || serverId <= 0) return null;
    return serverId;
  }

  Future<Map<String, dynamic>?> _getCachedSuratMapById(int id) async {
    final allItems = await _cache.readSuratAllRaw();
    for (final item in allItems) {
      if (_matchesSuratId(item, id)) return item;
    }
    final sayaItems = await _cache.readSuratSayaRaw();
    for (final item in sayaItems) {
      if (_matchesSuratId(item, id)) return item;
    }
    return null;
  }

  bool _matchesSuratId(Map<String, dynamic> item, int id) {
    final itemId = (item['id'] as num?)?.toInt();
    final tempId = (item['client_temp_id'] as num?)?.toInt();
    return itemId == id || tempId == id;
  }

  List<PengajuanSurat> _mapSuratList(dynamic data) {
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((item) => PengajuanSurat.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  PengajuanSurat _normalizeCreatedSurat(
    dynamic data, {
    required PengajuanSurat fallback,
  }) {
    final raw = data is Map
        ? Map<String, dynamic>.from(data)
        : fallback.toJson();

    raw['warga_id'] ??= fallback.wargaId;
    raw['rt_id'] ??= fallback.rtId;
    raw['keperluan'] ??= fallback.keperluan;
    raw['keterangan'] ??= fallback.keterangan;
    raw['status'] ??= fallback.status.value;
    raw['doc_referensi'] ??= fallback.docRef;
    raw['catatan'] ??= fallback.catatan;
    raw['disetujui_oleh'] ??= fallback.disetujuiOleh;
    raw['waktu_disetujui'] ??= fallback.waktuDisetujui?.toIso8601String();
    raw['is_signed'] ??= fallback.isSigned;
    raw['waktu_dibuat'] ??= fallback.waktuDibuat?.toIso8601String();
    raw['waktu_diubah'] ??= fallback.waktuDiubah?.toIso8601String();
    raw['waktu_dihapus'] ??= fallback.waktuDihapus?.toIso8601String();

    return PengajuanSurat.fromJson(raw);
  }

  // ── Cache Reads ────────────────────────────────────────────────

  Future<List<PengajuanSurat>> _getCachedSuratAll() async {
    return _mapSuratList(await _cache.readSuratAllRaw());
  }

  Future<List<PengajuanSurat>> _getCachedSuratSaya() async {
    return _mapSuratList(await _cache.readSuratSayaRaw());
  }

  Future<List<PengajuanSurat>> _getCachedSuratByRt(int rtId) async {
    return _mapSuratList(await _cache.readSuratRtRaw(rtId));
  }

  Future<List<PengajuanSurat>> _getCachedSuratByRw(int rwId) async {
    return _mapSuratList(await _cache.readSuratRwRaw(rwId));
  }

  Future<PengajuanSurat?> _getCachedSuratById(int id) async {
    final raw = await _getCachedSuratMapById(id);
    if (raw == null) return null;
    return PengajuanSurat.fromJson(raw);
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
