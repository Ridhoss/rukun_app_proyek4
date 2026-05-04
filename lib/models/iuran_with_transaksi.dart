import 'package:rukun_app_proyek4/models/iuran_model.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';

class IuranWithTransaksi {
  final Iuran iuran;
  final Transaksi? transaksi;

  IuranWithTransaksi({
    required this.iuran,
    this.transaksi,
  });
}