import 'package:flutter_test/flutter_test.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/viewmodels/penduduk/warga/add_warga_viewmodel.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';

class MockWargaRepository extends Fake implements WargaRepository {}

void main() {
  late AddWargaViewModel vm;

  setUp(() {
    vm = AddWargaViewModel(repo: MockWargaRepository(), kkId: 1);
  });

  List<Warga> dummyList = [
    Warga(nama: "Budi", nik: "1234567890123456"),
    Warga(nama: "Andi", nik: "9876543210987654"),
  ];

  group('UT05 - Pencarian Nama Warga', () {
    test('Cari berdasarkan nama', () {
      final keyword = "Budi";

      final result = dummyList
          .where((e) => e.nama.toLowerCase().contains(keyword.toLowerCase()))
          .toList();

      expect(result.length, 1);
      expect(result.first.nama, "Budi");
    });
  });

  group('UT06 - Pencarian NIK', () {
    test('Cari berdasarkan NIK', () {
      final keyword = "9876";

      final result = dummyList.where((e) => e.nik.contains(keyword)).toList();

      expect(result.length, 1);
      expect(result.first.nama, "Andi");
    });
  });
}
