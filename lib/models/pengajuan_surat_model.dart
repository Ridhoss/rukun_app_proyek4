enum SuratStatus { tertunda, disetujui, ditolak, selesai }

class PengajuanSurat {
  final int? id;
  final int wargaId;
  final String jenisSurat;
  final String subjectKeperluan;
  final String keterangan;
  final SuratStatus status;
  final int? disetujuiOleh;
  final DateTime? waktuDisetujui;
  final DateTime? waktuDibuat;

  const PengajuanSurat({
    this.id,
    required this.wargaId,
    required this.jenisSurat,
    required this.subjectKeperluan,
    required this.keterangan,
    this.status = SuratStatus.tertunda,
    this.disetujuiOleh,
    this.waktuDisetujui,
    this.waktuDibuat,
  });

  PengajuanSurat copyWith({
    int? id,
    int? wargaId,
    String? jenisSurat,
    String? subjectKeperluan,
    String? keterangan,
    SuratStatus? status,
    int? disetujuiOleh,
    DateTime? waktuDisetujui,
    DateTime? waktuDibuat,
  }) {
    return PengajuanSurat(
      id: id ?? this.id,
      wargaId: wargaId ?? this.wargaId,
      jenisSurat: jenisSurat ?? this.jenisSurat,
      subjectKeperluan: subjectKeperluan ?? this.subjectKeperluan,
      keterangan: keterangan ?? this.keterangan,
      status: status ?? this.status,
      disetujuiOleh: disetujuiOleh ?? this.disetujuiOleh,
      waktuDisetujui: waktuDisetujui ?? this.waktuDisetujui,
      waktuDibuat: waktuDibuat ?? this.waktuDibuat,
    );
  }

  factory PengajuanSurat.fromJson(Map<String, dynamic> json) {
    return PengajuanSurat(
      id: json['id'],
      wargaId: json['warga_id'],
      jenisSurat: json['jenis_surat'],
      subjectKeperluan: json['subject_keperluan'],
      keterangan: json['keterangan'],
      status: _status(json['status']),
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
      'id': id,
      'warga_id': wargaId,
      'jenis_surat': jenisSurat,
      'subject_keperluan': subjectKeperluan,
      'keterangan': keterangan,
      'status': status.name,
      'disetujui_oleh': disetujuiOleh,
      'waktu_disetujui': waktuDisetujui?.toIso8601String(),
      'waktu_dibuat': waktuDibuat?.toIso8601String(),
    };
  }

  static SuratStatus _status(String? v) {
    switch (v) {
      case "disetujui":
        return SuratStatus.disetujui;
      case "ditolak":
        return SuratStatus.ditolak;
      case "selesai":
        return SuratStatus.selesai;
      default:
        return SuratStatus.tertunda;
    }
  }
}
