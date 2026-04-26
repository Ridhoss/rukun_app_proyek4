import 'package:flutter/foundation.dart';
import 'package:rukun_app_proyek4/models/keluarga.dart';
import 'package:rukun_app_proyek4/models/warga.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';

class KKViewModel extends ChangeNotifier {
  final KKRepository kkRepository;
  final WargaRepository wargaRepository;

  KKViewModel({
    required this.kkRepository,
    required this.wargaRepository,
  });

  bool isLoadingRT = true;
  bool isLoadingKK = false;
  bool kkSaved = false;
  String? errorMessage;
  List<Map<String, dynamic>> rtList = [];
  int? selectedRTId;
  int? savedKKId;
  List<WargaModel> anggotaList = [];

  Future<void> init({Keluarga? editData}) async {
    await loadRTList();
    if (editData != null) {
      selectedRTId = editData.rtId;
      kkSaved = true;
      savedKKId = editData.id;
      if (editData.id != null) {
        anggotaList = await wargaRepository.getWargaByKK(editData.id!);
      }
    }
    notifyListeners();
  }

  Future<void> loadRTList() async {
    isLoadingRT = true;
    notifyListeners();
    rtList = await kkRepository.getRTList();
    isLoadingRT = false;
    notifyListeners();
  }

  Future<bool> saveKK(Keluarga kk) async {
    isLoadingKK = true;
    errorMessage = null;
    notifyListeners();

    final success = await kkRepository.saveKK(kk);

    isLoadingKK = false;
    if (success) {
      kkSaved = true;
      savedKKId = kkRepository.lastSavedKKId;
    } else {
      errorMessage = kkRepository.lastError ?? 'Gagal menyimpan KK.';
    }
    notifyListeners();
    return success;
  }

  void unlockKK() {
    kkSaved = false;
    notifyListeners();
  }

  void selectRT(int? id) {
    selectedRTId = id;
    notifyListeners();
  }

  void addAnggota(WargaModel warga) {
    anggotaList = [...anggotaList, warga];
    notifyListeners();
  }

  void updateAnggota(int index, WargaModel updated) {
    final list = [...anggotaList];
    list[index] = updated;
    anggotaList = list;
    notifyListeners();
  }

  Future<void> removeAnggota(int index) async {
    final wargaId = anggotaList[index].id;
    if (wargaId != null) {
      await wargaRepository.deleteWarga(wargaId.toString());
    }
    final list = [...anggotaList];
    list.removeAt(index);
    anggotaList = list;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}