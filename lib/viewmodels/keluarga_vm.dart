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

  Future<void> loadKK(int rtId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      kkList = await repository.getKKByRT(rtId);
    } catch (e) {
      errorMessage = e.toString();
      kkList = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadKK(currentRtId);
  }

  bool get hasData => kkList.isNotEmpty;
  bool get isEmpty => kkList.isEmpty && !isLoading;
}