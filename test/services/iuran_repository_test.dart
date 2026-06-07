import 'dart:io';

import 'package:dio/dio.dart' show RequestOptions;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rukun_app_proyek4/repositories/iuran_repository.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_iuran_service.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';

import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';

import 'surat_repository_test.dart';

class MockCloudIuranService extends Mock implements CloudIuranService {}

class MockAuthLocalService extends Mock implements AuthLocalService {}

void main() {
  late MockCloudIuranService service;
  late MockAuthLocalService auth;
  late IuranRepository repo;

  // 👉 MOCK CHANNEL PATH PROVIDER (INI KUNCI FIX)
  const MethodChannel pathProviderChannel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    registerFallbackValue(<String, dynamic>{});

    // 🔥 MOCK path_provider supaya tidak panggil native plugin
    pathProviderChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/mock/documents';
      }
      return null;
    });
  });

  setUp(() {
    service = MockCloudIuranService();
    auth = MockAuthLocalService();

    repo = IuranRepository(service, auth);

    when(() => auth.getToken()).thenAnswer((_) async => 'token');

    when(
      () => service.createIuran(any(), any()),
    ).thenAnswer((_) async => {"status": "success", "data": {}});

    when(
      () => service.updateIuran(any(), any(), any()),
    ).thenAnswer((_) async => {"status": "success", "data": {}});

    when(
      () => service.deleteIuran(any(), any()),
    ).thenAnswer((_) async => {"status": "success", "data": {}});

    when(
      () => service.createTransaksi(any(), any()),
    ).thenAnswer((_) async => {"status": "success", "data": {}});
  });

  test('UT16 - create iuran', () async {
    final iuran = Iuran(
      id: null,
      nama: "Iuran Bulanan",
      jumlah: 10000,
      level: IuranLevel.rw,
      tipe: IuranType.reguler,
    );

    await repo.createIuran(iuran);

    verify(() => service.createIuran(any(), any())).called(1);
  });

  test('UT17 - Validasi Tagihan Ganda', () async {
    final iuran = Iuran(
      id: null,
      nama: "Iuran Bulanan",
      jumlah: 10000,
      level: IuranLevel.rw,
      tipe: IuranType.reguler,
    );

    when(
      () => service.createIuran(any(), any()),
    ).thenThrow(Exception("Tagihan periode sudah ada"));

    expect(() async => repo.createIuran(iuran), throwsException);

    verify(() => service.createIuran(any(), any())).called(1);
  });

}
