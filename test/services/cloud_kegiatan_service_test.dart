import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kegiatan_service.dart';

class MockDio extends Mock implements Dio {}

// =============================================================
// UT-36, UT-37, UT-38 — CloudKegiatanService
//
// Tiga prinsip yang diterapkan:
// 1. Capture payload/options yang dikirim service untuk diinspeksi
// 2. await expectLater untuk async throws agar verify() reliable
// 3. Setiap test memverifikasi SATU behavior spesifik
// =============================================================

void main() {
  late MockDio mockDio;
  late CloudKegiatanService kegiatanService;

  const token = 'test_bearer_token';

  setUp(() {
    mockDio = MockDio();
    kegiatanService = CloudKegiatanService();
  });

  setUpAll(() {
    registerFallbackValue(Options());
  });

  // ============================================================
  // UT-36 | Create Kegiatan — Tambah Kegiatan Valid
  //
  // Test bahwa service mengirim payload yang lengkap ke endpoint
  // yang benar dan menyertakan Authorization header.
  // ============================================================
  group('UT-36 | Create Kegiatan - Tambah Kegiatan Valid', () {

    test('service harus mengirim semua field wajib ke endpoint /kegiatan', () async {
      // Arrange — capture payload yang dikirim
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
        '/kegiatan',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[const Symbol('data')] as Map<String, dynamic>?;
        return Response(
          data: {
            'status': 201,
            'message': 'Kegiatan berhasil ditambahkan',
            'data': {
              'id': 5,
              'nama': 'Kerja Bakti',
              'tanggal': '2026-06-01',
              'created_at': '2026-05-30T10:00:00Z',
            },
          },
          statusCode: 201,
          requestOptions: RequestOptions(path: '/kegiatan'),
        );
      });

      // Act
      await kegiatanService.createKegiatan({
        'nama': 'Kerja Bakti',
        'tanggal': '2026-06-01',
        'deskripsi': 'Bersih-bersih lingkungan RT 003',
        'lokasi': 'Lapangan RT 003',
        'rw_id': 1,
      }, token);

      // Assert — semua field wajib harus ada di payload
      expect(capturedData, isNotNull);
      expect(capturedData!.containsKey('nama'), isTrue,
          reason: 'Field "nama" wajib ada di payload');
      expect(capturedData!.containsKey('tanggal'), isTrue,
          reason: 'Field "tanggal" wajib ada di payload');
      expect(capturedData!['nama'], 'Kerja Bakti');
      expect(capturedData!['tanggal'], '2026-06-01');
    });

    test('service harus menyertakan Bearer token di header saat create', () async {
      // Tujuan: /kegiatan (POST) butuh auth header — pastikan dikirim
      Options? capturedOptions;

      when(() => mockDio.post(
        '/kegiatan',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenAnswer((invocation) async {
        capturedOptions = invocation.namedArguments[const Symbol('options')] as Options?;
        return Response(
          data: {'status': 201, 'data': {'id': 5}},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/kegiatan'),
        );
      });

      // Act
      await kegiatanService.createKegiatan({'nama': 'Rapat RT'}, 'admin_token_xyz');

      // Assert — Authorization header harus ada dengan format Bearer
      expect(capturedOptions, isNotNull,
          reason: 'Service harus mengirim Options ke Dio');
      expect(capturedOptions?.headers?['Authorization'], 'Bearer admin_token_xyz',
          reason: 'Header Authorization harus format "Bearer <token>"');
    });

    test('service harus return status 201 (Created) saat berhasil', () async {
      // Tujuan: create kegiatan = resource baru, harus 201 bukan 200
      when(() => mockDio.post(
        '/kegiatan',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Response(
        data: {'status': 201, 'message': 'Kegiatan berhasil ditambahkan', 'data': {'id': 5}},
        statusCode: 201,
        requestOptions: RequestOptions(path: '/kegiatan'),
      ));

      final result = await kegiatanService.createKegiatan({
        'nama': 'Kerja Bakti',
        'tanggal': '2026-06-01',
      }, token);

      expect(result['status'], 201);
      expect(result['status'], isNot(200),
          reason: 'Create harus 201 Created, bukan 200 OK');

      // Verify endpoint
      verify(() => mockDio.post(
        '/kegiatan',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).called(1);
    });
  });

  // ============================================================
  // UT-37 | Validasi Form Kegiatan — Tolak field kosong
  //
  // Test bahwa service meneruskan error 400 dari API saat
  // field wajib tidak diisi, bukan menelan exception.
  // ============================================================
  group('UT-37 | Validasi Form Kegiatan - Tolak field kosong', () {

    test('service harus melempar DioException 400 saat nama dan tanggal kosong', () async {
      // Arrange — API menolak payload kosong
      final emptyData = {'nama': '', 'tanggal': '', 'deskripsi': ''};

      when(() => mockDio.post(
        '/kegiatan',
        data: emptyData,
        options: any(named: 'options'),
      )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          data: {
            'status': 400,
            'message': 'Validation error',
            'errors': {
              'nama': ['Nama kegiatan wajib diisi'],
              'tanggal': ['Tanggal kegiatan wajib diisi'],
            },
          },
          statusCode: 400,
          requestOptions: RequestOptions(path: '/kegiatan'),
        ),
        requestOptions: RequestOptions(path: '/kegiatan'),
      ));

      // Act & Assert — await agar verify() reliable
      await expectLater(
        kegiatanService.createKegiatan(emptyData, token),
        throwsA(isA<DioException>().having(
          (e) => e.response?.statusCode, 'statusCode', 400,
        )),
      );

      // Verify — endpoint tetap dipanggil (service tidak skip sebelum API)
      verify(() => mockDio.post(
        '/kegiatan',
        data: emptyData,
        options: any(named: 'options'),
      )).called(1);
    });

    test('service harus meneruskan pesan validasi error dari server', () async {
      // Tujuan: pesan error spesifik dari server harus sampai ke caller,
      // bukan diganti dengan pesan generik "Terjadi kesalahan"
      when(() => mockDio.post(
        '/kegiatan',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          data: {
            'status': 400,
            'message': 'Validation error',
            'errors': {'nama': ['Nama kegiatan wajib diisi']},
          },
          statusCode: 400,
          requestOptions: RequestOptions(path: '/kegiatan'),
        ),
        requestOptions: RequestOptions(path: '/kegiatan'),
      ));

      // Act & Assert — pesan spesifik dari server harus sampai
      await expectLater(
        kegiatanService.createKegiatan({}, token),
        throwsA(isA<DioException>().having(
          (e) => e.response?.data['message'],
          'pesan error dari server',
          'Validation error',
        )),
      );
    });

    test('service harus meneruskan detail error per field dari server', () async {
      // Tujuan: selain pesan umum, detail error per field juga harus ada
      // agar UI bisa tampilkan pesan error di bawah masing-masing input
      when(() => mockDio.post(
        '/kegiatan',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          data: {
            'status': 400,
            'message': 'Validation error',
            'errors': {
              'nama': ['Nama kegiatan wajib diisi'],
              'tanggal': ['Tanggal kegiatan wajib diisi'],
            },
          },
          statusCode: 400,
          requestOptions: RequestOptions(path: '/kegiatan'),
        ),
        requestOptions: RequestOptions(path: '/kegiatan'),
      ));

      // Act & Assert — field-level errors harus sampai ke caller
      await expectLater(
        kegiatanService.createKegiatan({'nama': '', 'tanggal': ''}, token),
        throwsA(isA<DioException>().having(
          (e) => (e.response?.data['errors'] as Map?)?.containsKey('nama'),
          'ada error detail untuk field nama',
          isTrue,
        )),
      );
    });
  });

  // ============================================================
  // UT-38 | Upload Bukti Kegiatan — Berhasil via updateKegiatan
  //
  // Test bahwa service mengirim bukti ke endpoint PUT /kegiatan/{id}
  // dengan payload dan auth header yang benar.
  // ============================================================
  group('UT-38 | Upload Bukti Kegiatan - Berhasil', () {

    test('service harus mengirim bukti_kegiatan via PUT ke endpoint yang benar', () async {
      // Arrange — capture data dan verify endpoint
      Map<String, dynamic>? capturedData;
      const kegiatanId = 5;

      when(() => mockDio.put(
        '/kegiatan/$kegiatanId',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[const Symbol('data')] as Map<String, dynamic>?;
        return Response(
          data: {
            'status': 200,
            'message': 'Bukti kegiatan berhasil diupload',
            'data': {
              'id': kegiatanId,
              'bukti_kegiatan': 'https://storage.example.com/kegiatan/5/bukti.jpg',
              'status': 'selesai',
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kegiatan/$kegiatanId'),
        );
      });

      // Act
      await kegiatanService.updateKegiatan(kegiatanId, {
        'bukti_kegiatan': 'base64encoded_foto_kerja_bakti...',
        'status': 'selesai',
      }, token);

      // Assert — payload harus mengandung field bukti_kegiatan
      expect(capturedData, isNotNull);
      expect(capturedData!.containsKey('bukti_kegiatan'), isTrue,
          reason: 'Payload update harus mengandung field "bukti_kegiatan"');
      expect(capturedData!['bukti_kegiatan'], isNotEmpty,
          reason: 'File bukti tidak boleh kosong');

      // Verify — harus pakai PUT, bukan POST
      verify(() => mockDio.put(
        '/kegiatan/$kegiatanId',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).called(1);
    });

    test('service harus menyertakan auth header saat upload bukti', () async {
      // Tujuan: pastikan token dikirim di header saat update
      Options? capturedOptions;
      const kegiatanId = 5;

      when(() => mockDio.put(
        '/kegiatan/$kegiatanId',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenAnswer((invocation) async {
        capturedOptions = invocation.namedArguments[const Symbol('options')] as Options?;
        return Response(
          data: {'status': 200, 'data': {'id': kegiatanId}},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/kegiatan/$kegiatanId'),
        );
      });

      await kegiatanService.updateKegiatan(
        kegiatanId,
        {'bukti_kegiatan': 'base64...'},
        'rt_admin_token',
      );

      // Assert — header harus ada
      expect(capturedOptions?.headers?['Authorization'], 'Bearer rt_admin_token',
          reason: 'Upload bukti butuh Authorization header');
    });

    test('service harus memanggil endpoint dengan kegiatanId yang benar', () async {
      // Tujuan: mencegah bug hardcoded kegiatanId
      const targetId = 42;

      when(() => mockDio.put(
        '/kegiatan/$targetId',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Response(
        data: {'status': 200, 'data': {'id': targetId}},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/kegiatan/$targetId'),
      ));

      await kegiatanService.updateKegiatan(targetId, {'bukti_kegiatan': 'img'}, token);

      // Kalau service hardcode /kegiatan/1, verify ini gagal
      verify(() => mockDio.put(
        '/kegiatan/42', // ← bukan /kegiatan/1 atau /kegiatan/5
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).called(1);
    });

    test('service harus melempar 404 saat kegiatan tidak ditemukan', () async {
      // Tujuan: service tidak boleh menelan error 404
      const invalidId = 9999;

      when(() => mockDio.put(
        '/kegiatan/$invalidId',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          data: {'status': 404, 'message': 'Kegiatan tidak ditemukan'},
          statusCode: 404,
          requestOptions: RequestOptions(path: '/kegiatan/$invalidId'),
        ),
        requestOptions: RequestOptions(path: '/kegiatan/$invalidId'),
      ));

      await expectLater(
        kegiatanService.updateKegiatan(invalidId, {'bukti_kegiatan': 'img'}, token),
        throwsA(isA<DioException>().having(
          (e) => e.response?.statusCode, 'statusCode', 404,
        )),
      );
    });
  });
}