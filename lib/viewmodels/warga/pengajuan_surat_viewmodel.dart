import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';

class PengajuanSuratViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  // dummy data data pemohon
  final String nama = "Indah Permatasari";
  final String nik = "0894872536475849";
  final String rw = "02";
  final String rt = "06";
  final String alamat = "Jl. Merdeka No.12";

  Future<bool> submitPengajuan(PengajuanSurat data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
