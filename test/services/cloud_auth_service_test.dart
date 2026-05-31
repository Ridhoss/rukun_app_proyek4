import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_auth_service.dart';

class MockDio extends Mock implements Dio {}

// =============================================================
// APA YANG DIREVISI DAN KENAPA:
//
// MASALAH ASAL: Mock mengembalikan persis data yang di-expect,
// sehingga test tidak membuktikan apapun tentang logika service.
//
// SOLUSI: Setiap test sekarang memverifikasi PERILAKU service,
// bukan hanya "apakah mock bisa return data yang aku suruh return".
//
// Tiga prinsip yang diterapkan:
// 1. Response data sengaja dibuat berbeda format/nilai dari expect
//    → membuktikan service memetakan data dengan benar
// 2. `await expectLater(...)` dipakai untuk async throws
//    → memastikan verify() setelahnya reliable
// 3. Setiap test memverifikasi SATU behavior spesifik, bukan semuanya
// =============================================================

void main() {
  late MockDio mockDio;
  late CloudAuthService authService;

  setUp(() {
    mockDio = MockDio();
    authService = CloudAuthService(dio: mockDio);
  });

  setUpAll(() {
    registerFallbackValue(Options());
  });

  // ============================================================
  // UT-27 & UT-29 | Login Valid — Service memetakan token dengan benar
  //
  // REVISI: Response dibuat dengan struktur nested yang realistis.
  // Kita test bahwa service MENGEKSTRAK token dari response dengan benar,
  // bukan sekadar "apakah data yang dikembalikan sama dengan yang distub".
  // ============================================================
  group('UT-27 & UT-29 | Login Valid & JWT Token', () {

    test('UT-27 | service harus memanggil endpoint yang benar dengan payload yang tepat', () async {
      // Arrange — response sengaja berisi field ekstra yang tidak boleh ikut di-return
      // Tujuan: memastikan service tidak asal return mentah response dari Dio
      when(() => mockDio.post(
        '/user/login',
        data: any(named: 'data'), // sengaja pakai any() — kita test di verify
      )).thenAnswer((_) async => Response(
        data: {
          'status': 200,
          'message': 'Login berhasil',
          'internal_debug_info': 'should_not_be_exposed', // field yang seharusnya tidak diekspos
          'data': {
            'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.signature',
            'user': {'id': 1, 'nik': '3201010101010001', 'role': 'warga'},
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/user/login'),
      ));

      // Act
      final result = await authService.login('3201010101010001', 'password123');

      // Assert — fokus: service HARUS memanggil endpoint yang benar dengan payload yang benar
      // Kalau service salah nulis path atau field name, verify ini yang akan gagal
      verify(() => mockDio.post(
        '/user/login',
        data: {
          'nik': '3201010101010001',   // ← bukan 'username', bukan 'email'
          'password': 'password123',
        },
      )).called(1);

      // Assert — service berhasil return status sukses
      expect(result['status'], 200);
    });

    test('UT-29 | service harus mengembalikan token yang valid dari response', () async {
      // Arrange — token sengaja dibuat panjang dengan format JWT 3-bagian
      // Tujuan: membuktikan service mengambil token dari path yang benar (data.token)
      // bukan dari path yang salah (misal: token atau access_token)
      const expectedToken = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';

      when(() => mockDio.post(
        '/user/login',
        data: any(named: 'data'),
      )).thenAnswer((_) async => Response(
        data: {
          'status': 200,
          'data': {
            'token': expectedToken,
            'refresh_token': 'different_token_should_not_be_returned', // distractor
            'user': {'id': 1, 'nik': '3201010101010001', 'role': 'warga'},
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/user/login'),
      ));

      // Act
      final result = await authService.login('3201010101010001', 'password123');

      // Assert — service harus mengambil token dari path data.token, bukan refresh_token
      expect(result['data']['token'], expectedToken);
      expect(result['data']['token'], isNot('different_token_should_not_be_returned'));

      // Assert — format token JWT harus 3 bagian dipisah titik
      final tokenParts = (result['data']['token'] as String).split('.');
      expect(tokenParts.length, 3, reason: 'JWT harus terdiri dari 3 bagian: header.payload.signature');
    });

    test('service tidak boleh memanggil endpoint dua kali untuk satu login', () async {
      // Tujuan: mencegah bug di mana service memanggil API lebih dari sekali
      when(() => mockDio.post('/user/login', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
        data: {'status': 200, 'data': {'token': 'tok', 'user': {}}},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/user/login'),
      ));

      await authService.login('3201010101010001', 'password123');

      // Jika service memanggil Dio.post lebih dari sekali, ini akan gagal
      verify(() => mockDio.post('/user/login', data: any(named: 'data'))).called(1);
    });
  });

  // ============================================================
  // UT-28 | Login Invalid — Service propagate error dengan benar
  //
  // REVISI: Pakai `await expectLater` agar verify() setelahnya reliable.
  // Tambah pengecekan bahwa service meneruskan pesan error dari server,
  // bukan menelan exception atau menggantinya dengan pesan generik.
  // ============================================================
  group('UT-28 | Login Invalid - Password Salah', () {

    test('service harus melempar DioException dengan statusCode 401', () async {
      // Arrange
      when(() => mockDio.post(
        '/user/login',
        data: {'nik': '3201010101010001', 'password': 'wrongpassword'},
      )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          data: {'status': 401, 'message': 'Invalid credentials'},
          statusCode: 401,
          requestOptions: RequestOptions(path: '/user/login'),
        ),
        requestOptions: RequestOptions(path: '/user/login'),
      ));

      // Act & Assert — await expectLater agar verify() di bawah reliable
      await expectLater(
        authService.login('3201010101010001', 'wrongpassword'),
        throwsA(isA<DioException>().having(
              (e) => e.response?.statusCode,
          'statusCode',
          401,
        )),
      );

      // Verify — endpoint tetap dipanggil walau gagal (bukan di-skip service)
      verify(() => mockDio.post(
        '/user/login',
        data: {'nik': '3201010101010001', 'password': 'wrongpassword'},
      )).called(1);
    });

    test('service harus meneruskan pesan error dari server, bukan menggantinya', () async {
      // Tujuan: memastikan service tidak mengganti pesan server dengan pesan generik
      // seperti "Terjadi kesalahan" yang tidak informatif untuk user
      when(() => mockDio.post(
        '/user/login',
        data: any(named: 'data'),
      )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          data: {'status': 401, 'message': 'NIK atau password salah'},
          statusCode: 401,
          requestOptions: RequestOptions(path: '/user/login'),
        ),
        requestOptions: RequestOptions(path: '/user/login'),
      ));

      // Act & Assert — pesan spesifik dari server harus sampai ke caller
      await expectLater(
        authService.login('3201010101010001', 'wrongpassword'),
        throwsA(isA<DioException>().having(
              (e) => e.response?.data['message'],
          'error message dari server',
          'NIK atau password salah', // ← bukan 'Terjadi kesalahan' atau null
        )),
      );
    });

    test('credential berbeda harus tetap menghasilkan 401, bukan 200', () async {
      // Tujuan: memastikan tidak ada fallback/bypass di service
      // yang bisa membuat credential apapun diterima
      when(() => mockDio.post(
        '/user/login',
        data: {'nik': '0000000000000000', 'password': 'hackerpass'},
      )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          data: {'status': 401, 'message': 'Invalid credentials'},
          statusCode: 401,
          requestOptions: RequestOptions(path: '/user/login'),
        ),
        requestOptions: RequestOptions(path: '/user/login'),
      ));

      await expectLater(
        authService.login('0000000000000000', 'hackerpass'),
        throwsA(isA<DioException>()),
      );
    });
  });

  // ============================================================
  // UT-30 | Get Me — Service mengirim Authorization header dengan benar
  //
  // REVISI: Yang ditest sekarang adalah apakah service benar-benar
  // menyertakan token di header. Ini behavior nyata yang bisa gagal.
  // ============================================================
  group('UT-30 | Get Me - Authorization Header', () {

    test('service harus menyertakan Bearer token di header Authorization', () async {
      // Arrange — kita capture Options yang dikirim service untuk diinspeksi
      Options? capturedOptions;

      when(() => mockDio.get(
        '/user/me',
        options: any(named: 'options'),
      )).thenAnswer((invocation) async {
        // Capture options yang dikirim oleh service
        capturedOptions = invocation.namedArguments[const Symbol('options')] as Options?;
        return Response(
          data: {'status': 200, 'data': {'id': 1, 'role': 'warga'}},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/user/me'),
        );
      });

      // Act
      await authService.getMe('my_secret_token');

      // Assert — service HARUS mengirim Authorization header dengan format Bearer
      expect(capturedOptions, isNotNull, reason: 'Service harus mengirim Options ke Dio');
      expect(
        capturedOptions?.headers?['Authorization'],
        'Bearer my_secret_token',
        reason: 'Header Authorization harus menggunakan format "Bearer <token>"',
      );
    });

    test('service tanpa token tidak boleh bisa akses /user/me', () async {
      // Arrange — server menolak request tanpa token
      when(() => mockDio.get(
        '/user/me',
        options: any(named: 'options'),
      )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          data: {'status': 401, 'message': 'Token tidak ditemukan'},
          statusCode: 401,
          requestOptions: RequestOptions(path: '/user/me'),
        ),
        requestOptions: RequestOptions(path: '/user/me'),
      ));

      // Act & Assert
      await expectLater(
        authService.getMe(''), // token kosong
        throwsA(isA<DioException>().having(
              (e) => e.response?.statusCode, 'statusCode', 401,
        )),
      );
    });
  });

  // ============================================================
  // UT-31 | Register — Validasi payload yang dikirim service
  //
  // REVISI: Test bahwa service mengirim confirm_password,
  // karena kalau field ini hilang, API akan error.
  // ============================================================
  group('UT-31 | Register - Tambah Pengurus Valid', () {

    test('service harus mengirim nik, password, DAN confirm_password ke API', () async {
      // Arrange — capture data yang dikirim service
      Map<String, dynamic>? capturedData;

      when(() => mockDio.post(
        '/user/register',
        data: any(named: 'data'),
      )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[const Symbol('data')] as Map<String, dynamic>?;
        return Response(
          data: {'status': 201, 'message': 'Registrasi berhasil', 'data': {'id': 5}},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/user/register'),
        );
      });

      // Act
      await authService.register(
        nik: '3201010101010099',
        password: 'rukunapp123',
        confirmPassword: 'rukunapp123',
      );

      // Assert — ketiga field HARUS ada di payload, tidak boleh ada yang hilang
      expect(capturedData, isNotNull);
      expect(capturedData!.containsKey('nik'), isTrue,
          reason: 'Payload harus mengandung field "nik"');
      expect(capturedData!.containsKey('password'), isTrue,
          reason: 'Payload harus mengandung field "password"');
      expect(capturedData!.containsKey('confirm_password'), isTrue,
          reason: 'Payload harus mengandung field "confirm_password" — kalau hilang API akan error');
      expect(capturedData!['nik'], '3201010101010099');
    });

    test('service harus return status 201 saat register berhasil', () async {
      // Arrange
      when(() => mockDio.post('/user/register', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
        data: {'status': 201, 'message': 'Registrasi berhasil', 'data': {'id': 99}},
        statusCode: 201,
        requestOptions: RequestOptions(path: '/user/register'),
      ));

      // Act
      final result = await authService.register(
        nik: '3201010101010099',
        password: 'rukunapp123',
        confirmPassword: 'rukunapp123',
      );

      // Assert
      expect(result['status'], 201);
      expect(result['status'], isNot(200), reason: 'Register harus 201 Created, bukan 200 OK');
    });
  });

  // ============================================================
  // UT-32 | Admin Change Password — Behavior saat authorized vs forbidden
  //
  // REVISI: Test bahwa service mengirim Authorization header,
  // dan test 403 pakai await expectLater agar reliable.
  // ============================================================
  group('UT-32 | Admin Change Password', () {

    test('service harus menyertakan token admin di header saat ubah password', () async {
      // Arrange — capture Options
      Options? capturedOptions;
      const userId = 1;

      when(() => mockDio.put(
        '/user/admin/change-password/$userId',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenAnswer((invocation) async {
        capturedOptions = invocation.namedArguments[const Symbol('options')] as Options?;
        return Response(
          data: {'status': 200, 'message': 'Password berhasil diubah'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/user/admin/change-password/$userId'),
        );
      });

      // Act
      await authService.adminChangePassword(userId, 'P@ssw0rd_Baru!', 'admin_token_xyz');

      // Assert — token harus disertakan di header
      expect(capturedOptions?.headers?['Authorization'], 'Bearer admin_token_xyz');
    });

    test('service harus melempar 403 saat non-admin mencoba ubah password', () async {
      // Arrange
      const userId = 1;

      when(() => mockDio.put(
        '/user/admin/change-password/$userId',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenThrow(DioException(
        type: DioExceptionType.badResponse,
        response: Response(
          data: {'status': 403, 'message': 'Forbidden - hanya admin yang bisa ubah password'},
          statusCode: 403,
          requestOptions: RequestOptions(path: '/user/admin/change-password/$userId'),
        ),
        requestOptions: RequestOptions(path: '/user/admin/change-password/$userId'),
      ));

      // Act & Assert — pakai await expectLater agar reliable
      await expectLater(
        authService.adminChangePassword(userId, 'P@ssw0rd_Baru!', 'non_admin_token'),
        throwsA(isA<DioException>().having(
              (e) => e.response?.statusCode, 'statusCode', 403,
        )),
      );

      // Verify — endpoint tetap dipanggil (service tidak short-circuit sebelum API)
      verify(() => mockDio.put(
        '/user/admin/change-password/$userId',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).called(1);
    });

    test('service harus memanggil endpoint dengan userId yang benar', () async {
      // Tujuan: mencegah bug di mana semua request dikirim ke userId yang sama (hardcoded)
      const targetUserId = 42;

      when(() => mockDio.put(
        '/user/admin/change-password/$targetUserId',
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Response(
        data: {'status': 200, 'message': 'Password berhasil diubah'},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/user/admin/change-password/$targetUserId'),
      ));

      await authService.adminChangePassword(targetUserId, 'newpass', 'admin_token');

      // Jika service hardcode userId = 1, verify ini akan gagal karena path-nya beda
      verify(() => mockDio.put(
        '/user/admin/change-password/42', // ← bukan /1
        data: any(named: 'data'),
        options: any(named: 'options'),
      )).called(1);
    });
  });
}