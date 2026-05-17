import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/models/iuran/iuransaya_model.dart';

class UploadIuranViewModel extends ChangeNotifier {
  final IuranSaya item;

  UploadIuranViewModel({required this.item}) {
    if (item.iuran.tipe != IuranType.insidentil) {
      jumlah = item.iuran.jumlah;
    }
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
      if (tanggal == null) {
        throw Exception("Tanggal wajib diisi");
      }

      if (buktiFile == null) {
        throw Exception("Bukti pembayaran wajib diupload");
      }

      if (jumlah == null || jumlah! <= 0) {
        throw Exception("Jumlah pembayaran tidak valid");
      }

      // TODO:
      // upload API disini

      await Future.delayed(const Duration(seconds: 2));

      isSuccess = true;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    }

    isLoading = false;

    notifyListeners();
  }

  void reset() {
    jumlah = item.iuran.tipe == IuranType.insidentil ? null : item.iuran.jumlah;

    tanggal = null;
    buktiFile = null;
    errorMessage = null;
    isSuccess = false;

    notifyListeners();
  }
}
