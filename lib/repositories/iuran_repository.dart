import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/models/iuran/iuransaya_model.dart';
import 'package:rukun_app_proyek4/models/iuran/rw/iuran_detail_rw_model.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_iuran_service.dart';
import 'package:rukun_app_proyek4/services/local/local_iuran_cache_service.dart';
import 'package:rukun_app_proyek4/services/local/local_iuran_sync_service.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';
import 'package:rukun_app_proyek4/services/utils/hive_service.dart';
import 'package:rukun_app_proyek4/utils/hive_cast_utils.dart';
import 'package:rukun_app_proyek4/utils/connectivity_helper.dart';

class IuranRepository {
  final CloudIuranService service;
  final AuthLocalService local;
  final CloudinaryService? cloudinary;

  IuranRepository(this.service, this.local, [this.cloudinary]);

  final IuranLocalCacheService cache = IuranLocalCacheService();
  final IuranLocalSyncService syncQueue = IuranLocalSyncService();

  Future<List<Iuran>> getAllIuran() async {
    final token = await local.getToken();

    if (token == null) {
      return _getCachedIuran();
    }

    if (await ConnectivityHelper.isOffline()) {
      return _getCachedIuran();
    }

    try {
      await _syncPendingIuran(token);

      final result = await _safeCall(() => service.getAllIuran(token));

      _validateStatus(result);

      final List data = result['data'] ?? [];

      final rawItems = data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      await cache.cacheIuranRawList(rawItems);

      return rawItems.map(Iuran.fromJson).toList();
    } catch (e) {
      final cached = await _getCachedIuran();
      if (cached.isNotEmpty) {
        return cached;
      }

      rethrow;
    }
  }

  Future<List<IuranSaya>> getIuranSaya() async {
    final token = await _requireToken();

    try {
      final result = await _safeCall(() => service.getIuranSaya(token));

      _validateStatus(result);

      final List data = result['data'] ?? [];
      final items = data.map((e) => IuranSaya.fromJson(e)).toList();
      await _cacheIuranSayaRaw(data);
      return items;
    } catch (e) {
      if (_canUseCache(e)) {
        return _getCachedIuranSaya();
      }
      rethrow;
    }
  }

  static const String _iuranSayaCacheBox = 'offline_cache_iuran_saya';

  Future<void> _cacheIuranSayaRaw(List<dynamic> data) async {
    final box = await HiveService().openBox<dynamic>(_iuranSayaCacheBox);
    await box.put('all', data);
  }

  Future<List<IuranSaya>> _getCachedIuranSaya() async {
    final box = await HiveService().openBox<dynamic>(_iuranSayaCacheBox);
    final raw = box.get('all');
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => IuranSaya.fromJson(deepCastMap(e)))
          .toList();
    }
    return [];
  }

  Future<Iuran?> getIuranById(int id) async {
    try {
      final token = await _requireToken();
      await _syncPendingIuran(token);

      final result = await _safeCall(() => service.getIuranById(id, token));

      _validateStatus(result);

      final data = result['data'];

      if (data == null) return null;

      final raw = Map<String, dynamic>.from(data as Map);
      await cache.upsertIuranRaw(raw);

      return Iuran.fromJson(raw);
    } catch (e) {
      final cached = await _getCachedIuranById(id);
      if (cached != null) return cached;

      rethrow;
    }
  }

  Future<void> createIuran(Iuran iuran) async {
    if (await ConnectivityHelper.isOffline()) {
      await _createIuranOffline(iuran);
      return;
    }

    try {
      final token = await _requireToken();
      await _syncPendingIuran(token);

      final result = await _safeCall(
        () => service.createIuran(iuran.toJson(), token),
      );

      _validateStatus(result);

      final data = result['data'];
      if (data is Map) {
        await cache.upsertIuranRaw(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      await _createIuranOffline(iuran);
    }
  }

  Future<void> updateIuran(int id, Iuran iuran) async {
    if (await ConnectivityHelper.isOffline()) {
      await _updateIuranOffline(id, iuran);
      return;
    }

    try {
      final token = await _requireToken();
      await _syncPendingIuran(token);

      final result = await _safeCall(
        () => service.updateIuran(id, iuran.toJson(), token),
      );

      _validateStatus(result);

      final data = result['data'];
      if (data is Map) {
        await cache.upsertIuranRaw(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      await _updateIuranOffline(id, iuran);
    }
  }

  Future<void> updateStatusTransaksi(int id, Map<String, dynamic> data) async {
    final token = await _requireToken();

    final result = await _safeCall(
      () => service.updateStatusTransaksi(id, data, token),
    );

    _validateStatus(result);
  }

  Future<void> deleteIuran(int id) async {
    if (await ConnectivityHelper.isOffline()) {
      await _deleteIuranOffline(id);
      return;
    }

    try {
      final token = await _requireToken();
      await _syncPendingIuran(token);

      final result = await _safeCall(() => service.deleteIuran(id, token));

      _validateStatus(result);

      await cache.removeIuran(id);
    } catch (e) {
      await _deleteIuranOffline(id);
    }
  }

  Future<List<Iuran>> _getCachedIuran() async {
    final raw = await cache.readIuranRaw();
    return raw.map(Iuran.fromJson).toList();
  }

  Future<Iuran?> _getCachedIuranById(int id) async {
    final raw = await cache.readIuranRaw();
    for (final item in raw) {
      if ((item['id'] as num?)?.toInt() == id) {
        return Iuran.fromJson(item);
      }
    }

    return null;
  }

  Future<void> _createIuranOffline(Iuran iuran) async {
    final tempId = -DateTime.now().microsecondsSinceEpoch;
    final raw = _prepareOfflinePayload(iuran.toJson(), tempId);

    await cache.upsertIuranRaw(raw);

    final rwId = iuran.rw?.id;
    if (rwId != null) {
      await cache.upsertIuranRwRaw(rwId, raw);
    }

    await syncQueue.queueCreateIuran(tempId: tempId, payload: raw);
  }

  Future<void> _updateIuranOffline(int id, Iuran iuran) async {
    final raw = _prepareOfflinePayload({...iuran.toJson(), 'id': id}, id);

    await cache.upsertIuranRaw(raw);
    await syncQueue.queueUpdateIuran(entityId: id, payload: raw);
  }

  Future<void> _deleteIuranOffline(int id) async {
    await cache.removeIuran(id);
    await syncQueue.queueDeleteIuran(entityId: id);
  }

  Future<void> _syncPendingIuran(String token) async {
    final pending = await syncQueue.readPendingActions();
    if (pending.isEmpty) return;

    final tempIdMap = <int, int>{};

    for (final action in pending) {
      if (action['entity'] == 'transaksi') {
        await _syncTransaksiAction(action, token);
        continue;
      }

      if (action['entity'] != 'iuran') continue;

      final queueId = action['queue_id'] as String?;
      if (queueId == null) continue;

      final operation = action['operation'] as String?;
      final entityId = (action['entity_id'] as num?)?.toInt();
      if (entityId == null) continue;

      final payload = Map<String, dynamic>.from(
        (action['payload'] as Map?)?.cast<String, dynamic>() ?? {},
      );

      try {
        if (operation == 'create') {
          final cleanPayload = _stripSyncFields(payload)..remove('id');

          final result = await _safeCall(
            () => service.createIuran(cleanPayload, token),
          );
          _validateStatus(result);

          final data = result['data'];
          if (data is Map) {
            final serverRaw = Map<String, dynamic>.from(data);
            await cache.removeIuran(entityId);
            await cache.upsertIuranRaw(serverRaw);

            final serverId = (serverRaw['id'] as num?)?.toInt();
            if (serverId != null) tempIdMap[entityId] = serverId;
          }

          await syncQueue.removeAction(queueId);
          continue;
        }

        final targetId = tempIdMap[entityId] ?? entityId;

        if (operation == 'update') {
          final cleanPayload = _stripSyncFields(payload)..remove('id');
          final result = await _safeCall(
            () => service.updateIuran(
              targetId,
              Iuran.fromJson({...cleanPayload, 'id': targetId}).toJson(),
              token,
            ),
          );
          _validateStatus(result);

          final data = result['data'];
          if (data is Map) {
            await cache.upsertIuranRaw(Map<String, dynamic>.from(data));
          } else {
            await cache.upsertIuranRaw({...cleanPayload, 'id': targetId});
          }

          await syncQueue.removeAction(queueId);
          continue;
        }

        if (operation == 'delete') {
          final result = await _safeCall(
            () => service.deleteIuran(targetId, token),
          );
          _validateStatus(result);
          await cache.removeIuran(targetId);
          await syncQueue.removeAction(queueId);
        }
      } catch (e) {
        try {
          final currentAttempts = (action['attempts'] as int?) ?? 0;
          final nextAttempts = currentAttempts + 1;
          if (nextAttempts >= 3) {
            await syncQueue.removeAction(queueId);
            debugPrint(
              'Iuran queue $queueId failed permanently after $nextAttempts attempts',
            );
          } else {
            await syncQueue.updateActionAttempts(queueId, nextAttempts);
            debugPrint(
              'Iuran queue $queueId will retry later (attempt $nextAttempts)',
            );
          }
        } catch (_) {}
        continue;
      }
    }
  }

  Future<void> _syncTransaksiAction(
    Map<String, dynamic> action,
    String token,
  ) async {
    final queueId = action['queue_id'] as String?;
    if (queueId == null) return;

    final operation = action['operation'] as String?;
    if (operation != 'transaksi_create') return;

    final payload = Map<String, dynamic>.from(
      (action['payload'] as Map?)?.cast<String, dynamic>() ?? {},
    );

    try {
      final localPath = payload['_local_file_path'] as String?;
      String? imageUrl;

      if (localPath != null && cloudinary != null) {
        final file = File(localPath);
        if (await file.exists()) {
          imageUrl = await cloudinary!.uploadFile(file, folder: 'bukti_iuran');
          if (imageUrl == null) {
            debugPrint('Transaksi sync: upload bukti failed, will retry');
            throw Exception('Upload bukti gagal');
          }
        }
      }

      final cleanPayload = _stripSyncFields(payload)..remove('id');
      if (imageUrl != null) {
        cleanPayload['img_referensi'] = imageUrl;
      }

      final result = await _safeCall(
        () => service.createTransaksi(cleanPayload, token),
      );
      _validateStatus(result);

      await syncQueue.removeAction(queueId);
      debugPrint('Transaksi sync success for $queueId');
    } catch (e) {
      try {
        final currentAttempts = (action['attempts'] as int?) ?? 0;
        final nextAttempts = currentAttempts + 1;
        if (nextAttempts >= 3) {
          await syncQueue.removeAction(queueId);
          debugPrint(
            'Transaksi queue $queueId failed permanently after $nextAttempts attempts',
          );
        } else {
          await syncQueue.updateActionAttempts(queueId, nextAttempts);
          debugPrint(
            'Transaksi queue $queueId will retry later (attempt $nextAttempts)',
          );
        }
      } catch (_) {}
    }
  }

  /// Public wrapper to trigger pending sync from outside (e.g., SyncCoordinator).
  Future<void> syncPending() async {
    final token = await _requireToken();
    await _syncPendingIuran(token);
  }

  Map<String, dynamic> _prepareOfflinePayload(
    Map<String, dynamic> raw,
    int id,
  ) {
    return {
      ...raw,
      'id': id,
      'sync_status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _stripSyncFields(Map<String, dynamic> raw) {
    final result = Map<String, dynamic>.from(raw);
    result.remove('sync_status');
    result.remove('queue_id');
    result.remove('created_at');
    result.remove('updated_at');
    result.remove('entity');
    result.remove('entity_id');
    result.remove('operation');
    result.remove('local_queue_id');
    result.remove('_sync_operation');
    result.remove('_sync_status');
    result.remove('_created_offline_at');
    result.remove('_local_file_path');
    return result;
  }

  Future<List<Iuran>> getIuranByRWId(int idRw) async {
    if (await ConnectivityHelper.isOffline()) {
      final cached = await cache.readIuranRwRaw(idRw);
      if (cached.isNotEmpty) {
        final items = cached.map(Iuran.fromJson).toList();
        final pendingItems = await _getPendingIuranForRw(idRw);
        if (pendingItems.isNotEmpty) {
          final existingIds = items.map((e) => e.id).toSet();
          for (final pending in pendingItems) {
            if (!existingIds.contains(pending.id)) {
              items.add(pending);
            }
          }
        }
        return items;
      }

      final allCached = await cache.readIuranRaw();
      final filtered = allCached
          .where((item) => (item['rw_id'] as num?)?.toInt() == idRw)
          .map(Iuran.fromJson)
          .toList();

      final pendingItems = await _getPendingIuranForRw(idRw);
      if (pendingItems.isNotEmpty) {
        final existingIds = filtered.map((e) => e.id).toSet();
        for (final pending in pendingItems) {
          if (!existingIds.contains(pending.id)) {
            filtered.add(pending);
          }
        }
      }

      return filtered;
    }

    final token = await _requireToken();

    try {
      await _syncPendingIuran(token);
    } catch (_) {}

    final result = await _safeCall(() => service.getIuranByRW(idRw, token));

    _validateStatus(result);

    final List data = result['data'] ?? [];
    final items = data.map((e) => Iuran.fromJson(e)).toList();
    await cache.cacheIuranRwList(idRw, items);

    final pendingItems = await _getPendingIuranForRw(idRw);
    if (pendingItems.isNotEmpty) {
      final existingIds = items.map((e) => e.id).toSet();
      for (final pending in pendingItems) {
        if (!existingIds.contains(pending.id)) {
          items.add(pending);
        }
      }
      await cache.cacheIuranRwList(idRw, items);
    }

    return items;
  }

  Future<List<Iuran>> _getPendingIuranForRw(int rwId) async {
    final pending = await syncQueue.readPendingActions();
    final results = <Iuran>[];

    for (final action in pending) {
      if (action['entity'] != 'iuran') continue;
      if (action['operation'] != 'create') continue;

      final payload = action['payload'] as Map?;
      if (payload == null) continue;

      final raw = Map<String, dynamic>.from(payload);
      if ((raw['rw_id'] as num?)?.toInt() != rwId) continue;

      results.add(Iuran.fromJson(raw));
    }

    return results;
  }

  Future<IuranRWDetail> getIuranRWDetail(int id) async {
    final token = await _requireToken();

    if (await ConnectivityHelper.isOffline()) {
      throw Exception('Tidak dapat memuat detail iuran saat offline');
    }

    final result = await _safeCall(
      () => service.getIuranDetailWithRT(id, token),
    );

    _validateStatus(result);

    final data = result['data'];

    if (data == null) {
      throw Exception("Data tidak ditemukan");
    }

    return IuranRWDetail.fromJson(data);
  }

  Future<void> createTransaksi(
    Transaksi transaksi, {
    String? localFilePath,
  }) async {
    try {
      final token = await _requireToken();

      final result = await _safeCall(
        () => service.createTransaksi(transaksi.toJson(), token),
      );

      _validateStatus(result);
    } catch (e) {
      await _createTransaksiOffline(transaksi, localFilePath: localFilePath);
    }
  }

  Future<void> _createTransaksiOffline(
    Transaksi transaksi, {
    String? localFilePath,
  }) async {
    final tempId = -DateTime.now().microsecondsSinceEpoch;
    final raw = transaksi.toJson();
    raw['id'] = tempId;
    raw['_sync_operation'] = 'transaksi_create';
    raw['_sync_status'] = 'pending';
    raw['_created_offline_at'] = DateTime.now().toIso8601String();
    if (localFilePath != null) {
      raw['_local_file_path'] = localFilePath;
    }

    await syncQueue.queueCreateTransaksi(
      tempId: tempId,
      payload: raw,
    );
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
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _validateStatus(Map<String, dynamic> res) {
    if (res["status"] != "success") {
      throw Exception(res["message"] ?? "Unknown error");
    }
  }

  bool _canUseCache(Object error) {
    if (error is DioException) {
      return switch (error.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.unknown => true,
        _ => false,
      };
    }

    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('connection refused') ||
        message.contains('network is unreachable');
  }
}
