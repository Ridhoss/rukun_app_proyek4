class PengajuanSurat {
  final int? id;
  final int wargaId;
  final String jenisSurat;
  final String subjectKeperluan;
  final String keterangan;
  final String status;
  final int? disetujuiOleh;
  final DateTime? waktuDisetujui;
  final DateTime? waktuDibuat;

  PengajuanSurat({
    this.id,
    required this.wargaId,
    required this.jenisSurat,
    required this.subjectKeperluan,
    required this.keterangan,
    this.status = "tertunda",
    this.disetujuiOleh,
    this.waktuDisetujui,
    this.waktuDibuat,
  });

  factory PengajuanSurat.fromJson(Map<String, dynamic> json) {
    return PengajuanSurat(
      id: json['id'],
      wargaId: json['warga_id'],
      jenisSurat: json['jenis_surat'],
      subjectKeperluan: json['subject_keperluan'],
      keterangan: json['keterangan'],
      status: json['status'],
      disetujuiOleh: json['disetujui_oleh'],
      waktuDisetujui: json['waktu_disetujui'] != null
          ? DateTime.parse(json['waktu_disetujui'])
          : null,
      waktuDibuat: json['waktu_dibuat'] != null
          ? DateTime.parse(json['waktu_dibuat'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warga_id': wargaId,
      'jenis_surat': jenisSurat,
      'subject_keperluan': subjectKeperluan,
      'keterangan': keterangan,
      'status': status,
      'disetujui_oleh': disetujuiOleh,
      'waktu_disetujui': waktuDisetujui?.toIso8601String(),
      'waktu_dibuat': waktuDibuat?.toIso8601String(),
    };
  }
}