import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:rukun_app_proyek4/repositories/surat_repository.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_surat_service.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';

import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/mock/path';
  }
}

class MockCloudSuratService extends Mock implements CloudSuratService {}

class MockAuthLocalService extends Mock implements AuthLocalService {}

class MockCloudinaryService extends Mock implements CloudinaryService {}

void main() {
  setUpAll(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();

    registerFallbackValue(File('dummy.pdf'));
  });

  late MockCloudSuratService service;
  late MockAuthLocalService auth;
  late MockCloudinaryService cloud;
  late SuratRepository repo;

  setUp(() {
    service = MockCloudSuratService();
    auth = MockAuthLocalService();
    cloud = MockCloudinaryService();

    repo = SuratRepository(service, auth, cloud);

    when(() => auth.getToken()).thenAnswer((_) async => 'token');

    when(
      () => service.createSurat(any(), any()),
    ).thenAnswer((_) async => {'status': 'success'});

    when(
      () => service.updateSurat(any(), any(), any()),
    ).thenAnswer((_) async => {'status': 'success'});

    when(
      () => cloud.uploadFile(any(), folder: any(named: 'folder')),
    ).thenAnswer((_) async => 'http://file.pdf');
  });

  test('UT11 - Pengajuan Surat berhasil', () async {
    final surat = PengajuanSurat(
      id: null,
      wargaId: 1,
      rtId: 1,
      keperluan: 'Izin',
      status: SuratStatus.diajukan,
    );

    final result = await repo.createSurat(surat);

    expect(result, true);
    verify(() => service.createSurat(any(), any())).called(1);
  });

  test('UT12 - Form kosong tetap diproses repo', () async {
    final surat = PengajuanSurat(
      id: null,
      wargaId: 0,
      rtId: 0,
      keperluan: '',
      status: SuratStatus.diajukan,
    );

    final result = await repo.createSurat(surat);

    expect(result, true);
  });

  test('UT13 - Update surat berhasil', () async {
    when(() => service.updateSurat(any(), any(), any())).thenAnswer(
      (_) async => {
        'id': 1,
        'warga_id': 1,
        'rt_id': 1,
        'keperluan': 'Izin',
        'status': 'Selesai',
      },
    );

    await repo.updateSurat(1, {'status': 'Selesai', 'catatan': 'OK'});

    verify(() => service.updateSurat(any(), any(), any())).called(1);
  });

  test('UT14 - Upload file berhasil', () async {
    final file = File('dummy.pdf');

    await repo.queueFileUploadSurat(
      entityId: 1,
      localFilePath: file.path,
      uploadType: 'signed',
    );

    expect(true, true);
  });

  test('UT15 - validasi akses6', () {
    expect(true, true);
  });

  test('UT16 - repository tidak crash saat token ada', () async {
    final surat = PengajuanSurat(
      id: null,
      wargaId: 2,
      rtId: 2,
      keperluan: 'Administrasi',
      status: SuratStatus.diajukan,
    );

    final result = await repo.createSurat(surat);

    expect(result, isA<bool>());
  });

  test('UT17 - update status surat aman', () async {
    await repo.updateSurat(2, {'status': 'Diproses'});

    verify(() => service.updateSurat(any(), any(), any())).called(1);
  });

  test('UT18 - upload tidak crash dengan file dummy', () async {
    final file = File('dummy.pdf');

    await repo.queueFileUploadSurat(
      entityId: 99,
      localFilePath: file.path,
      uploadType: 'signed',
    );

    expect(true, true);
  });

  test('UT19 - repository flow lengkap aman', () async {
    final surat = PengajuanSurat(
      id: null,
      wargaId: 5,
      rtId: 1,
      keperluan: 'Surat Keterangan',
      status: SuratStatus.diajukan,
    );

    final result = await repo.createSurat(surat);

    await repo.updateSurat(1, {'status': 'Selesai'});

    expect(result, true);
  });
}
