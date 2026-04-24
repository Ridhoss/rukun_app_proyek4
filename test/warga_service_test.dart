import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rukun_app_proyek4/services/hive_service.dart';
import 'package:rukun_app_proyek4/services/warga_service.dart';

void main() {
  late Directory tempDir;
  final hiveService = HiveService();
  final service = WargaService();

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('warga-service-test');
    await hiveService.initForTest(tempDir.path);
    await service.setCurrentRTContext(rtId: 1, rtLabel: 'RT 001');
  });

  tearDownAll(() async {
    await hiveService.resetForTest();
    await tempDir.delete(recursive: true);
  });

  test('saveKK sukses di RT aktif', () async {
    final ok = await service.saveKK(
      KKModel(noKK: '3171011111111111', rtId: 1, alamat: 'Jl. Anggrek 10'),
    );

    expect(ok, isTrue);
    expect(service.lastSavedKKId, isNotNull);
  });

  test('saveKK gagal jika no KK duplikat', () async {
    await service.saveKK(
      KKModel(noKK: '3171012222222222', rtId: 1, alamat: 'Jl. Mawar 12'),
    );

    final second = await service.saveKK(
      KKModel(noKK: '3171012222222222', rtId: 1, alamat: 'Jl. Melati 14'),
    );

    expect(second, isFalse);
    expect(service.lastError, 'No. KK sudah terdaftar.');
  });

  test('saveKK gagal jika RT tidak sesuai konteks', () async {
    final ok = await service.saveKK(
      KKModel(noKK: '3171013333333333', rtId: 2, alamat: 'Jl. Kenanga 2'),
    );

    expect(ok, isFalse);
    expect(
      service.lastError,
      'RT tidak sesuai konteks login. Anda hanya bisa input RT aktif.',
    );
  });

  test('saveWarga gagal saat NIK duplikat', () async {
    await service.saveKK(
      KKModel(noKK: '3171014444444444', rtId: 1, alamat: 'Jl. Flamboyan 7'),
    );

    final keluargaId = service.lastSavedKKId!;

    final warga1 = WargaModel(
      nama: 'Andi',
      nik: '3201010101010001',
      jk: 'Laki-laki',
      tempatLahir: 'Bandung',
      agama: 'Islam',
      pendidikan: 'S1',
      jenisPekerjaan: 'Wiraswasta',
      golonganDarah: 'O',
      statusPerkawinan: 'Kawin',
      statusHubungan: 'Kepala Keluarga',
      kewarganegaraan: 'WNI',
      namaAyah: 'Bapak A',
      namaIbu: 'Ibu A',
      keluargaId: keluargaId,
    );

    final warga2 = WargaModel(
      nama: 'Budi',
      nik: '3201010101010001',
      jk: 'Laki-laki',
      tempatLahir: 'Bandung',
      agama: 'Islam',
      pendidikan: 'SMA/Sederajat',
      jenisPekerjaan: 'Karyawan Swasta',
      golonganDarah: 'A',
      statusPerkawinan: 'Belum Kawin',
      statusHubungan: 'Anak',
      kewarganegaraan: 'WNI',
      namaAyah: 'Bapak B',
      namaIbu: 'Ibu B',
      keluargaId: keluargaId,
    );

    final first = await service.saveWarga(warga1);
    final second = await service.saveWarga(warga2);

    expect(first, isTrue);
    expect(second, isFalse);
    expect(service.lastError, 'NIK sudah terdaftar.');
  });

  test('saveWarga gagal jika keluarga berada di RT lain', () async {
    await service.setCurrentRTContext(rtId: 2, rtLabel: 'RT 002');
    await service.saveKK(
      KKModel(noKK: '3171015555555555', rtId: 2, alamat: 'Jl. Cempaka 99'),
    );
    final rt2KeluargaId = service.lastSavedKKId!;

    await service.setCurrentRTContext(rtId: 1, rtLabel: 'RT 001');

    final warga = WargaModel(
      nama: 'Cici',
      nik: '3201010101010002',
      jk: 'Perempuan',
      tempatLahir: 'Bandung',
      agama: 'Islam',
      pendidikan: 'S1',
      jenisPekerjaan: 'Pelajar/Mahasiswa',
      golonganDarah: 'B',
      statusPerkawinan: 'Belum Kawin',
      statusHubungan: 'Anak',
      kewarganegaraan: 'WNI',
      namaAyah: 'Bapak C',
      namaIbu: 'Ibu C',
      keluargaId: rt2KeluargaId,
    );

    final ok = await service.saveWarga(warga);

    expect(ok, isFalse);
    expect(
      service.lastError,
      'Anda tidak bisa menambah warga di KK milik RT lain.',
    );
  });
}
