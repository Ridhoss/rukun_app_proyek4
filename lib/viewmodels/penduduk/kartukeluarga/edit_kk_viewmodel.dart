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

  // Text editing controllers for two-way binding
  final TextEditingController noKKController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController kodePosController = TextEditingController();

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

      // Update controllers
      noKKController.text = noKK;
      alamatController.text = alamat;
      kodePosController.text = kodePos;

      fotoKKUrl = result.imgRef;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Apply scan results to form fields
  void applyScanResults({
    String? scannedNoKK,
    String? scannedAlamat,
    String? scannedKodePos,
    File? scannedFoto,
  }) {
    if (scannedNoKK != null && scannedNoKK.isNotEmpty) {
      noKK = scannedNoKK;
      noKKController.text = scannedNoKK;
    }
    if (scannedAlamat != null && scannedAlamat.isNotEmpty) {
      alamat = scannedAlamat;
      alamatController.text = scannedAlamat;
    }
    if (scannedKodePos != null && scannedKodePos.isNotEmpty) {
      kodePos = scannedKodePos;
      kodePosController.text = scannedKodePos;
    }
    if (scannedFoto != null) {
      fotoKK = scannedFoto;
    }
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

  @override
  void dispose() {
    noKKController.dispose();
    alamatController.dispose();
    kodePosController.dispose();
    super.dispose();
  }
}
