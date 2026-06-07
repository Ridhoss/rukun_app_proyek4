import 'package:flutter/foundation.dart';
import 'package:rukun_app_proyek4/services/utils/hive_service.dart';

class OfflineSyncStatusService {
  OfflineSyncStatusService._();

  static final OfflineSyncStatusService instance = OfflineSyncStatusService._();

  static const List<String> _queueBoxNames = [
    'offline_sync_penduduk',
    'offline_sync_surat',
    'offline_sync_iuran',
    'offline_sync_setoran',
    'offline_sync_kegiatan',
  ];

  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);

  VoidCallback? onQueueChanged;

  Future<void> refresh() async {
    final oldCount = pendingCount.value;
    pendingCount.value = await _countPendingActions();

    if (pendingCount.value > oldCount) {
      onQueueChanged?.call();
    }
  }

  Future<int> _countPendingActions() async {
    final hive = HiveService();
    var total = 0;

    for (final boxName in _queueBoxNames) {
      final box = await hive.openBox<dynamic>(boxName);
      total += box.length;
    }

    return total;
  }
}
