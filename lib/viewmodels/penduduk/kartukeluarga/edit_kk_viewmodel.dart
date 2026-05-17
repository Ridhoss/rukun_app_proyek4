import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';

class EditKKViewModel extends ChangeNotifier {
  final KKRepository kkRepository;
  final CloudinaryService cloudinaryService;

  final int idKK;

  EditKKViewModel({
    required this.kkRepository,
    required this.cloudinaryService,
    required this.idKK,
  }) {
    getDetailKK();
  }

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;

  Keluarga? kk;

  File? fotoKK;

  /// url image lama
  String? fotoKKUrl;

  String noKK = '';
  String alamat = '';
  String kodePos = '';

  Future<void> getDetailKK() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      final result = await kkRepository.getKKById(idKK);

      if (result == null) {
        throw Exception("Data KK tidak ditemukan");
      }

      kk = result;

      noKK = result.noKK;
      alamat = result.alamat ?? '';
      kodePos = result.kodePos ?? '';

      fotoKKUrl = result.imgRef;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> pickFotoKK() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      fotoKK = File(picked.path);
      notifyListeners();
    }
  }

  void setFotoKK(File file) {
    fotoKK = file;
    notifyListeners();
  }

  Future<void> updateKK() async {
    try {
      isSaving = true;
      errorMessage = null;

      notifyListeners();

      String? fotoUrl = fotoKKUrl;

      if (fotoKK != null) {
        fotoUrl = await cloudinaryService.uploadFile(fotoKK!, folder: 'kartukeluarga');

        if (fotoUrl == null) {
          throw Exception("Gagal upload foto KK baru");
        }
      }

      if (kk == null) {
        throw Exception("Data KK belum dimuat");
      }

      final data = {
        "no_kk": noKK,
        "alamat": alamat,
        "kode_pos": kodePos,
        "img_referensi": fotoUrl,
      };

      await kkRepository.updateKK(idKK, data);
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    }

    isSaving = false;
    notifyListeners();
  }
}
