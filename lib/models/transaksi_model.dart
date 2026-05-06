enum StatusPembayaran {
  belumDibayar,
  diproses,
  dibayar,
  ditolak,
}
class Transaksi {
  final int id;
  final int iuranId;
  final int? keluargaId;
  final int? wargaId;
  final int jumlah;
  final DateTime? waktuBayar;
  final StatusPembayaran status;
  final String? imgRef;
  final int? diverifikasiOleh;
  final DateTime? waktuVerifikasi;

  Transaksi({
    required this.id,
    required this.iuranId,
    this.keluargaId,
    this.wargaId,
    required this.jumlah,
    this.waktuBayar,
    required this.status,
    this.imgRef,
    this.diverifikasiOleh,
    this.waktuVerifikasi,
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

      diverifikasiOleh: json['diverifikasi_oleh'],
      waktuVerifikasi: json['waktu_verifikasi'] != null
          ? DateTime.parse(json['waktu_verifikasi'])
          : null,
    );
  }

  static StatusPembayaran _status(String v) {
    switch (v) {
      case "lunas":
        return StatusPembayaran.dibayar;
      case "belum_dibayar":
        return StatusPembayaran.belumDibayar;
      case "ditolak":
        return StatusPembayaran.ditolak;
      default:
        return StatusPembayaran.belumDibayar;
    }
  }
}
