import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';

class AddKKViewModel extends ChangeNotifier {
  final KKRepository kkRepository;
  final int rtId;

  AddKKViewModel({
    required this.kkRepository,
    required this.rtId,
  });

  bool isSaving = false;
  bool isKKSaved = false;
  String? errorMessage;

  Keluarga? kk;

  String noKK = '';
  String alamat = '';
  String kodePos = '';

  Future<void> createKK() async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = Keluarga(
        noKK: noKK,
        rtId: rtId,
        alamat: alamat,
        kodePos: kodePos,
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