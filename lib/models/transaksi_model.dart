import 'package:rukun_app_proyek4/models/keluarga_model.dart';

enum StatusPembayaran { belumDibayar, diproses, dibayar, ditolak }

class Transaksi {
  final int? id;
  final int iuranId;
  final int? keluargaId;
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
  final Keluarga? keluarga;
  final String? disetujuiNama;

  Transaksi({
    this.id,
    required this.iuranId,
    this.keluargaId,
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
    this.keluarga,
    this.disetujuiNama,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      iuranId: json['iuran_id'],
      keluargaId: json['keluarga_id'],
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
      keluarga: json['keluarga'] != null
          ? Keluarga.fromJson(json['keluarga'])
          : null,
      disetujuiNama: json['disetujui_nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iuran_id': iuranId,
      'keluarga_id': keluargaId,
      'jumlah': jumlah,
      'status': _statusToString(status),
      'img_referensi': imgRef,
      'waktu_bayar': waktuBayar?.toIso8601String(),
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

  Transaksi copyWith({StatusPembayaran? status}) {
    return Transaksi(
      id: id,
      iuranId: iuranId,
      keluargaId: keluargaId,
      waktuBayar: waktuBayar,
      jumlah: jumlah,
      status: status ?? this.status,
      imgRef: imgRef,
      catatan: catatan,
      disetujuiOleh: disetujuiOleh,
      waktuDisetujui: waktuDisetujui,
      keluarga: keluarga,
      disetujuiNama: disetujuiNama,
    );
  }
}
