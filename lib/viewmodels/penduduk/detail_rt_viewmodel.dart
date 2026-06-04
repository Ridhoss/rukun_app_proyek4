import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';

class DetailRTViewmodel extends ChangeNotifier {
  final KKRepository kkRepository;

  DetailRTViewmodel({required this.kkRepository});

  bool isLoading = false;
  String? errorMessage;

  List<Keluarga> kkList = [];

  int? currentRtId;

  void init(int rtId) {
    currentRtId = rtId;
    // Delay loading until after build phase completes
    Future.microtask(() => loadKK(rtId));
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