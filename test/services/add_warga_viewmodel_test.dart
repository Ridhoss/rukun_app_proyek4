import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';
import 'package:rukun_app_proyek4/viewmodels/penduduk/warga/add_warga_viewmodel.dart';

class MockWargaRepository extends Mock implements WargaRepository {}

class FakeWarga extends Fake implements Warga {}

void main() {
  late MockWargaRepository repo;
  late AddWargaViewModel vm;

  setUpAll(() {
    registerFallbackValue(FakeWarga());
  });

  setUp(() {
    repo = MockWargaRepository();

    vm = AddWargaViewModel(repo: repo, kkId: 1);
  });

  Keluarga createDummyKK({int id = 1}) {
    return Keluarga(
      id: id,
      noKK: '3174010101010001',
      rtId: 1,
      alamat: 'Jakarta',
      kodePos: '12345',
    );
  }

  group('UT01 - Input Data Warga WNI', () {
    test('Menambahkan data warga WNI lengkap berhasil', () async {
      when(() => repo.createWarga(any())).thenAnswer((_) async {});

      vm.setNama('Budi');
      vm.setNik('3201010000000001');
      vm.setJenisKelamin('Laki-Laki');
      vm.setKewarganegaraan('WNI');

      final keluarga = createDummyKK();

      final result = await vm.saveWarga(keluarga);

      expect(result, true);

      verify(() => repo.createWarga(any())).called(1);
    });
  });

  group('UT02 - Validasi NIK', () {
    test('UT02 - NIK kurang dari 16 digit ditolak', () async {
      final repo = MockWargaRepository();

      when(() => repo.createWarga(any())).thenAnswer((_) async {});

      final vm = AddWargaViewModel(repo: repo, kkId: 1);

      vm.setNama('Budi');
      vm.setNik('0202020202');
      vm.setJenisKelamin('Laki-Laki');

      final keluarga = Keluarga(
        id: 1,
        noKK: '002',
        rtId: 1, 
      );

      final result = await vm.saveWarga(keluarga);

      expect(result, false);
      expect(vm.errorMessage, 'NIK harus 16 digit');
    });
  });

  group('UT03 - Validasi Nama', () {
    test('Nama kosong menampilkan error', () async {
      vm.setNama('');
      vm.setNik('3201010000000001');
      vm.setJenisKelamin('Laki-Laki');

      final keluarga = createDummyKK();

      final result = await vm.saveWarga(keluarga);

      expect(result, false);

      expect(vm.errorMessage, 'Nama wajib diisi');

      verifyNever(() => repo.createWarga(any()));
    });
  });

  group('UT04 - Data Keluarga', () {
    test('Warga terhubung ke KK tertentu', () async {
      when(() => repo.createWarga(any())).thenAnswer((_) async {});

      vm.setNama('Andi');
      vm.setNik('1234567890123456');
      vm.setJenisKelamin('Laki-Laki');

      final keluarga = createDummyKK(id: 10);

      await vm.saveWarga(keluarga);

      final captured =
          verify(() => repo.createWarga(captureAny())).captured.first as Warga;

      expect(captured.keluarga?.id, 10);
    });
  });
}
