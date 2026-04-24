import 'package:rukun_app_proyek4/services/warga_service.dart';

class AuthContextService {
  Future<void> applyLoginRTContext({required int rtId, String? rtLabel}) async {
    await WargaService().setCurrentRTContext(rtId: rtId, rtLabel: rtLabel);
  }

  Future<void> applyLoginRTContextFromPayload(
    Map<String, dynamic> payload,
  ) async {
    final dynamic rawRtId = payload['rt_id'] ?? payload['rtId'];
    final int? rtId = _toInt(rawRtId);
    if (rtId == null) {
      throw StateError('rt_id tidak ditemukan di payload login');
    }

    final String? rtLabel =
        (payload['rt_label'] ?? payload['rtLabel']) as String?;
    await applyLoginRTContext(rtId: rtId, rtLabel: rtLabel);
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
