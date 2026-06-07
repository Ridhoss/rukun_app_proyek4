import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/models/pengurus_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';
import 'package:rukun_app_proyek4/services/utils/excel_export_service.dart';
import 'package:rukun_app_proyek4/services/utils/pdf_generator_service.dart';
import 'package:rukun_app_proyek4/viewmodels/export_data_viewmodel.dart';

// =============================================================
// MOCK: Repository dan ExcelExportService di-mock,
// BUKAN ViewModel — kita test logic ViewModel yang ASLI.
// =============================================================
class MockKKRepository extends Mock implements KKRepository {}
class MockWargaRepository extends Mock implements WargaRepository {}
class MockExcelExportService extends Mock implements ExcelExportService {}

// =============================================================
// UT-34 & UT-35 — Export PDF & Excel
//
// UT-34: PdfGeneratorService.generateDraftSurat — pure function,
//        test bahwa output Uint8List valid dan tidak kosong.
//
// UT-35: ExportDataViewModel — test bahwa ViewModel memanggil
//        repository dan export service dengan benar berdasarkan role.
// =============================================================

void main() {
  // ============================================================
  // UT-34 | Export PDF — Generate Draft Surat
  //
  // PdfGeneratorService adalah pure function (static method),
  // tidak perlu mock — langsung test input → output.
  // ============================================================
  group('UT-34 | Export PDF - Generate Draft Surat', () {

    test('generateDraftSurat harus menghasilkan Uint8List yang tidak kosong', () async {
      // Arrange — buat data surat dan warga yang realistis
      final surat = PengajuanSurat(
        id: 1,
        wargaId: 10,
        rtId: 3,
        keperluan: 'Pembuatan KTP',
        keterangan: 'Untuk keperluan administrasi',
        status: SuratStatus.diajukan,
      );

      final warga = Warga(
        id: 10,
        nama: 'Budi Santoso',
        nik: '3201010101010001',
        jk: JenisKelamin.lakiLaki,
        tempatLahir: 'Bandung',
        tglLahir: DateTime(1990, 5, 15),
        agama: Agama.islam,
        statusPerkawinan: StatusPerkawinan.kawin,
        kewarganegaraan: Kewarganegaraan.wni,
        jenisPekerjaan: 'Wiraswasta',
        keluarga: Keluarga(
          id: 1,
          noKK: '3201010101010000',
          rtId: 3,
          alamat: 'Jl. Merdeka No. 10',
        ),
      );

      // Act — panggil method static langsung
      final pdfBytes = await PdfGeneratorService.generateDraftSurat(surat, warga);

      // Assert — output harus Uint8List valid
      expect(pdfBytes, isA<Uint8List>(),
          reason: 'Output harus berupa Uint8List (byte array PDF)');
      expect(pdfBytes, isNotEmpty,
          reason: 'PDF bytes tidak boleh kosong — artinya PDF gagal di-generate');
      expect(pdfBytes.length, greaterThan(100),
          reason: 'PDF valid biasanya lebih dari 100 bytes');
    });

    test('generateDraftSurat harus menghasilkan PDF yang dimulai dengan header PDF', () async {
      // Arrange
      final surat = PengajuanSurat(
        id: 2,
        keperluan: 'Surat Keterangan Domisili',
      );

      final warga = Warga(
        nama: 'Siti Aminah',
        nik: '3201010101010002',
      );

      // Act
      final pdfBytes = await PdfGeneratorService.generateDraftSurat(surat, warga);

      // Assert — PDF file selalu dimulai dengan header "%PDF"
      // %PDF dalam ASCII = [37, 80, 68, 70]
      expect(pdfBytes[0], 37,  reason: 'Byte pertama PDF harus "%" (37)');
      expect(pdfBytes[1], 80,  reason: 'Byte kedua PDF harus "P" (80)');
      expect(pdfBytes[2], 68,  reason: 'Byte ketiga PDF harus "D" (68)');
      expect(pdfBytes[3], 70,  reason: 'Byte keempat PDF harus "F" (70)');
    });

    test('generateDraftSurat harus bisa handle warga dengan data minimal', () async {
      // Tujuan: memastikan service tidak crash saat field opsional null
      final surat = PengajuanSurat(keperluan: 'Test');
      final warga = Warga(nama: 'Test User', nik: '0000000000000000');

      // Act — tidak boleh throw exception
      final pdfBytes = await PdfGeneratorService.generateDraftSurat(surat, warga);

      // Assert — tetap generate PDF walau data minimal
      expect(pdfBytes, isNotEmpty,
          reason: 'PDF harus tetap di-generate walau banyak field null');
    });
  });

  // ============================================================
  // UT-35 | Export Excel — ExportDataViewModel
  //
  // Mock: KKRepository, WargaRepository, ExcelExportService
  // Test: Logic branching role RW vs RT, dan error handling.
  // ============================================================
  group('UT-35 | Export Excel - ExportDataViewModel', () {
    late MockKKRepository mockKKRepo;
    late MockWargaRepository mockWargaRepo;
    late MockExcelExportService mockExportService;
    late ExportDataViewModel viewModel;

    // Data test yang realistis
    final testKeluargaList = [
      Keluarga(id: 1, noKK: '3201010101010000', rtId: 3, alamat: 'Jl. Merdeka 10'),
      Keluarga(id: 2, noKK: '3201010101010001', rtId: 3, alamat: 'Jl. Merdeka 11'),
    ];

    final testWargaList = [
      Warga(id: 1, nama: 'Budi Santoso', nik: '3201010101010001',
          keluarga: Keluarga(id: 1, noKK: '3201010101010000', rtId: 3)),
      Warga(id: 2, nama: 'Siti Aminah', nik: '3201010101010002',
          keluarga: Keluarga(id: 2, noKK: '3201010101010001', rtId: 3)),
      Warga(id: 3, nama: 'Andi Prasetyo', nik: '3201010101010003',
          keluarga: Keluarga(id: 99, noKK: '9999999999999999', rtId: 5)), // RT lain
    ];

    setUp(() {
      mockKKRepo = MockKKRepository();
      mockWargaRepo = MockWargaRepository();
      mockExportService = MockExcelExportService();
      viewModel = ExportDataViewModel(
        kkRepo: mockKKRepo,
        wargaRepo: mockWargaRepo,
        exportService: mockExportService,
      );
    });

    setUpAll(() {
      // Register fallback values untuk mocktail
      registerFallbackValue(<Keluarga>[]);
      registerFallbackValue(<Warga>[]);
    });

    test('role RW harus memanggil getAllKK dan getAllWarga, bukan getByRT', () async {
      // Arrange — user dengan role RW
      final rwUser = User(
        id: 1,
        wargaId: 1,
        pengurus: Pengurus(userId: 1, level: 'RW', rwId: 1),
      );

      when(() => mockKKRepo.getAllKK()).thenAnswer((_) async => testKeluargaList);
      when(() => mockWargaRepo.getAllWarga()).thenAnswer((_) async => testWargaList);
      when(() => mockExportService.exportDataKependudukan(
        listKk: any(named: 'listKk'),
        listWarga: any(named: 'listWarga'),
        scopeName: any(named: 'scopeName'),
      )).thenAnswer((_) async {});

      // Act
      final result = await viewModel.exportDataKependudukan(rwUser);

      // Assert
      expect(result, isTrue, reason: 'Export RW harus berhasil');

      // Verify — RW harus memanggil getAllKK, bukan getKKByRT
      verify(() => mockKKRepo.getAllKK()).called(1);
      verify(() => mockWargaRepo.getAllWarga()).called(1);
      verifyNever(() => mockKKRepo.getKKByRT(any()));
    });

    test('role RT harus memanggil getKKByRT dan memfilter warga sesuai RT-nya', () async {
      // Arrange — user dengan role RT, rtId = 3
      final rtUser = User(
        id: 2,
        wargaId: 2,
        pengurus: Pengurus(userId: 2, level: 'RT', rtId: 3),
      );

      when(() => mockKKRepo.getKKByRT(3)).thenAnswer((_) async => testKeluargaList);
      when(() => mockWargaRepo.getAllWarga()).thenAnswer((_) async => testWargaList);
      when(() => mockExportService.exportDataKependudukan(
        listKk: any(named: 'listKk'),
        listWarga: any(named: 'listWarga'),
        scopeName: any(named: 'scopeName'),
      )).thenAnswer((_) async {});

      // Act
      final result = await viewModel.exportDataKependudukan(rtUser);

      // Assert
      expect(result, isTrue);

      // Verify — RT harus memanggil getKKByRT dengan rtId yang benar
      verify(() => mockKKRepo.getKKByRT(3)).called(1);
      verifyNever(() => mockKKRepo.getAllKK());

      // Verify — exportService dipanggil dengan scopeName yang mengandung RT ID
      verify(() => mockExportService.exportDataKependudukan(
        listKk: any(named: 'listKk'),
        listWarga: any(named: 'listWarga'),
        scopeName: 'RT_3', // ← harus mengandung RT ID
      )).called(1);
    });

    test('role selain RW/RT harus ditolak dan return false', () async {
      // Arrange — user tanpa pengurus (warga biasa)
      final wargaUser = User(
        id: 3,
        wargaId: 3,
        // pengurus null → role tidak ada
      );

      // Act
      final result = await viewModel.exportDataKependudukan(wargaUser);

      // Assert — harus gagal karena role tidak diizinkan
      expect(result, isFalse, reason: 'Warga biasa tidak boleh export data');
      expect(viewModel.errorMessage, isNotNull,
          reason: 'Error message harus di-set saat role tidak diizinkan');
      expect(viewModel.errorMessage, contains('tidak diizinkan'),
          reason: 'Pesan error harus informatif tentang role');

      // Verify — tidak ada repository yang dipanggil
      verifyNever(() => mockKKRepo.getAllKK());
      verifyNever(() => mockKKRepo.getKKByRT(any()));
      verifyNever(() => mockWargaRepo.getAllWarga());
    });

    test('isExporting harus false setelah export selesai (sukses atau gagal)', () async {
      // Tujuan: mencegah UI stuck di loading state
      final rwUser = User(
        id: 1,
        wargaId: 1,
        pengurus: Pengurus(userId: 1, level: 'RW', rwId: 1),
      );

      when(() => mockKKRepo.getAllKK()).thenAnswer((_) async => []);
      when(() => mockWargaRepo.getAllWarga()).thenAnswer((_) async => []);
      when(() => mockExportService.exportDataKependudukan(
        listKk: any(named: 'listKk'),
        listWarga: any(named: 'listWarga'),
        scopeName: any(named: 'scopeName'),
      )).thenAnswer((_) async {});

      // Act
      await viewModel.exportDataKependudukan(rwUser);

      // Assert — isExporting harus kembali false
      expect(viewModel.isExporting, isFalse,
          reason: 'isExporting harus false setelah selesai — kalau true, UI stuck loading');
    });

    test('errorMessage harus di-set saat repository throw exception', () async {
      // Tujuan: memastikan error dari repository ditangkap dan di-set ke errorMessage
      final rwUser = User(
        id: 1,
        wargaId: 1,
        pengurus: Pengurus(userId: 1, level: 'RW', rwId: 1),
      );

      when(() => mockKKRepo.getAllKK()).thenThrow(Exception('Koneksi gagal'));

      // Act
      final result = await viewModel.exportDataKependudukan(rwUser);

      // Assert — harus gagal dan error message terisi
      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.errorMessage, contains('Koneksi gagal'),
          reason: 'Error dari repository harus sampai ke errorMessage');
      expect(viewModel.isExporting, isFalse,
          reason: 'isExporting harus false meski error');
    });
  });
}
