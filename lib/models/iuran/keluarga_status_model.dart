import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';

class KeluargaStatus {
  final Keluarga keluarga;
  final bool sudahBayar;
  final StatusPembayaran status;
  final int nominal;
  final int? idTransaksi;
  final DateTime? waktuBayar;
  final String? disetujuiOleh;
  final String? imgBukti;

  KeluargaStatus({
    required this.keluarga,
    required this.sudahBayar,
    required this.status,
    required this.nominal,
    required this.idTransaksi,
    this.waktuBayar,
    this.disetujuiOleh,
    this.imgBukti,
  });
}
