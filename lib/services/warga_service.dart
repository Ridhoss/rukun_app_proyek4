// =============================================================
// warga_service.dart
// Stub service — semua method kosong, siap disambungkan ke BE
// =============================================================

class KKModel {
  final String? id;
  final String noKK;
  final int rtId;
  final String address;

  KKModel({
    this.id,
    required this.noKK,
    required this.rtId,
    required this.address,
  });

  Map<String, dynamic> toMap() => {
    'no_kk': noKK,
    'rt_id': rtId,
    'address': address,
  };
}

class WargaModel {
  final String? id;
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
}

class WargaService {
  // Singleton
  static final WargaService _instance = WargaService._internal();
  factory WargaService() => _instance;
  WargaService._internal();

  // ─────────────────────────────────────────────
  // KK (Keluarga) Methods
  // ─────────────────────────────────────────────

  /// TODO: Simpan data KK baru ke Hive lokal, lalu sync ke API jika online.
  /// Endpoint: POST /api/keluarga
  Future<bool> saveKK(KKModel kk) async {
    // TODO: implement Hive save + API call
    // Contoh struktur:
    //   final box = await HiveService().openBox<Map>('keluarga');
    //   await box.put(uuid, kk.toMap());
    //   if (online) await ApiService().post('/api/keluarga', kk.toMap());
    await Future.delayed(const Duration(milliseconds: 300)); // simulasi
    return true;
  }

  /// TODO: Ambil semua KK berdasarkan RT.
  /// Endpoint: GET /api/keluarga?rt_id={rtId}
  Future<List<KKModel>> getKKByRT(int rtId) async {
    // TODO: implement fetch dari Hive / API
    return [];
  }

  /// TODO: Update data KK.
  /// Endpoint: PUT /api/keluarga/{id}
  Future<bool> updateKK(String id, KKModel kk) async {
    // TODO: implement update
    return true;
  }

  // ─────────────────────────────────────────────
  // Warga Methods
  // ─────────────────────────────────────────────

  /// TODO: Simpan data warga baru ke Hive lokal, lalu sync ke API jika online.
  /// Endpoint: POST /api/warga
  Future<bool> saveWarga(WargaModel warga) async {
    // TODO: implement Hive save + API call
    // Contoh struktur:
    //   final box = await HiveService().openBox<Map>('warga');
    //   await box.put(warga.nik, warga.toMap());
    //   if (online) await ApiService().post('/api/warga', warga.toMap());
    await Future.delayed(const Duration(milliseconds: 300)); // simulasi
    return true;
  }

  /// TODO: Ambil semua warga berdasarkan keluarga_id (no KK).
  /// Endpoint: GET /api/warga?keluarga_id={kkId}
  Future<List<WargaModel>> getWargaByKK(int kkId) async {
    // TODO: implement fetch dari Hive / API
    return [];
  }

  /// TODO: Update data warga.
  /// Endpoint: PUT /api/warga/{id}
  Future<bool> updateWarga(String id, WargaModel warga) async {
    // TODO: implement update
    return true;
  }

  /// TODO: Hapus warga (soft delete).
  /// Endpoint: DELETE /api/warga/{id}
  Future<bool> deleteWarga(String id) async {
    // TODO: implement delete
    return true;
  }

  // ─────────────────────────────────────────────
  // RT List (untuk dropdown)
  // ─────────────────────────────────────────────

  /// TODO: Ambil daftar RT dari Hive/API.
  /// Endpoint: GET /api/rt
  Future<List<Map<String, dynamic>>> getRTList() async {
    // TODO: implement fetch RT list
    // Sementara return data dummy:
    return [
      {'id': 1, 'no_rt': 1, 'name': 'RT 001'},
      {'id': 2, 'no_rt': 2, 'name': 'RT 002'},
      {'id': 3, 'no_rt': 3, 'name': 'RT 003'},
    ];
  }
}