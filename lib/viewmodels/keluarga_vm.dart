import 'package:flutter/foundation.dart';
import 'package:rukun_app_proyek4/models/keluarga.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';

class KeluargaVM extends ChangeNotifier {
  final KKRepository repository;

  KeluargaVM({required this.repository});

  List<Keluarga> kkList = [];

  bool isLoading = false;
  String? errorMessage;

  int currentRtId = 1;
  String currentRtLabel = '';

  Future<void> init() async {
    await loadKK(currentRtId);
  }

  Future<void> loadKK(int? rtId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final rtList = await repository.getRTList();

      if (rtList.isNotEmpty) {
        // Update state VM dengan data asli dari Hive
        currentRtId = rtList.first['id'] as int;
        currentRtLabel = rtList.first['name'] as String;
      } else if (rtId != null) {
        currentRtId = rtId;
      }

      // 2. Sekarang ambil data KK menggunakan ID yang sudah pasti benar
      kkList = await repository.getKKByRT(currentRtId);
    } catch (e) {
      errorMessage = e.toString();
      kkList = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteKK(int id) async {
    isLoading = true;
    notifyListeners();

    final success = await repository.deleteKK(id);

    if (success) {
      await loadKK(currentRtId); // Muat ulang data setelah hapus
    } else {
      errorMessage = "Gagal menghapus data.";
      isLoading = false;
      notifyListeners();
    }

    return success;
  }

  Future<void> refresh() async {
    await loadKK(currentRtId);
  }

  bool get hasData => kkList.isNotEmpty;
  bool get isEmpty => kkList.isEmpty && !isLoading;
}