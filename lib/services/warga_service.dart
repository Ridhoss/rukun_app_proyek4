import 'package:rukun_app_proyek4/services/hive_service.dart';
import 'package:rukun_app_proyek4/services/session_context_service.dart';

// =============================================================
// warga_service.dart
// Offline-first service untuk input KK/Warga oleh pengurus RT.
// =============================================================

class KKModel {
  final int? id;
  final String noKK;
  final int rtId;
  final String alamat;

  KKModel({
    this.id,
    required this.noKK,
    required this.rtId,
    required this.alamat,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'no_kk': noKK,
    'rt_id': rtId,
    'alamat': alamat,
  };

  factory KKModel.fromMap(Map<dynamic, dynamic> map) {
    return KKModel(
      id: map['id'] == null ? null : (map['id'] as num).toInt(),
      noKK: (map['no_kk'] ?? '') as String,
      rtId: (map['rt_id'] as num).toInt(),
      alamat: ((map['alamat'] ?? map['address']) ?? '') as String,
    );
  }
}

class WargaModel {
  final int? id;
  final String nama;
  final String nik;
  final String jk;
  final String tempatLahir;
  final DateTime? tglLahir;
  final String agama;
  final String pendidikan;
  final String jenisPekerjaan;
  final String golonganDarah;
  final String statusPerkawinan;
  final DateTime? tglPerkawinan;
  final String statusHubungan;
  final String kewarganegaraan;
  final String? noPaspor;
  final String? noKitap;
  final String namaAyah;
  final String namaIbu;
  final int? keluargaId;

  WargaModel({
    this.id,
    required this.nama,
    required this.nik,
    required this.jk,
    required this.tempatLahir,
    this.tglLahir,
    required this.agama,
    required this.pendidikan,
    required this.jenisPekerjaan,
    required this.golonganDarah,
    required this.statusPerkawinan,
    this.tglPerkawinan,
    required this.statusHubungan,
    required this.kewarganegaraan,
    this.noPaspor,
    this.noKitap,
    required this.namaAyah,
    required this.namaIbu,
    this.keluargaId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama': nama,
    'nik': nik,
    'jk': jk,
    'tempat_lahir': tempatLahir,
    'tgl_lahir': tglLahir?.toIso8601String(),
    'agama': agama,
    'pendidikan': pendidikan,
    'jenis_pekerjaan': jenisPekerjaan,
    'golongan_darah': golonganDarah,
    'status_perkawinan': statusPerkawinan,
    'tgl_perkawinan': tglPerkawinan?.toIso8601String(),
    'status_hubungan': statusHubungan,
    'kewarganegaraan': kewarganegaraan,
    'no_paspor': noPaspor,
    'no_kitap': noKitap,
    'nama_ayah': namaAyah,
    'nama_ibu': namaIbu,
    'keluarga_id': keluargaId,
  };

  factory WargaModel.fromMap(Map<dynamic, dynamic> map) {
    return WargaModel(
      id: map['id'] == null ? null : (map['id'] as num).toInt(),
      nama: (map['nama'] ?? '') as String,
      nik: (map['nik'] ?? '') as String,
      jk: (map['jk'] ?? '') as String,
      tempatLahir: (map['tempat_lahir'] ?? '') as String,
      tglLahir: map['tgl_lahir'] == null
          ? null
          : DateTime.tryParse(map['tgl_lahir'] as String),
      agama: (map['agama'] ?? '') as String,
      pendidikan: (map['pendidikan'] ?? '') as String,
      jenisPekerjaan: (map['jenis_pekerjaan'] ?? '') as String,
      golonganDarah: (map['golongan_darah'] ?? '') as String,
      statusPerkawinan: (map['status_perkawinan'] ?? '') as String,
      tglPerkawinan: map['tgl_perkawinan'] == null
          ? null
          : DateTime.tryParse(map['tgl_perkawinan'] as String),
      statusHubungan: (map['status_hubungan'] ?? '') as String,
      kewarganegaraan: (map['kewarganegaraan'] ?? '') as String,
      noPaspor: map['no_paspor'] as String?,
      noKitap: map['no_kitap'] as String?,
      namaAyah: (map['nama_ayah'] ?? '') as String,
      namaIbu: (map['nama_ibu'] ?? '') as String,
      keluargaId: map['keluarga_id'] == null
          ? null
          : (map['keluarga_id'] as num).toInt(),
    );
  }
}

class WargaService {
  // Singleton
  static final WargaService _instance = WargaService._internal();
  factory WargaService() => _instance;
  WargaService._internal();

  static const String _kkBox = 'keluarga_offline';
  static const String _wargaBox = 'warga_offline';
  static const String _metaBox = 'metadata_offline';
  static const String _syncQueueBox = 'sync_queue_offline';

  int _currentRtId = 1;
  String _currentRtLabel = 'RT 001';
  bool _contextLoaded = false;
  final SessionContextService _sessionContextService = SessionContextService();

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
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // ─────────────────────────────────────────────
  // KK (Keluarga) Methods
  // ─────────────────────────────────────────────

  /// Simpan data KK baru ke Hive lokal dan antri untuk sinkronisasi.
  Future<bool> saveKK(KKModel kk) async {
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
  Future<List<KKModel>> getKKByRT(int rtId) async {
    await _ensureContextLoaded();
    final kkBox = await HiveService().openBox<dynamic>(_kkBox);
    final result = kkBox.values
        .whereType<Map>()
        .where(
          (row) =>
              (row['rt_id'] as num?)?.toInt() == rtId &&
              (row['is_deleted'] as bool?) != true,
        )
        .map(KKModel.fromMap)
        .toList();

    result.sort((a, b) => b.id!.compareTo(a.id!));
    return result;
  }

  /// Update data KK lokal.
  Future<bool> updateKK(String id, KKModel kk) async {
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

    if (warga.keluargaId == null) {
      lastError = 'Keluarga wajib dipilih sebelum menambah warga.';
      return false;
    }

    final kkBox = await HiveService().openBox<dynamic>(_kkBox);
    final keluargaRaw = kkBox.get(warga.keluargaId);
    if (keluargaRaw is! Map) {
      lastError = 'Data keluarga tidak ditemukan.';
      return false;
    }
    if ((keluargaRaw['rt_id'] as num).toInt() != _currentRtId) {
      lastError = 'Anda tidak bisa menambah warga di KK milik RT lain.';
      return false;
    }

    final wargaBox = await HiveService().openBox<dynamic>(_wargaBox);
    final nikNormalized = warga.nik.trim();
    final duplicateNik = wargaBox.values.whereType<Map>().any((row) {
      final sameNik = ((row['nik'] ?? '') as String).trim() == nikNormalized;
      final notDeleted = (row['is_deleted'] as bool?) != true;
      return sameNik && notDeleted;
    });
    if (duplicateNik) {
      lastError = 'NIK sudah terdaftar.';
      return false;
    }

    final id = await _nextId('seq.warga');
    final payload = {
      ...warga.toMap(),
      'id': id,
      'nik': nikNormalized,
      'sync_status': 'pending',
      'created_by_user_id': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_deleted': false,
    };

    await wargaBox.put(id, payload);
    await _enqueueSync(
      entity: 'warga',
      operation: 'create',
      entityId: id,
      payload: payload,
    );

    return true;
  }

  /// Ambil semua warga berdasarkan keluarga_id dari storage lokal.
  Future<List<WargaModel>> getWargaByKK(int kkId) async {
    await _ensureContextLoaded();
    final wargaBox = await HiveService().openBox<dynamic>(_wargaBox);
    final result = wargaBox.values
        .whereType<Map>()
        .where(
          (row) =>
              (row['keluarga_id'] as num?)?.toInt() == kkId &&
              (row['is_deleted'] as bool?) != true,
        )
        .map(WargaModel.fromMap)
        .toList();

    result.sort((a, b) => b.id!.compareTo(a.id!));
    return result;
  }

  /// Update warga lokal dengan validasi NIK unik.
  Future<bool> updateWarga(String id, WargaModel warga) async {
    await _ensureContextLoaded();
    lastError = null;
    final wargaId = int.tryParse(id);
    if (wargaId == null) {
      lastError = 'ID warga tidak valid.';
      return false;
    }

    final wargaBox = await HiveService().openBox<dynamic>(_wargaBox);
    final raw = wargaBox.get(wargaId);
    if (raw is! Map) {
      lastError = 'Data warga tidak ditemukan.';
      return false;
    }

    final nikNormalized = warga.nik.trim();
    final duplicateNik = wargaBox.values.whereType<Map>().any((row) {
      final rowId = (row['id'] as num?)?.toInt();
      final sameNik = ((row['nik'] ?? '') as String).trim() == nikNormalized;
      final notDeleted = (row['is_deleted'] as bool?) != true;
      return rowId != wargaId && sameNik && notDeleted;
    });
    if (duplicateNik) {
      lastError = 'NIK sudah dipakai warga lain.';
      return false;
    }

    if (warga.keluargaId == null) {
      lastError = 'Keluarga tidak valid.';
      return false;
    }

    final kkBox = await HiveService().openBox<dynamic>(_kkBox);
    final keluargaRaw = kkBox.get(warga.keluargaId);
    if (keluargaRaw is! Map ||
        (keluargaRaw['rt_id'] as num).toInt() != _currentRtId) {
      lastError = 'Anda tidak bisa memindahkan warga ke KK di RT lain.';
      return false;
    }

    final updated = {
      ...Map<String, dynamic>.from(raw),
      ...warga.toMap(),
      'id': wargaId,
      'nik': nikNormalized,
      'sync_status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    };

    await wargaBox.put(wargaId, updated);
    await _enqueueSync(
      entity: 'warga',
      operation: 'update',
      entityId: wargaId,
      payload: updated,
    );

    return true;
  }

  /// Hapus warga (soft delete) di storage lokal.
  Future<bool> deleteWarga(String id) async {
    await _ensureContextLoaded();
    lastError = null;
    final wargaId = int.tryParse(id);
    if (wargaId == null) {
      lastError = 'ID warga tidak valid.';
      return false;
    }

    final wargaBox = await HiveService().openBox<dynamic>(_wargaBox);
    final raw = wargaBox.get(wargaId);
    if (raw is! Map) {
      lastError = 'Data warga tidak ditemukan.';
      return false;
    }

    final updated = {
      ...Map<String, dynamic>.from(raw),
      'is_deleted': true,
      'sync_status': 'pending',
      'updated_at': DateTime.now().toIso8601String(),
    };

    await wargaBox.put(wargaId, updated);
    await _enqueueSync(
      entity: 'warga',
      operation: 'delete',
      entityId: wargaId,
      payload: updated,
    );

    return true;
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
