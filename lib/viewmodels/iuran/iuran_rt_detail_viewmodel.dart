import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/models/rt_model.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repository.dart';
import 'package:rukun_app_proyek4/repositories/rtrw_repository.dart';

class IuranRTDetailViewModel extends ChangeNotifier {
  final IuranRepository iuranRepo;
  final RTRWRepository rtrwRepo;

  IuranRTDetailViewModel({required this.iuranRepo, required this.rtrwRepo});

  bool isLoading = false;
  String? errorMessage;

  Iuran? iuran;
  RtModel? rtDetail;

  List<Transaksi> transaksi = [];

  int totalTerkumpul = 0;

  Future<void> fetchDetail(int iuranId, int rtId) async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      final result = await iuranRepo.getIuranById(iuranId);

      final rt = await rtrwRepo.getRTById(rtId);

      iuran = result;
      rtDetail = rt;

      final allTransaksi = result?.transaksi ?? [];

      transaksi = allTransaksi.where((t) {
        final keluarga = t.keluarga;

        return keluarga?.rtId == rtId;
      }).toList();

      totalTerkumpul = transaksi
          .where((t) => t.status == StatusPembayaran.dibayar)
          .fold<int>(0, (sum, item) => sum + (item.jumlah ?? 0));
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;

    notifyListeners();
  }
}
