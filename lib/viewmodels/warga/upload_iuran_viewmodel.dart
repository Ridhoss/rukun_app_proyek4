import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rukun_app_proyek4/models/iuran_with_transaksi.dart';

class UploadIuranViewModel extends ChangeNotifier {
  final IuranWithTransaksi item;

  UploadIuranViewModel({required this.item}) {
    periode = item.iuran.periode.name;
  }

  String periode = "";
  int? jumlah;
  DateTime? tanggal;
  File? buktiFile;

  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  void setJumlah(String value) {
    jumlah = int.tryParse(value);
    notifyListeners();
  }

  void setTanggal(DateTime date) {
    tanggal = date;
    notifyListeners();
  }

  Future<void> pickBukti() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      buktiFile = File(picked.path);
      notifyListeners();
    }
  }

  Future<void> submit() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (jumlah == null || tanggal == null || buktiFile == null) {
        throw Exception("Semua field wajib diisi");
      }

      await Future.delayed(const Duration(seconds: 2));

      isSuccess = true;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    jumlah = null;
    tanggal = null;
    buktiFile = null;
    errorMessage = null;
    isSuccess = false;
    notifyListeners();
  }
}
