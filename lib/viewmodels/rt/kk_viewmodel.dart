import 'package:flutter/foundation.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';

class KeluargaVM extends ChangeNotifier {
  final KKRepository kkRepository;

  KeluargaVM({required this.kkRepository});

  bool isLoading = false;
  String? errorMessage;

  List<Keluarga> kkList = [];

  int? currentRtId;

  Future<void> init(int rtId) async {
    currentRtId = rtId;
    await loadKK(rtId);
  }

  Future<void> loadKK(int? rtId) async {
    if (rtId == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      kkList = await kkRepository.getKKByRT(rtId);
    } catch (e) {
      errorMessage = 'Gagal load data KK';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteKK(int id) async {
    try {
      await kkRepository.deleteKK(id);

      // reload setelah delete
      await loadKK(currentRtId);
    } catch (e) {
      errorMessage = 'Gagal hapus KK';
      notifyListeners();
    }
  }
}