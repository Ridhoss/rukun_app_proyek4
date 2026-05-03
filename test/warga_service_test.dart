// import 'dart:io';

// import 'package:flutter_test/flutter_test.dart';
// import 'package:rukun_app_proyek4/models/keluarga.dart';
// import 'package:rukun_app_proyek4/models/warga.dart';
// import 'package:rukun_app_proyek4/services/hive_service.dart';
// import 'package:rukun_app_proyek4/services/warga_service.dart';

// void main() {
//   late Directory tempDir;
//   final hiveService = HiveService();
//   final service = WargaService();

//   setUpAll(() async {
//     tempDir = await Directory.systemTemp.createTemp('warga-service-test');
//     await hiveService.initForTest(tempDir.path);
//     await service.setCurrentRTContext(rtId: 1, rtLabel: 'RT 001');
//   });

//   tearDownAll(() async {
//     await hiveService.resetForTest();
//     await tempDir.delete(recursive: true);
//   });

//   test('saveKK sukses di RT aktif', () async {
//     final ok = await service.saveKK(
//       Keluarga(
//         noKK: '3171011111111111',
//         rtId: 1,
//         alamat: 'Jl. Anggrek 10',
//         kodePos: '40535',
//       ),
//     );

//     expect(ok, isTrue);
//     expect(service.lastSavedKKId, isNotNull);
//   });

//   test('enqueue sync menyimpan metadata retry untuk operasi lokal', () async {
//     final ok = await service.saveKK(
//       Keluarga(
//         noKK: '3171016666666666',
//         rtId: 1,
//         alamat: 'Jl. Sakura 77',
//         kodePos: '40535',
//       ),
//     );

//     expect(ok, isTrue);

//     final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//     final entries = queueBox.values.whereType<Map>().toList();
//     expect(entries, isNotEmpty);

//     final latest = Map<String, dynamic>.from(entries.last);
//     expect(latest['sync_status'], 'pending');
//     expect(latest['retry_count'], 0);
//     expect(latest.containsKey('last_error'), isTrue);
//     expect(latest['last_error'], isNull);
//     expect(latest.containsKey('attempted_at'), isTrue);
//     expect(latest['attempted_at'], isNull);
//     expect(latest.containsKey('next_retry_at'), isTrue);
//     expect(latest['next_retry_at'], isNull);
//   });

//   test(
//     'getPendingSyncQueue hanya mengembalikan item pending yang due',
//     () async {
//       final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//       await queueBox.clear();

//       final now = DateTime.now();
//       await queueBox.put(1, {
//         'id': 1,
//         'sync_status': 'pending',
//         'next_retry_at': null,
//         'created_at': now.toIso8601String(),
//       });
//       await queueBox.put(2, {
//         'id': 2,
//         'sync_status': 'pending',
//         'next_retry_at': now.add(const Duration(minutes: 5)).toIso8601String(),
//         'created_at': now.toIso8601String(),
//       });
//       await queueBox.put(3, {
//         'id': 3,
//         'sync_status': 'synced',
//         'next_retry_at': null,
//         'created_at': now.toIso8601String(),
//       });
//       await queueBox.put(4, {
//         'id': 4,
//         'sync_status': 'pending',
//         'next_retry_at': now
//             .subtract(const Duration(minutes: 5))
//             .toIso8601String(),
//         'created_at': now.toIso8601String(),
//       });

//       final pending = await service.getPendingSyncQueue();
//       final pendingIds = pending.map((item) => item['id']).toList();

//       expect(pendingIds, contains(1));
//       expect(pendingIds, contains(4));
//       expect(pendingIds, isNot(contains(2)));
//       expect(pendingIds, isNot(contains(3)));
//     },
//   );

//   test('transisi queue pending -> processing -> synced', () async {
//     final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//     await queueBox.clear();

//     await queueBox.put(100, {
//       'id': 100,
//       'sync_status': 'pending',
//       'retry_count': 0,
//       'last_error': null,
//       'attempted_at': null,
//       'next_retry_at': null,
//       'created_at': DateTime.now().toIso8601String(),
//     });

//     final processingOk = await service.markSyncProcessing(100);
//     expect(processingOk, isTrue);

//     final processingItem = Map<String, dynamic>.from(queueBox.get(100) as Map);
//     expect(processingItem['sync_status'], 'processing');
//     expect(processingItem['attempted_at'], isNotNull);

//     final successOk = await service.markSyncSuccess(100);
//     expect(successOk, isTrue);

//     final successItem = Map<String, dynamic>.from(queueBox.get(100) as Map);
//     expect(successItem['sync_status'], 'synced');
//     expect(successItem['last_error'], isNull);
//     expect(successItem['next_retry_at'], isNull);
//   });

//   test(
//     'transisi queue pending -> failed menaikkan retry dan jadwal ulang',
//     () async {
//       final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//       await queueBox.clear();

//       await queueBox.put(200, {
//         'id': 200,
//         'sync_status': 'pending',
//         'retry_count': 0,
//         'last_error': null,
//         'attempted_at': null,
//         'next_retry_at': null,
//         'created_at': DateTime.now().toIso8601String(),
//       });

//       final failedOk = await service.markSyncFailed(200, error: 'timeout');
//       expect(failedOk, isTrue);

//       final failedItem = Map<String, dynamic>.from(queueBox.get(200) as Map);
//       expect(failedItem['sync_status'], 'failed');
//       expect(failedItem['retry_count'], 1);
//       expect(failedItem['last_error'], 'timeout');
//       expect(failedItem['attempted_at'], isNotNull);
//       expect(failedItem['next_retry_at'], isNotNull);
//     },
//   );

//   test('failed item yang belum due tidak muncul di pending due list', () async {
//     final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//     await queueBox.clear();

//     final now = DateTime.now();
//     await queueBox.put(300, {
//       'id': 300,
//       'sync_status': 'failed',
//       'retry_count': 1,
//       'last_error': 'timeout',
//       'attempted_at': now.toIso8601String(),
//       'next_retry_at': now.add(const Duration(minutes: 10)).toIso8601String(),
//       'created_at': now.toIso8601String(),
//     });
//     await queueBox.put(301, {
//       'id': 301,
//       'sync_status': 'failed',
//       'retry_count': 1,
//       'last_error': 'timeout',
//       'attempted_at': now.toIso8601String(),
//       'next_retry_at': now
//           .subtract(const Duration(minutes: 10))
//           .toIso8601String(),
//       'created_at': now.toIso8601String(),
//     });

//     final due = await service.getPendingSyncQueue();
//     final ids = due.map((item) => item['id']).toList();

//     expect(ids, contains(301));
//     expect(ids, isNot(contains(300)));
//   });

//   test('helper observability queue status dan stats berjalan', () async {
//     final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//     await queueBox.clear();

//     final now = DateTime.now();
//     await queueBox.put(400, {
//       'id': 400,
//       'sync_status': 'pending',
//       'next_retry_at': null,
//       'created_at': now.toIso8601String(),
//     });
//     await queueBox.put(401, {
//       'id': 401,
//       'sync_status': 'processing',
//       'next_retry_at': null,
//       'created_at': now.toIso8601String(),
//     });
//     await queueBox.put(402, {
//       'id': 402,
//       'sync_status': 'synced',
//       'next_retry_at': null,
//       'created_at': now.toIso8601String(),
//     });
//     await queueBox.put(403, {
//       'id': 403,
//       'sync_status': 'failed',
//       'next_retry_at': now.add(const Duration(minutes: 2)).toIso8601String(),
//       'created_at': now.toIso8601String(),
//     });

//     final failed = await service.getSyncQueueByStatus('failed');
//     expect(failed.length, 1);
//     expect(failed.first['id'], 403);

//     final stats = await service.getSyncQueueStats();
//     expect(stats['total'], 4);
//     expect(stats['pending'], 1);
//     expect(stats['processing'], 1);
//     expect(stats['synced'], 1);
//     expect(stats['failed'], 1);
//     expect(stats['retryable'], 1);
//   });

//   test('processPendingSyncQueue menandai item sukses sebagai synced', () async {
//     final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//     await queueBox.clear();

//     await queueBox.put(500, {
//       'id': 500,
//       'entity': 'warga',
//       'operation': 'create',
//       'entity_id': 99,
//       'payload': {'foo': 'bar'},
//       'sync_status': 'pending',
//       'retry_count': 0,
//       'last_error': null,
//       'attempted_at': null,
//       'next_retry_at': null,
//       'created_at': DateTime.now().toIso8601String(),
//     });

//     final result = await service.processPendingSyncQueue(
//       processor: (queueItem) async {},
//     );

//     expect(result['picked'], 1);
//     expect(result['success'], 1);
//     expect(result['failed'], 0);
//     expect(result['skipped'], 0);

//     final updated = Map<String, dynamic>.from(queueBox.get(500) as Map);
//     expect(updated['sync_status'], 'synced');
//     expect(updated['last_error'], isNull);
//     expect(updated['next_retry_at'], isNull);
//   });

//   test('processPendingSyncQueue menandai item gagal sebagai failed', () async {
//     final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//     await queueBox.clear();

//     await queueBox.put(501, {
//       'id': 501,
//       'entity': 'warga',
//       'operation': 'update',
//       'entity_id': 100,
//       'payload': {'foo': 'bar'},
//       'sync_status': 'pending',
//       'retry_count': 0,
//       'last_error': null,
//       'attempted_at': null,
//       'next_retry_at': null,
//       'created_at': DateTime.now().toIso8601String(),
//     });

//     final result = await service.processPendingSyncQueue(
//       processor: (queueItem) async {
//         throw Exception('network down');
//       },
//     );

//     expect(result['picked'], 1);
//     expect(result['success'], 0);
//     expect(result['failed'], 1);
//     expect(result['skipped'], 0);

//     final updated = Map<String, dynamic>.from(queueBox.get(501) as Map);
//     expect(updated['sync_status'], 'failed');
//     expect(updated['retry_count'], 1);
//     expect((updated['last_error'] as String), contains('network down'));
//     expect(updated['next_retry_at'], isNotNull);
//   });

//   test(
//     'forceRetryQueueItem mengubah failed item menjadi pending langsung',
//     () async {
//       final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//       await queueBox.clear();

//       await queueBox.put(600, {
//         'id': 600,
//         'sync_status': 'failed',
//         'retry_count': 2,
//         'last_error': 'timeout',
//         'attempted_at': DateTime.now().toIso8601String(),
//         'next_retry_at': DateTime.now()
//             .add(const Duration(minutes: 10))
//             .toIso8601String(),
//         'created_at': DateTime.now().toIso8601String(),
//       });

//       final ok = await service.forceRetryQueueItem(600);
//       expect(ok, isTrue);

//       final updated = Map<String, dynamic>.from(queueBox.get(600) as Map);
//       expect(updated['sync_status'], 'pending');
//       expect(updated['next_retry_at'], isNull);
//       expect(updated['last_error'], isNull);
//       expect(updated['retry_count'], 2);
//     },
//   );

//   test(
//     'resetStaleProcessingQueue mereset processing item yang stale',
//     () async {
//       final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//       await queueBox.clear();

//       final now = DateTime.now();
//       await queueBox.put(610, {
//         'id': 610,
//         'sync_status': 'processing',
//         'attempted_at': now
//             .subtract(const Duration(minutes: 20))
//             .toIso8601String(),
//         'created_at': now.toIso8601String(),
//       });
//       await queueBox.put(611, {
//         'id': 611,
//         'sync_status': 'processing',
//         'attempted_at': now
//             .subtract(const Duration(minutes: 2))
//             .toIso8601String(),
//         'created_at': now.toIso8601String(),
//       });

//       final affected = await service.resetStaleProcessingQueue(
//         olderThan: const Duration(minutes: 5),
//       );
//       expect(affected, 1);

//       final stale = Map<String, dynamic>.from(queueBox.get(610) as Map);
//       final fresh = Map<String, dynamic>.from(queueBox.get(611) as Map);

//       expect(stale['sync_status'], 'failed');
//       expect(stale['last_error'], 'Recovered stale processing item');
//       expect(stale['next_retry_at'], isNotNull);
//       expect(fresh['sync_status'], 'processing');
//     },
//   );

//   test('purgeSyncedQueue menghapus item synced yang sudah lama', () async {
//     final queueBox = await hiveService.openBox<dynamic>('sync_queue_offline');
//     await queueBox.clear();

//     final now = DateTime.now();
//     await queueBox.put(620, {
//       'id': 620,
//       'sync_status': 'synced',
//       'attempted_at': now.subtract(const Duration(days: 10)).toIso8601String(),
//       'created_at': now.toIso8601String(),
//     });
//     await queueBox.put(621, {
//       'id': 621,
//       'sync_status': 'synced',
//       'attempted_at': now.subtract(const Duration(days: 2)).toIso8601String(),
//       'created_at': now.toIso8601String(),
//     });
//     await queueBox.put(622, {
//       'id': 622,
//       'sync_status': 'pending',
//       'created_at': now.toIso8601String(),
//     });

//     final removed = await service.purgeSyncedQueue(
//       olderThan: const Duration(days: 7),
//     );
//     expect(removed, 1);
//     expect(queueBox.get(620), isNull);
//     expect(queueBox.get(621), isNotNull);
//     expect(queueBox.get(622), isNotNull);
//   });

//   test('saveKK gagal jika no KK duplikat', () async {
//     await service.saveKK(
//       Keluarga(
//         noKK: '3171012222222222',
//         rtId: 1,
//         alamat: 'Jl. Mawar 12',
//         kodePos: '40535',
//       ),
//     );

//     final second = await service.saveKK(
//       Keluarga(
//         noKK: '3171012222222222',
//         rtId: 1,
//         alamat: 'Jl. Melati 14',
//         kodePos: '40535',
//       ),
//     );

//     expect(second, isFalse);
//     expect(service.lastError, 'No. KK sudah terdaftar.');
//   });

//   test('saveKK gagal jika RT tidak sesuai konteks', () async {
//     final ok = await service.saveKK(
//       Keluarga(
//         noKK: '3171013333333333',
//         rtId: 2,
//         alamat: 'Jl. Kenanga 2',
//         kodePos: '40535',
//       ),
//     );

//     expect(ok, isFalse);
//     expect(
//       service.lastError,
//       'RT tidak sesuai konteks login. Anda hanya bisa input RT aktif.',
//     );
//   });

//   test('saveWarga gagal saat NIK duplikat', () async {
//     await service.saveKK(
//       Keluarga(
//         noKK: '3171014444444444',
//         rtId: 1,
//         alamat: 'Jl. Flamboyan 7',
//         kodePos: '40535',
//       ),
//     );

//     final keluargaId = service.lastSavedKKId!;

//     final warga1 = WargaModel(
//       nama: 'Andi',
//       nik: '3201010101010001',
//       jk: 'Laki-laki',
//       tempatLahir: 'Bandung',
//       agama: 'Islam',
//       pendidikan: 'S1',
//       jenisPekerjaan: 'Wiraswasta',
//       golonganDarah: 'O',
//       statusPerkawinan: 'Kawin',
//       statusHubungan: 'Kepala Keluarga',
//       kewarganegaraan: 'WNI',
//       namaAyah: 'Bapak A',
//       namaIbu: 'Ibu A',
//       keluargaId: keluargaId,
//     );

//     final warga2 = WargaModel(
//       nama: 'Budi',
//       nik: '3201010101010001',
//       jk: 'Laki-laki',
//       tempatLahir: 'Bandung',
//       agama: 'Islam',
//       pendidikan: 'SMA/Sederajat',
//       jenisPekerjaan: 'Karyawan Swasta',
//       golonganDarah: 'A',
//       statusPerkawinan: 'Belum Kawin',
//       statusHubungan: 'Anak',
//       kewarganegaraan: 'WNI',
//       namaAyah: 'Bapak B',
//       namaIbu: 'Ibu B',
//       keluargaId: keluargaId,
//     );

//     final first = await service.saveWarga(warga1);
//     final second = await service.saveWarga(warga2);

//     expect(first, isTrue);
//     expect(second, isFalse);
//     expect(service.lastError, 'NIK sudah terdaftar.');
//   });

//   test('saveWarga gagal jika keluarga berada di RT lain', () async {
//     await service.setCurrentRTContext(rtId: 2, rtLabel: 'RT 002');
//     await service.saveKK(
//       Keluarga(
//         noKK: '3171015555555555',
//         rtId: 2,
//         alamat: 'Jl. Cempaka 99',
//         kodePos: '40535',
//       ),
//     );
//     final rt2KeluargaId = service.lastSavedKKId!;

//     await service.setCurrentRTContext(rtId: 1, rtLabel: 'RT 001');

//     final warga = WargaModel(
//       nama: 'Cici',
//       nik: '3201010101010002',
//       jk: 'Perempuan',
//       tempatLahir: 'Bandung',
//       agama: 'Islam',
//       pendidikan: 'S1',
//       jenisPekerjaan: 'Pelajar/Mahasiswa',
//       golonganDarah: 'B',
//       statusPerkawinan: 'Belum Kawin',
//       statusHubungan: 'Anak',
//       kewarganegaraan: 'WNI',
//       namaAyah: 'Bapak C',
//       namaIbu: 'Ibu C',
//       keluargaId: rt2KeluargaId,
//     );

//     final ok = await service.saveWarga(warga);

//     expect(ok, isFalse);
//     expect(
//       service.lastError,
//       'Anda tidak bisa menambah warga di KK milik RT lain.',
//     );
//   });
// }
