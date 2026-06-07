import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:rukun_app_proyek4/services/local/local_penduduk_sync_service.dart';
import 'package:rukun_app_proyek4/services/local/offline_sync_status_service.dart';
import 'package:rukun_app_proyek4/services/utils/hive_service.dart';

// Unit Testing 09,10
void main() {
  late PendudukLocalSyncService service;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp();

    await HiveService().initForTest(dir.path);

    service = PendudukLocalSyncService();
  });

  tearDown(() async {
    await HiveService().resetForTest();
  });

  group('UT09 - Offline Queue Warga', () {
    test('Data tersimpan ke queue offline', () async {
      await service.queueCreateWarga(
        tempId: 999,
        payload: {"nama": "Budi", "nik": "3201010000000999"},
      );

      final queue = await service.readPendingActions();

      final captured = queue.first;

      expect(queue.length, 1);
      expect(captured['operation'], 'create');
      expect(captured['payload']['nama'], 'Budi');
      expect(captured['payload']['nik'], '3201010000000999');
    });
  });

  group('UT10 - Offline Sync Status', () {
    test('Pending count bertambah setelah queue dibuat', () async {
      await service.queueCreateWarga(tempId: 1000, payload: {"nama": "Andi"});

      await OfflineSyncStatusService.instance.refresh();

      final pending = OfflineSyncStatusService.instance.pendingCount.value;

      expect(pending, 1);
    });
  });
}
