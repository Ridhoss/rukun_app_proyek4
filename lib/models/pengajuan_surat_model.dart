enum SuratStatus { diajukan, disetujui, ditolak, selesai }

class PengajuanSurat {
  final int? id;
  final int? wargaId;
  final String jenisSurat;
  final String keperluan;
  final String keterangan;
  final SuratStatus status;
  final int? disetujuiOleh;
  final DateTime? waktuDisetujui;
  final DateTime? waktuDibuat;
  final DateTime? waktuDiubah;
  final DateTime? waktuDihapus;

  const PengajuanSurat({
    this.id,
    this.wargaId,
    required this.jenisSurat,
    required this.keperluan,
    required this.keterangan,
    this.status = SuratStatus.diajukan,
    this.disetujuiOleh,
    this.waktuDisetujui,
    this.waktuDibuat,
    this.waktuDiubah,
    this.waktuDihapus,
  });

  PengajuanSurat copyWith({
    int? id,
    int? wargaId,
    String? jenisSurat,
    String? keperluan,
    String? keterangan,
    SuratStatus? status,
    int? disetujuiOleh,
  }) {
    return PengajuanSurat(
      id: id ?? this.id,
      wargaId: wargaId ?? this.wargaId,
      jenisSurat: jenisSurat ?? this.jenisSurat,
      keperluan: keperluan ?? this.keperluan,
      keterangan: keterangan ?? this.keterangan,
      status: status ?? this.status,
      disetujuiOleh: disetujuiOleh ?? this.disetujuiOleh,
    );
  }

  factory PengajuanSurat.fromJson(Map<String, dynamic> json) {
    return PengajuanSurat(
      id: json['id'],
      wargaId: json['warga_id'],
      jenisSurat: json['jenis_surat'],
      keperluan: json['keperluan'],
      keterangan: json['keterangan'],
      status: _status(json['status']),
      disetujuiOleh: json['disetujui_oleh'],
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
      'jenis_surat': jenisSurat,
      'keperluan': keperluan,
      'keterangan': keterangan,
      'status': _statusToString(status),
      'disetujui_oleh': disetujuiOleh,
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
