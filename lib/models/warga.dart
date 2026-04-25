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
