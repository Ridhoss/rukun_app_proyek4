import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';

class AddKKViewModel extends ChangeNotifier {
  final KKRepository kkRepository;
  final CloudinaryService cloudinaryService;
  final int rtId;
  File? fotoKK;

  AddKKViewModel({
    required this.kkRepository,
    required this.rtId,
    required this.cloudinaryService,
  });

  bool isSaving = false;
  bool isKKSaved = false;
  String? errorMessage;

  Keluarga? kk;

  String noKK = '';
  String alamat = '';
  String kodePos = '';

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

  Future<void> createKK() async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      String? fotoUrl;

      if (fotoKK != null) {
        fotoUrl = await cloudinaryService.uploadFile(fotoKK!);

        if (fotoUrl == null) {
          throw Exception("Gagal upload foto KK");
        }
      }

      final data = Keluarga(
        noKK: noKK,
        rtId: rtId,
        alamat: alamat,
        kodePos: kodePos,
        imgRef: fotoUrl,
      );

      final result = await kkRepository.createKK(data);

      if (result == null) throw Exception("Gagal membuat KK");

      kk = result;
      isKKSaved = true;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    }

    isSaving = false;
    notifyListeners();
  }
}
