import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/repositories/kegiatan_repository.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kegiatan_service.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/local/local_kegiatan_cache_service.dart';
import 'package:rukun_app_proyek4/services/utils/hive_service.dart';

class MockCloudKegiatan extends Mock implements CloudKegiatanService {}

void main() {
  late Directory tempDir;
  late HiveService hiveService;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    hiveService = HiveService();
    await hiveService.initForTest(tempDir.path);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    final authLocal = AuthLocalService(hiveService);
    await authLocal.clearToken();

    final cacheBox =
        await hiveService.openBox<dynamic>('offline_cache_kegiatan');
    await cacheBox.clear();
  });

  tearDownAll(() async {
    await hiveService.resetForTest();
    await tempDir.delete(recursive: true);
  });

  group('Kegiatan cache-only approach', () {
    test('getAllKegiatan returns cached data when token is null', () async {
      final mockCloud = MockCloudKegiatan();
      final authLocal = AuthLocalService(hiveService);

      final repo = KegiatanRepository(mockCloud, authLocal);

      final cache = KegiatanLocalCacheService();
      await cache.cacheKegiatanRawList([
        {
          'id': 1,
          'nama': 'Cached Kegiatan',
          'deskripsi': 'Deskripsi',
          'tanggal_mulai': DateTime(2026, 6, 1).toIso8601String(),
          'level': 'RT',
          'status': 'Dibuat',
          'rt_id': 1,
          'rw_id': 1,
        },
      ]);

      final result = await repo.getAllKegiatan();

      expect(result, isNotEmpty);
      expect(result.first.nama, 'Cached Kegiatan');
    });

    test('getKegiatanById returns cached data when offline', () async {
      final mockCloud = MockCloudKegiatan();
      final authLocal = AuthLocalService(hiveService);

      final repo = KegiatanRepository(mockCloud, authLocal);

      final cache = KegiatanLocalCacheService();
      await cache.cacheKegiatanRawList([
        {
          'id': 5,
          'nama': 'Kegiatan Detail',
          'deskripsi': 'Detail test',
          'tanggal_mulai': DateTime(2026, 6, 1).toIso8601String(),
          'level': 'RT',
          'status': 'Dibuat',
          'rt_id': 1,
          'rw_id': 1,
        },
      ]);

      final result = await repo.getKegiatanById(5);

      expect(result, isNotNull);
      expect(result!.nama, 'Kegiatan Detail');
    });

    test('createKegiatan throws when offline', () async {
      final mockCloud = MockCloudKegiatan();
      final authLocal = AuthLocalService(hiveService);
      await authLocal.saveToken('token-kegiatan');

      final repo = KegiatanRepository(mockCloud, authLocal);

      final kegiatan = Kegiatan(
        nama: 'Kegiatan Test',
        deskripsi: 'Deskripsi test',
        tanggalMulai: DateTime(2026, 6, 1),
        tanggalSelesai: DateTime(2026, 6, 2),
        level: KegiatanLevel.rt,
        status: KegiatanStatus.dibuat,
        rtId: 1,
        rwId: 1,
      );

      expect(
        () => repo.createKegiatan(kegiatan),
        throwsA(isA<Exception>()),
      );
    });
  });
}
