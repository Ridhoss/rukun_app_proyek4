enum StatusPembayaran { belumDibayar, diproses, dibayar, ditolak }

class Transaksi {
  final int? id;
  final int iuranId;
  final int? keluargaId;
  final int? wargaId;
  final int? jumlah;
  final DateTime? waktuBayar;
  final StatusPembayaran status;
  final String? imgRef;
  final String? catatan;
  final int? disetujuiOleh;
  final DateTime? waktuDisetujui;
  final DateTime? waktuDibuat;
  final DateTime? waktuDiubah;
  final DateTime? waktuDihapus;

  Transaksi({
    this.id,
    required this.iuranId,
    this.keluargaId,
    this.wargaId,
    this.jumlah,
    this.waktuBayar,
    required this.status,
    this.imgRef,
    this.catatan,
    this.disetujuiOleh,
    this.waktuDisetujui,
    this.waktuDibuat,
    this.waktuDiubah,
    this.waktuDihapus,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      iuranId: json['iuran_id'],
      keluargaId: json['keluarga_id'],
      wargaId: json['warga_id'],
      jumlah: json['jumlah'],
      waktuBayar: json['waktu_bayar'] != null
          ? DateTime.parse(json['waktu_bayar'])
          : null,
      status: _status(json['status']),
      imgRef: json['img_referensi'],
      catatan: json['catatan'],
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
      'iuran_id': iuranId,
      'keluarga_id': keluargaId,
      'warga_id': wargaId,
      'jumlah': jumlah,
      'status': _statusToString(status),
      'img_referensi': imgRef,
      'catatan': catatan,
      'disetujui_oleh': disetujuiOleh,
    };
  }

  static StatusPembayaran _status(String? v) {
    switch (v) {
      case "Diproses":
        return StatusPembayaran.diproses;

      case "Dibayar":
        return StatusPembayaran.dibayar;

      case "Ditolak":
        return StatusPembayaran.ditolak;

      case "Belum Dibayar":
      default:
        return StatusPembayaran.belumDibayar;
    }
  }

  static String _statusToString(StatusPembayaran status) {
    switch (status) {
      case StatusPembayaran.diproses:
        return "Diproses";

      case StatusPembayaran.dibayar:
        return "Dibayar";

      case StatusPembayaran.ditolak:
        return "Ditolak";

      case StatusPembayaran.belumDibayar:
        return "Belum Dibayar";
    }
  }
}
