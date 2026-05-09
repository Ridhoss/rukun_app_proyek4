enum StatusPembayaran {
  belumDibayar,
  diproses,
  dibayar,
  ditolak,
}

class Transaksi {
  final int? id;

  final int iuranId;

  final int? keluargaId;

  final int? wargaId;

  final int jumlah;

  final DateTime? waktuBayar;

  final StatusPembayaran status;

  final String? imgRef;

  final int? disetujuiOleh;

  final DateTime? waktuDisetujui;

  final DateTime? waktuDibuat;

  Transaksi({
    this.id,
    required this.iuranId,
    this.keluargaId,
    this.wargaId,
    required this.jumlah,
    this.waktuBayar,
    required this.status,
    this.imgRef,
    this.disetujuiOleh,
    this.waktuDisetujui,
    this.waktuDibuat,
  });

  factory Transaksi.fromJson(
    Map<String, dynamic> json,
  ) {
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
      disetujuiOleh: json['disetujui_oleh'],
      waktuDisetujui:
          json['waktu_disetujui'] != null
          ? DateTime.parse(
              json['waktu_disetujui'],
            )
          : null,
      waktuDibuat:
          json['waktu_dibuat'] != null
          ? DateTime.parse(
              json['waktu_dibuat'],
            )
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
      'waktu_bayar':
          waktuBayar?.toIso8601String(),
      'status': _statusToString(status),
      'img_referensi': imgRef,
      'disetujui_oleh': disetujuiOleh,
      'waktu_disetujui':
          waktuDisetujui?.toIso8601String(),
      'waktu_dibuat':
          waktuDibuat?.toIso8601String(),
    };
  }

  static StatusPembayaran _status(
    String? v,
  ) {
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

  static String _statusToString(
    StatusPembayaran status,
  ) {
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