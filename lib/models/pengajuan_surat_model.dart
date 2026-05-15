enum SuratStatus { diajukan, disetujui, ditolak, selesai }

class PengajuanSurat {
  final int? id;
  final int? wargaId;
  final String keperluan;
  final String keterangan;
  final SuratStatus status;
  final int? disetujuiOleh;
  final String? docRef;
  final DateTime? waktuDisetujui;
  final DateTime? waktuDibuat;
  final DateTime? waktuDiubah;
  final DateTime? waktuDihapus;

  const PengajuanSurat({
    this.id,
    this.wargaId,
    required this.keperluan,
    required this.keterangan,
    this.status = SuratStatus.diajukan,
    this.disetujuiOleh,
    this.waktuDisetujui,
    this.docRef,
    this.waktuDibuat,
    this.waktuDiubah,
    this.waktuDihapus,
  });

  PengajuanSurat copyWith({
    int? id,
    int? wargaId,
    String? keperluan,
    String? keterangan,
    SuratStatus? status,
    int? disetujuiOleh,
    String? docRef,
    DateTime? waktuDisetujui,
    DateTime? waktuDibuat,
    DateTime? waktuDiubah,
    DateTime? waktuDihapus,
  }) {
    return PengajuanSurat(
      id: id ?? this.id,
      wargaId: wargaId ?? this.wargaId,
      keperluan: keperluan ?? this.keperluan,
      keterangan: keterangan ?? this.keterangan,
      status: status ?? this.status,
      disetujuiOleh: disetujuiOleh ?? this.disetujuiOleh,
      docRef: docRef ?? this.docRef,
      waktuDisetujui: waktuDisetujui ?? this.waktuDisetujui,
      waktuDibuat: waktuDibuat ?? this.waktuDibuat,
      waktuDiubah: waktuDiubah ?? this.waktuDiubah,
      waktuDihapus: waktuDihapus ?? this.waktuDihapus,
    );
  }

  factory PengajuanSurat.fromJson(Map<String, dynamic> json) {
    return PengajuanSurat(
      id: json['id'],
      wargaId: json['warga_id'],
      keperluan: json['keperluan'],
      keterangan: json['keterangan'],
      status: _status(json['status']),
      disetujuiOleh: json['disetujui_oleh'],
      docRef: json['doc_ref'],
      waktuDisetujui: json['waktu_disetujui'] != null
          ? DateTime.parse(json['waktu_disetujui'])
          : null,
      waktuDibuat: json['waktu_dibuat'] != null
          ? DateTime.parse(json['waktu_dibuat'])
          : null,
      waktuDiubah: json['waktu_diubah'] != null
          ? DateTime.parse(json['waktu_diubah'])
          : null,
      waktuDihapus: json['waktu_dihapus'] != null
          ? DateTime.parse(json['waktu_dihapus'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warga_id': wargaId,
      'keperluan': keperluan,
      'keterangan': keterangan,
      'status': _statusToString(status),
      'disetujui_oleh': disetujuiOleh,
      'doc_ref': docRef,
      'waktu_disetujui': waktuDisetujui?.toIso8601String(),
      'waktu_dibuat': waktuDibuat?.toIso8601String(),
      'waktu_diubah': waktuDiubah?.toIso8601String(),
      'waktu_dihapus': waktuDihapus?.toIso8601String(),
    };
  }

  static SuratStatus _status(String? v) {
    switch (v) {
      case "Disetujui":
        return SuratStatus.disetujui;

      case "Ditolak":
        return SuratStatus.ditolak;

      case "Selesai":
        return SuratStatus.selesai;

      default:
        return SuratStatus.diajukan;
    }
  }

  static String _statusToString(SuratStatus status) {
    switch (status) {
      case SuratStatus.diajukan:
        return "Diajukan";

      case SuratStatus.disetujui:
        return "Disetujui";

      case SuratStatus.ditolak:
        return "Ditolak";

      case SuratStatus.selesai:
        return "Selesai";
    }
  }
}
