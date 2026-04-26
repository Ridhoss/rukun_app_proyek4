import 'package:rukun_app_proyek4/models/warga.dart';
import 'package:rukun_app_proyek4/services/warga_service.dart';

class WargaRepository {
  final WargaService _localService;
  // Jika nanti ada CloudWargaService untuk API, tambahkan di sini

  WargaRepository({required WargaService localService})
      : _localService = localService;

  Future<bool> saveWarga(WargaModel warga) async {
    return await _localService.saveWarga(warga);
  }

  Future<bool> updateWarga(String id, WargaModel warga) async {
    return await _localService.updateWarga(id, warga);
  }

  Future<List<WargaModel>> getWargaByKK(int kkId) async {
    return await _localService.getWargaByKK(kkId);
  }

  Future<bool> deleteWarga(String id) async {
    return await _localService.deleteWarga(id);
  }

  String? get lastError => _localService.lastError;
}