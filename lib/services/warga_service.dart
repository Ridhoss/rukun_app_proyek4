import 'package:rukun_app_proyek4/models/keluarga.dart';
import 'package:rukun_app_proyek4/models/warga.dart';
import 'package:rukun_app_proyek4/services/hive_service.dart';
import 'package:rukun_app_proyek4/services/local/local_warga_service.dart';
import 'package:rukun_app_proyek4/services/session_context_service.dart';

// =============================================================
// warga_service.dart
// Offline-first service untuk input KK/Warga oleh pengurus RT.
// =============================================================

class WargaService {
  // Singleton
  static final WargaService _instance = WargaService._internal();
  factory WargaService() => _instance;
  WargaService._internal();

  static const String _kkBox = 'keluarga_offline';
  static const String _metaBox = 'metadata_offline';
  static const String _syncQueueBox = 'sync_queue_offline';

  int _currentRtId = 1;
  String _currentRtLabel = 'RT 001';
  bool _contextLoaded = false;
  final SessionContextService _sessionContextService = SessionContextService();
  final LocalWargaService _localWargaService = LocalWargaService();

  int? lastSavedKKId;
  String? lastError;

  int get currentRtId => _currentRtId;
  String get currentRtLabel => _currentRtLabel;

  Future<void> warmUpRTContext() async {
    await _ensureContextLoaded();
  }

  Future<void> _ensureContextLoaded() async {
    if (_contextLoaded) {
      return;
    }

    final context = await _sessionContextService.getRTContext();
    _currentRtId = context.rtId;
    _currentRtLabel = context.rtLabel;
    _contextLoaded = true;
  }

  Future<void> setCurrentRTContext({required int rtId, String? rtLabel}) async {
    _currentRtId = rtId;
    _currentRtLabel = rtLabel ?? 'RT ${rtId.toString().padLeft(3, '0')}';
    _contextLoaded = true;
    await _sessionContextService.setRTContext(
      rtId: _currentRtId,
      rtLabel: _currentRtLabel,
    );
  }

  Future<int> _nextId(String sequenceKey) async {
    final box = await HiveService().openBox<dynamic>(_metaBox);
    final current = (box.get(sequenceKey) as int?) ?? 0;
    final next = current + 1;
    await box.put(sequenceKey, next);
    return next;
  }

  Future<void> _enqueueSync({
    required String entity,
    required String operation,
    required int entityId,
    required Map<String, dynamic> payload,
  }) async {
    final queue = await HiveService().openBox<dynamic>(_syncQueueBox);
    final queueId = await _nextId('seq.sync_queue');
    await queue.put(queueId, {
      'id': queueId,
      'entity': entity,
      'operation': operation,
      'entity_id': entityId,
      'payload': payload,
      'sync_status': 'pending',
      'retry_count': 0,
      'last_error': null,
      'attempted_at': null,
      'next_retry_at': null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Duration _retryBackoff(int retryCount) {
    if (retryCount <= 1) {
      return const Duration(minutes: 1);
    }
    if (retryCount == 2) {
      return const Duration(minutes: 5);
    }
    if (retryCount == 3) {
      return const Duration(minutes: 15);
    }
    if (retryCount == 4) {
      return const Duration(minutes: 30);
    }
    return const Duration(minutes: 60);
  }

  Future<bool> markSyncProcessing(int queueId) async {
    final queue = await HiveService().openBox<dynamic>(_syncQueueBox);
    final raw = queue.get(queueId);
    if (raw is! Map) {
      return false;
    }

    final updated = {
      ...Map<String, dynamic>.from(raw),
      'sync_status': 'processing',
      'attempted_at': DateTime.now().toIso8601String(),
    };
    await queue.put(queueId, updated);
    return true;
  }

  Future<bool> markSyncSuccess(int queueId) async {
    final queue = await HiveService().openBox<dynamic>(_syncQueueBox);
    final raw = queue.get(queueId);
    if (raw is! Map) {
      return false;
    }

    final updated = {
      ...Map<String, dynamic>.from(raw),
      'sync_status': 'synced',
      'attempted_at': DateTime.now().toIso8601String(),
      'next_retry_at': null,
      'last_error': null,
    };
    await queue.put(queueId, updated);
    return true;
  }

  Future<bool> markSyncFailed(int queueId, {required String error}) async {
    final queue = await HiveService().openBox<dynamic>(_syncQueueBox);
    final raw = queue.get(queueId);
    if (raw is! Map) {
      return false;
    }

    final currentRetry = ((raw['retry_count'] as num?)?.toInt() ?? 0) + 1;
    final now = DateTime.now();
    final nextRetryAt = now.add(_retryBackoff(currentRetry));

    final updated = {
      ...Map<String, dynamic>.from(raw),
      'sync_status': 'failed',
      'retry_count': currentRetry,
      'last_error': error,
      'attempted_at': now.toIso8601String(),
      'next_retry_at': nextRetryAt.toIso8601String(),
    };
    await queue.put(queueId, updated);
    return true;
  }

  /// Paksa item antrean kembali retry sekarang (tanpa menambah retry_count).
  Future<bool> forceRetryQueueItem(int queueId) async {
    final queue = await HiveService().openBox<dynamic>(_syncQueueBox);
    final raw = queue.get(queueId);
    if (raw is! Map) {
      return false;
    }

    final updated = {
      ...Map<String, dynamic>.from(raw),
      'sync_status': 'pending',
      'next_retry_at': null,
      'last_error': null,
    };
    await queue.put(queueId, updated);
    return true;
  }

  /// Kembalikan item yang terlalu lama di status processing agar bisa dicoba ulang.
  Future<int> resetStaleProcessingQueue({
    Duration olderThan = const Duration(minutes: 5),
  }) async {
    final queue = await HiveService().openBox<dynamic>(_syncQueueBox);
    final threshold = DateTime.now().subtract(olderThan);
    int affected = 0;

    for (final key in queue.keys) {
      final raw = queue.get(key);
      if (raw is! Map) {
        continue;
      }

      final item = Map<String, dynamic>.from(raw);
      if ((item['sync_status'] ?? '').toString() != 'processing') {
        continue;
      }

      final attemptedRaw = item['attempted_at'] as String?;
      final attemptedAt = attemptedRaw == null
          ? null
          : DateTime.tryParse(attemptedRaw);
      if (attemptedAt != null && attemptedAt.isAfter(threshold)) {
        continue;
      }

      final updated = {
        ...item,
        'sync_status': 'failed',
        'last_error': 'Recovered stale processing item',
        'next_retry_at': DateTime.now().toIso8601String(),
      };
      await queue.put(key, updated);
      affected += 1;
    }

    return affected;
  }

  /// Hapus item synced yang sudah lama agar ukuran queue tetap terjaga.
  Future<int> purgeSyncedQueue({
    Duration olderThan = const Duration(days: 7),
    int? limit,
  }) async {
    final queue = await HiveService().openBox<dynamic>(_syncQueueBox);
    final threshold = DateTime.now().subtract(olderThan);
    int removed = 0;

    for (final key in queue.keys) {
      if (limit != null && limit > 0 && removed >= limit) {
        break;
      }

      final raw = queue.get(key);
      if (raw is! Map) {
        continue;
      }

      final item = Map<String, dynamic>.from(raw);
      if ((item['sync_status'] ?? '').toString() != 'synced') {
        continue;
      }

      final attemptedRaw = item['attempted_at'] as String?;
      final createdRaw = item['created_at'] as String?;
      final baselineTime =
          DateTime.tryParse(attemptedRaw ?? '') ??
          DateTime.tryParse(createdRaw ?? '');
      if (baselineTime == null || baselineTime.isAfter(threshold)) {
        continue;
      }

      await queue.delete(key);
      removed += 1;
    }

    return removed;
  }

  /// Ambil antrean sinkronisasi yang pending dan sudah waktunya diproses.
  Future<List<Map<String, dynamic>>> getPendingSyncQueue({int? limit}) async {
    final queue = await HiveService().openBox<dynamic>(_syncQueueBox);
    final now = DateTime.now();

    final entries = queue.values
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw))
        .where((item) {
          final status = (item['sync_status'] ?? '').toString();
          if (status != 'pending' && status != 'failed') {
            return false;
          }

          final nextRetryRaw = item['next_retry_at'] as String?;
          if (nextRetryRaw == null || nextRetryRaw.isEmpty) {
            return true;
          }

          final nextRetryAt = DateTime.tryParse(nextRetryRaw);
          if (nextRetryAt == null) {
            return true;
          }

          return !nextRetryAt.isAfter(now);
        })
        .toList();

    entries.sort((a, b) {
      final aId = (a['id'] as num?)?.toInt() ?? 0;
      final bId = (b['id'] as num?)?.toInt() ?? 0;
      return aId.compareTo(bId);
    });

    if (limit == null || limit <= 0) {
      return entries;
    }

    if (entries.length <= limit) {
      return entries;
    }

    return entries.take(limit).toList();
  }

  Future<List<Map<String, dynamic>>> getSyncQueueByStatus(
    String status, {
    int? limit,
  }) async {
    final queue = await HiveService().openBox<dynamic>(_syncQueueBox);
    final entries = queue.values
        .whereType<Map>()
        .map((raw) => Map<String, dynamic>.from(raw))
        .where((item) => (item['sync_status'] ?? '').toString() == status)
        .toList();

    entries.sort((a, b) {
      final aId = (a['id'] as num?)?.toInt() ?? 0;
      final bId = (b['id'] as num?)?.toInt() ?? 0;
      return aId.compareTo(bId);
    });

    if (limit == null || limit <= 0 || entries.length <= limit) {
      return entries;
    }

    return entries.take(limit).toList();
  }

  Future<Map<String, int>> getSyncQueueStats() async {
    final queue = await HiveService().openBox<dynamic>(_syncQueueBox);
    final now = DateTime.now();
    int pending = 0;
    int processing = 0;
    int synced = 0;
    int failed = 0;
    int retryable = 0;

    for (final raw in queue.values.whereType<Map>()) {
      final item = Map<String, dynamic>.from(raw);
      final status = (item['sync_status'] ?? '').toString();

      if (status == 'pending') {
        pending += 1;
      }
      if (status == 'processing') {
        processing += 1;
      }
      if (status == 'synced') {
        synced += 1;
      }
      if (status == 'failed') {
        failed += 1;
      }

      if (status == 'pending' || status == 'failed') {
        final nextRetryRaw = item['next_retry_at'] as String?;
        if (nextRetryRaw == null || nextRetryRaw.isEmpty) {
          retryable += 1;
        } else {
          final nextRetryAt = DateTime.tryParse(nextRetryRaw);
          if (nextRetryAt == null || !nextRetryAt.isAfter(now)) {
            retryable += 1;
          }
        }
      }
    }

    return {
      'total': queue.length,
      'pending': pending,
      'processing': processing,
      'synced': synced,
      'failed': failed,
      'retryable': retryable,
    };
  }

  /// Proses antrean sync yang due dengan callback processor (mis. cloud sender).
  Future<Map<String, int>> processPendingSyncQueue({
    required Future<void> Function(Map<String, dynamic> queueItem) processor,
    int? limit,
  }) async {
    final dueItems = await getPendingSyncQueue(limit: limit);

    int success = 0;
    int failed = 0;
    int skipped = 0;

    for (final item in dueItems) {
      final queueId = (item['id'] as num?)?.toInt();
      if (queueId == null) {
        skipped += 1;
        continue;
      }

      final markedProcessing = await markSyncProcessing(queueId);
      if (!markedProcessing) {
        skipped += 1;
        continue;
      }

      try {
        await processor(item);
        await markSyncSuccess(queueId);
        success += 1;
      } catch (e) {
        await markSyncFailed(queueId, error: e.toString());
        failed += 1;
      }
    }

    return {
      'picked': dueItems.length,
      'success': success,
      'failed': failed,
      'skipped': skipped,
    };
  }

  // ─────────────────────────────────────────────
  // KK (Keluarga) Methods
  // ─────────────────────────────────────────────

  /// Simpan data KK baru ke Hive lokal dan antri untuk sinkronisasi.
  Future<bool> saveKK(Keluarga kk) async {
    await _ensureContextLoaded();
    lastError = null;
    lastSavedKKId = null;

    if (kk.rtId != _currentRtId) {
      lastError =
          'RT tidak sesuai konteks login. Anda hanya bisa input RT aktif.';
      return false;
    }

    final kkBox = await HiveService().openBox<dynamic>(_kkBox);
    final noKKNormalized = kk.noKK.trim();

    final exists = kkBox.values.whereType<Map>().any((raw) {
      final sameNoKK =
          ((raw['no_kk'] ?? '') as String).trim() == noKKNormalized;
      final notDeleted = (raw['is_deleted'] as bool?) != true;
      return sameNoKK && notDeleted;
    });
    if (exists) {
      lastError = 'No. KK sudah terdaftar.';
      return false;
    }

    final id = await _nextId('seq.keluarga');
    final payload = {
      'id': id,
      'no_kk': noKKNormalized,
      'rt_id': kk.rtId,
      'alamat': kk.alamat.trim(),
      'sync_status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': false,
    };

    await kkBox.put(id, payload);
    await _enqueueSync(
      entity: 'keluarga',
      operation: 'create',
      entityId: id,
      payload: payload,
    );

    lastSavedKKId = id;
    return true;
  }

  /// Ambil semua KK berdasarkan RT dari storage lokal.
  Future<List<Keluarga>> getKKByRT(int rtId) async {
    await _ensureContextLoaded();
    final kkBox = await HiveService().openBox<dynamic>(_kkBox);
    final result = kkBox.values
        .whereType<Map>()
        .where(
          (row) =>
              (row['rt_id'] as num?)?.toInt() == rtId &&
              (row['is_deleted'] as bool?) != true,
        )
        .map(Keluarga.fromMap)
        .toList();

    result.sort((a, b) => b.id!.compareTo(a.id!));
    return result;
  }

  /// Update data KK lokal.
  Future<bool> updateKK(String id, Keluarga kk) async {
    await _ensureContextLoaded();
    lastError = null;
    final kkId = int.tryParse(id);
    if (kkId == null) {
      lastError = 'ID KK tidak valid.';
      return false;
    }

    final kkBox = await HiveService().openBox<dynamic>(_kkBox);
    final raw = kkBox.get(kkId);
    if (raw is! Map) {
      lastError = 'Data KK tidak ditemukan.';
      return false;
    }

    if ((raw['rt_id'] as num).toInt() != _currentRtId ||
        kk.rtId != _currentRtId) {
      lastError = 'Anda tidak memiliki akses mengubah KK di RT lain.';
      return false;
    }

    final noKKNormalized = kk.noKK.trim();
    final duplicate = kkBox.values.whereType<Map>().any((row) {
      final rowId = (row['id'] as num?)?.toInt();
      final sameNoKK =
          ((row['no_kk'] ?? '') as String).trim() == noKKNormalized;
      final notDeleted = (row['is_deleted'] as bool?) != true;
      return rowId != kkId && sameNoKK && notDeleted;
    });
    if (duplicate) {
      lastError = 'No. KK sudah dipakai oleh keluarga lain.';
      return false;
    }

    final updated = {
      ...Map<String, dynamic>.from(raw),
      'no_kk': noKKNormalized,
      'rt_id': kk.rtId,
      'alamat': kk.alamat.trim(),
      'sync_status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    };

    await kkBox.put(kkId, updated);
    await _enqueueSync(
      entity: 'keluarga',
      operation: 'update',
      entityId: kkId,
      payload: updated,
    );

    return true;
  }

  // ─────────────────────────────────────────────
  // Warga Methods
  // ─────────────────────────────────────────────

  /// Simpan data warga baru ke Hive lokal dan antri sinkronisasi.
  Future<bool> saveWarga(WargaModel warga) async {
    await _ensureContextLoaded();
    lastError = null;
    final id = await _nextId('seq.warga');
    final writeResult = await _localWargaService.saveWarga(
      wargaData: warga.toMap(),
      currentRtId: _currentRtId,
      newWargaId: id,
    );

    if (!writeResult.success) {
      lastError = writeResult.error;
      return false;
    }

    await _enqueueSync(
      entity: 'warga',
      operation: 'create',
      entityId: writeResult.entityId!,
      payload: writeResult.payload!,
    );

    return true;
  }

  /// Ambil semua warga berdasarkan keluarga_id dari storage lokal.
  Future<List<WargaModel>> getWargaByKK(int kkId) async {
    await _ensureContextLoaded();
    final result = await _localWargaService.getWargaByKK(kkId);

    final mapped = result.map(WargaModel.fromMap).toList();

    mapped.sort((a, b) => b.id!.compareTo(a.id!));
    return mapped;
  }

  /// Update warga lokal dengan validasi NIK unik.
  Future<bool> updateWarga(String id, WargaModel warga) async {
    await _ensureContextLoaded();
    lastError = null;
    final writeResult = await _localWargaService.updateWarga(
      id: id,
      wargaData: warga.toMap(),
      currentRtId: _currentRtId,
    );

    if (!writeResult.success) {
      lastError = writeResult.error;
      return false;
    }

    await _enqueueSync(
      entity: 'warga',
      operation: 'update',
      entityId: writeResult.entityId!,
      payload: writeResult.payload!,
    );

    return true;
  }

  /// Hapus warga (soft delete) di storage lokal.
  Future<bool> deleteWarga(String id) async {
    await _ensureContextLoaded();
    lastError = null;
    final writeResult = await _localWargaService.deleteWarga(id);

    if (!writeResult.success) {
      lastError = writeResult.error;
      return false;
    }

    await _enqueueSync(
      entity: 'warga',
      operation: 'delete',
      entityId: writeResult.entityId!,
      payload: writeResult.payload!,
    );

    return true;
  }

  Future<bool> deleteKK(String id) async {
    await _ensureContextLoaded();
    lastError = null;
    final kkId = int.tryParse(id);

    final kkBox = await HiveService().openBox<dynamic>(_kkBox);
    final raw = kkBox.get(kkId);

    if (raw is Map) {
      final updated = {
        ...Map<String, dynamic>.from(raw),
        'is_deleted': true,
        'sync_status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      };

      await kkBox.put(kkId, updated);

      await _enqueueSync(
        entity: 'keluarga',
        operation: 'delete',
        entityId: kkId!,
        payload: updated,
      );
      return true;
    }
    return false;
  }

  // ─────────────────────────────────────────────
  // RT List (untuk dropdown)
  // ─────────────────────────────────────────────

  /// Ambil daftar RT dalam konteks sesi pengurus RT aktif.
  Future<List<Map<String, dynamic>>> getRTList() async {
    await _ensureContextLoaded();
    return [
      {'id': _currentRtId, 'no_rt': _currentRtId, 'name': _currentRtLabel},
    ];
  }
}
