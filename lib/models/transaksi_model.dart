enum ApprovalStatus { ditunda, disetujui, ditolak }

class Transaksi {
  final int id;
  final int iuranId;
  final int? keluargaId;
  final int? wargaId;
  final int jumlah;
  final DateTime waktuBayar;
  final ApprovalStatus status;
  final int? disetujuiOleh;
  final DateTime? waktuDisetujui;

  Transaksi({
    required this.id,
    required this.iuranId,
    this.keluargaId,
    this.wargaId,
    required this.jumlah,
    required this.waktuBayar,
    required this.status,
    this.disetujuiOleh,
    this.waktuDisetujui,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      iuranId: json['iuran_id'],
      keluargaId: json['keluarga_id'],
      wargaId: json['warga_id'],
      jumlah: json['jumlah'],
      waktuBayar: DateTime.parse(json['waktu_bayar']),
      status: _status(json['status']),
      disetujuiOleh: json['disetujui_oleh'],
      waktuDisetujui: json['waktu_disetujui'] != null
          ? DateTime.parse(json['waktu_disetujui'])
          : null,
    );
  }

  static ApprovalStatus _status(String v) {
    switch (v) {
      case "disetujui":
        return ApprovalStatus.disetujui;
      case "ditolak":
        return ApprovalStatus.ditolak;
      default:
        return ApprovalStatus.ditunda;
    }
  }
}

