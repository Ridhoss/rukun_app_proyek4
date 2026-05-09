import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';

class DetailKKViewModel extends ChangeNotifier {
  final WargaRepository repo;
  final int kkId;

  DetailKKViewModel({
    required this.repo,
    required this.kkId,
  });

  List<Warga> anggota = [];

  bool isLoadingAnggota = false;
  String? anggotaError;

  Future<void> fetchAnggota() async {
    try {
      isLoadingAnggota = true;
      anggotaError = null;
      notifyListeners();

      anggota = await repo.getWargaByKeluarga(kkId);
    } catch (e) {
      anggotaError = e.toString();
    } finally {
      isLoadingAnggota = false;
      notifyListeners();
    }
  }
}