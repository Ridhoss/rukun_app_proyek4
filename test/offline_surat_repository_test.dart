import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/repositories/surat_repository.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_surat_service.dart';
import 'package:rukun_app_proyek4/services/utils/hive_service.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';
import 'package:rukun_app_proyek4/services/local/local_surat_cache_service.dart';
import 'package:rukun_app_proyek4/utils/connectivity_helper.dart';

class MockCloudSurat extends Mock implements CloudSuratService {}

class MockCloudinary extends Mock implements CloudinaryService {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late Directory tempDir;
  late HiveService hiveService;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp();
    hiveService = HiveService();
    await hiveService.initForTest(tempDir.path);
    ConnectivityHelper.init(MockConnectivity());
  });

  tearDownAll(() async {
    await hiveService.resetForTest();
    await tempDir.delete(recursive: true);
  });

  group('Surat cache-only approach', () {
    test('getAllSurat returns cached data when token is null', () async {
      final mockCloud = MockCloudSurat();
      final mockCloudinary = MockCloudinary();
      final authLocal = AuthLocalService(hiveService);

      final repo = SuratRepository(mockCloud, authLocal, mockCloudinary);

      final cache = SuratLocalCacheService();
      await cache.cacheSuratAllList([
        PengajuanSurat(id: 1, keperluan: 'Test Surat', wargaId: 1, rtId: 1),
      ]);

      final result = await repo.getAllSurat();

      expect(result, isNotEmpty);
      expect(result.first.keperluan, 'Test Surat');
    });

    test('getSuratSaya returns cached data when token is null', () async {
      final mockCloud = MockCloudSurat();
      final mockCloudinary = MockCloudinary();
      final authLocal = AuthLocalService(hiveService);

      final repo = SuratRepository(mockCloud, authLocal, mockCloudinary);

      final cache = SuratLocalCacheService();
      await cache.cacheSuratSayaList([
        PengajuanSurat(id: 2, keperluan: 'Surat Saya', wargaId: 1, rtId: 1),
      ]);

      final result = await repo.getSuratSaya();

      expect(result, isNotEmpty);
      expect(result.first.keperluan, 'Surat Saya');
    });

    test('createSurat throws when offline', () async {
      final mockCloud = MockCloudSurat();
      final mockCloudinary = MockCloudinary();
      final authLocal = AuthLocalService(hiveService);
      await authLocal.saveToken('token-xyz');

      final repo = SuratRepository(mockCloud, authLocal, mockCloudinary);

      final surat = PengajuanSurat(
        wargaId: 1,
        rtId: 1,
        keperluan: 'Surat Keterangan',
      );

      expect(
        () => repo.createSurat(surat),
        throwsA(isA<Exception>()),
      );
    });
  });
}
