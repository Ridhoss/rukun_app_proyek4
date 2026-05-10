import 'package:rukun_app_proyek4/models/iuran_model.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';

class IuranSaya {
  final Iuran iuran;

  final List<Transaksi> transaksi;

  IuranSaya({required this.iuran, required this.transaksi});

  factory IuranSaya.fromJson(Map<String, dynamic> json) {
    final transaksiJson = json['transaksi'] as List? ?? [];

    return IuranSaya(
      iuran: Iuran.fromJson(json),

      transaksi: (transaksiJson as List)
          .map((e) => Transaksi.fromJson(e))
          .toList(),
    );
  }

  Transaksi? get transaksiTerbaru {
    if (transaksi.isEmpty) {
      return null;
    }
    transaksi.sort((a, b) => b.waktuBayar!.compareTo(a.waktuBayar!));
    return transaksi.first;
  }

  bool get pernahBayar {
    return transaksi.isNotEmpty;
  }

  StatusPembayaran get statusTerbaru {
    return transaksiTerbaru?.status ?? StatusPembayaran.belumDibayar;
  }
}
