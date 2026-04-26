import 'package:rukun_app_proyek4/models/keluarga.dart';
import 'package:rukun_app_proyek4/services/local/local_kk_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kk_service.dart';
import 'package:rukun_app_proyek4/services/warga_service.dart';

class KKRepository {
  final CloudKKService cloud;
  final LocalKkService local;
  final WargaService syncService; // <-- Pastikan ini ada

  KKRepository({
    required this.cloud,
    required this.local,
    required this.syncService, // <-- Pastikan ini ada
  });

  bool isOnline = true;

  Future<List<Keluarga>> getKKByRT(int rtId) async {
    if (isOnline) {
      try {
        final data = await cloud.getKKByRT(rtId);
        await _cacheToLocal(data);
        return data;
      } catch (e) {
        return await local.getKKByRT(rtId);
      }
    } else {
      return await local.getKKByRT(rtId);
    }
  }

  Future<void> _cacheToLocal(List<Keluarga> data) async {
    for (final kk in data) {
      await local.saveKKLocalOnly(kk);
    }
  }

  Future<bool> saveKK(Keluarga kk) async {
    return await syncService.saveKK(kk);
  }

  Future<List<Map<String, dynamic>>> getRTList() async {
    return await syncService.getRTList();
  }

  Future<bool> deleteKK(int id) async {
    return await syncService.deleteKK(id.toString());
  }

  String? get lastError => syncService.lastError;
  int? get lastSavedKKId => syncService.lastSavedKKId;
}