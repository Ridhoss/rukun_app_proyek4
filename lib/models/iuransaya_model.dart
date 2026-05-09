import 'package:rukun_app_proyek4/models/iuran_model.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';

class IuranSaya {
  final Iuran iuran;
  final Transaksi? transaksi;

  IuranSaya({
    required this.iuran,
    this.transaksi,
  });

  factory IuranSaya.fromJson(
    Map<String, dynamic> json,
  ) {
    final transaksiId = json['transaksi_id'];

    return IuranSaya(
      iuran: Iuran.fromJson(json),
      transaksi: transaksiId != null
          ? Transaksi(
              id: transaksiId,
              iuranId: json['id'],
              jumlah: json['jumlah'],
              waktuBayar:
                  json['waktu_bayar'] != null
                  ? DateTime.parse(
                      json['waktu_bayar'],
                    )
                  : null,
              status: _parseStatus(
                json['status'],
              ),
            )
          : null,
    );
  }

  static StatusPembayaran _parseStatus(
    String? status,
  ) {
    switch (status) {
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
}