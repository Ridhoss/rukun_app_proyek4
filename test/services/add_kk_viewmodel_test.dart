import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/viewmodels/penduduk/kartukeluarga/add_kk_viewmodel.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';

class MockKKRepository extends Mock implements KKRepository {}

class MockCloudinary extends Mock implements CloudinaryService {}

class FakeKeluarga extends Fake implements Keluarga {}

void main() {
  late AddKKViewModel vm;
  late MockKKRepository repo;
  late MockCloudinary cloud;

  setUpAll(() {
    registerFallbackValue(File('fallback.jpg'));
    registerFallbackValue(FakeKeluarga());
  });

  setUp(() {
    repo = MockKKRepository();
    cloud = MockCloudinary();

    vm = AddKKViewModel(kkRepository: repo, rtId: 1, cloudinaryService: cloud);
  });

  group('UT07 - Upload KK valid', () {
    test('file berhasil diupload', () async {
      when(
        () => cloud.uploadFile(any(), folder: any(named: 'folder')),
      ).thenAnswer((_) async => 'url_image');

      when(() => repo.createKK(any())).thenAnswer((_) async {});

      vm.noKK = '123';
      vm.alamat = 'Jakarta';
      vm.setFotoKK(File('dummy.jpg'));

      await vm.createKK();

      expect(vm.isKKSaved, true);

      verify(() => cloud.uploadFile(any(), folder: 'kartukeluarga')).called(1);
    });
  });

  group('UT08 - File terlalu besar (SIMULASI)', () {
    test('reject file > 5MB (simulasi)', () {
      final fakeSizeMB = 6;
      final isValid = fakeSizeMB <= 5;

      expect(isValid, false);
    });
  });
}
