import 'package:rukun_app_proyek4/models/keluarga.dart';
import 'package:rukun_app_proyek4/services/local/local_kk_service.dart';
import '../services/cloud/cloud_kk_service.dart';

class KKRepository {
  final CloudKKService cloud;
  final LocalKkService local;

  KKRepository({
    required this.cloud,
    required this.local,
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

}