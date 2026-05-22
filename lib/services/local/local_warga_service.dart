import 'package:rukun_app_proyek4/services/utils/hive_service.dart';

class LocalWargaWriteResult {
  final bool success;
  final String? error;
  final int? entityId;
  final Map<String, dynamic>? payload;

  const LocalWargaWriteResult({
    required this.success,
    this.error,
    this.entityId,
    this.payload,
  });
}

class LocalWargaService {
  static const String _kkBox = 'keluarga_offline';
  static const String _wargaBox = 'warga_offline';

  Future<LocalWargaWriteResult> saveWarga({
    required Map<String, dynamic> wargaData,
    required int currentRtId,
    required int newWargaId,
  }) async {
    final keluargaId = (wargaData['keluarga_id'] as num?)?.toInt();
    if (keluargaId == null) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'Keluarga wajib dipilih sebelum menambah warga.',
      );
    }

    final kkBox = await HiveService().openBox<dynamic>(_kkBox);
    final keluargaRaw = kkBox.get(keluargaId);
    if (keluargaRaw is! Map) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'Data keluarga tidak ditemukan.',
      );
    }

    if ((keluargaRaw['rt_id'] as num).toInt() != currentRtId) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'Anda tidak bisa menambah warga di KK milik RT lain.',
      );
    }

    final wargaBox = await HiveService().openBox<dynamic>(_wargaBox);
    final nikNormalized = ((wargaData['nik'] ?? '') as String).trim();
    final duplicateNik = wargaBox.values.whereType<Map>().any((row) {
      final sameNik = ((row['nik'] ?? '') as String).trim() == nikNormalized;
      final notDeleted = (row['is_deleted'] as bool?) != true;
      return sameNik && notDeleted;
    });
    if (duplicateNik) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'NIK sudah terdaftar.',
      );
    }

    final payload = {
      ...wargaData,
      'id': newWargaId,
      'nik': nikNormalized,
      'sync_status': 'pending',
      'created_by_user_id': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': false,
    };

    await wargaBox.put(newWargaId, payload);
    return LocalWargaWriteResult(
      success: true,
      entityId: newWargaId,
      payload: payload,
    );
  }

  Future<List<Map<dynamic, dynamic>>> getWargaByKK(int kkId) async {
    final wargaBox = await HiveService().openBox<dynamic>(_wargaBox);
    final result = wargaBox.values
        .whereType<Map>()
        .where(
          (row) =>
              (row['keluarga_id'] as num?)?.toInt() == kkId &&
              (row['is_deleted'] as bool?) != true,
        )
        .map((row) => Map<dynamic, dynamic>.from(row))
        .toList();

    result.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return result;
  }

  Future<LocalWargaWriteResult> updateWarga({
    required String id,
    required Map<String, dynamic> wargaData,
    required int currentRtId,
  }) async {
    final wargaId = int.tryParse(id);
    if (wargaId == null) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'ID warga tidak valid.',
      );
    }

    final wargaBox = await HiveService().openBox<dynamic>(_wargaBox);
    final raw = wargaBox.get(wargaId);
    if (raw is! Map) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'Data warga tidak ditemukan.',
      );
    }

    final nikNormalized = ((wargaData['nik'] ?? '') as String).trim();
    final duplicateNik = wargaBox.values.whereType<Map>().any((row) {
      final rowId = (row['id'] as num?)?.toInt();
      final sameNik = ((row['nik'] ?? '') as String).trim() == nikNormalized;
      final notDeleted = (row['is_deleted'] as bool?) != true;
      return rowId != wargaId && sameNik && notDeleted;
    });
    if (duplicateNik) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'NIK sudah dipakai warga lain.',
      );
    }

    final keluargaId = (wargaData['keluarga_id'] as num?)?.toInt();
    if (keluargaId == null) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'Keluarga tidak valid.',
      );
    }

    final kkBox = await HiveService().openBox<dynamic>(_kkBox);
    final keluargaRaw = kkBox.get(keluargaId);
    if (keluargaRaw is! Map ||
        (keluargaRaw['rt_id'] as num).toInt() != currentRtId) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'Anda tidak bisa memindahkan warga ke KK di RT lain.',
      );
    }

    final updated = {
      ...Map<String, dynamic>.from(raw),
      ...wargaData,
      'id': wargaId,
      'nik': nikNormalized,
      'sync_status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    };

    await wargaBox.put(wargaId, updated);
    return LocalWargaWriteResult(
      success: true,
      entityId: wargaId,
      payload: updated,
    );
  }

  Future<LocalWargaWriteResult> deleteWarga(String id) async {
    final wargaId = int.tryParse(id);
    if (wargaId == null) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'ID warga tidak valid.',
      );
    }

    final wargaBox = await HiveService().openBox<dynamic>(_wargaBox);
    final raw = wargaBox.get(wargaId);
    if (raw is! Map) {
      return const LocalWargaWriteResult(
        success: false,
        error: 'Data warga tidak ditemukan.',
      );
    }

    final updated = {
      ...Map<String, dynamic>.from(raw),
      'is_deleted': true,
      'sync_status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    };

    await wargaBox.put(wargaId, updated);
    return LocalWargaWriteResult(
      success: true,
      entityId: wargaId,
      payload: updated,
    );
  }
}
