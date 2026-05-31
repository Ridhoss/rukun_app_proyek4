import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_iuran_service.dart';

// =============================================================
// MOCK: Only the Dio client is mocked — NOT the service itself.
// =============================================================
class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late CloudIuranService iuranService;

  const token = 'test_bearer_token';

  setUp(() {
    mockDio = MockDio();
    iuranService = CloudIuranService(dio: mockDio);
  });

  setUpAll(() {
    registerFallbackValue(Options());
  });

  // ============================================================
  // UT-21 | Upload Bukti Invalid — Tolak jika file kosong
  // ============================================================
  group('UT-21 | Upload Bukti Invalid - createTransaksi tanpa bukti', () {
    test('should throw DioException 400 when bukti pembayaran is empty', () async {
      // Arrange — simulate the API rejecting a transaction with empty bukti
      final requestData = {
        'iuran_id': 1,
        'jumlah': 50000,
        'bukti_pembayaran': null, // file kosong / null
      };

      when(() => mockDio.post(
            '/transaksi',
            data: requestData,
            options: any(named: 'options'),
          )).thenThrow(DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {
                'status': 400,
                'message': 'Bukti pembayaran wajib diupload',
              },
              statusCode: 400,
              requestOptions: RequestOptions(path: '/transaksi'),
            ),
            requestOptions: RequestOptions(path: '/transaksi'),
          ));

      // Act & Assert
      expect(
        () async => await iuranService.createTransaksi(requestData, token),
        throwsA(isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          400,
        )),
      );

      // Verify the endpoint was called
      verify(() => mockDio.post(
            '/transaksi',
            data: requestData,
            options: any(named: 'options'),
          )).called(1);
    });

    test('should throw DioException 400 when bukti file path is empty string', () async {
      // Arrange
      final requestData = {
        'iuran_id': 1,
        'jumlah': 50000,
        'bukti_pembayaran': '', // string kosong
      };

      when(() => mockDio.post(
            '/transaksi',
            data: requestData,
            options: any(named: 'options'),
          )).thenThrow(DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {
                'status': 400,
                'message': 'Bukti pembayaran wajib diupload',
              },
              statusCode: 400,
              requestOptions: RequestOptions(path: '/transaksi'),
            ),
            requestOptions: RequestOptions(path: '/transaksi'),
          ));

      // Act & Assert
      expect(
        () async => await iuranService.createTransaksi(requestData, token),
        throwsA(isA<DioException>().having(
          (e) => e.response?.data['message'],
          'error message',
          'Bukti pembayaran wajib diupload',
        )),
      );
    });
  });

  // ============================================================
  // UT-22 & UT-23 | Update Status Transaksi — Approve & Reject
  // ============================================================
  group('UT-22 & UT-23 | Update Status Transaksi (Approve / Reject)', () {
    test('UT-22 | should approve transaksi successfully', () async {
      // Arrange
      const transId = 1;
      final approveData = {'status': 'disetujui'};
      final mockResponseData = {
        'status': 200,
        'message': 'Transaksi disetujui',
        'data': {
          'id': transId,
          'status': 'disetujui',
          'updated_at': '2026-05-30T10:00:00Z',
        },
      };

      when(() => mockDio.put(
            '/transaksi/$transId/status',
            data: approveData,
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/transaksi/$transId/status'),
          ));

      // Act
      final result =
          await iuranService.updateStatusTransaksi(transId, approveData, token);

      // Assert
      expect(result['status'], 200);
      expect(result['message'], 'Transaksi disetujui');
      expect(result['data']['status'], 'disetujui');

      // Verify
      verify(() => mockDio.put(
            '/transaksi/$transId/status',
            data: approveData,
            options: any(named: 'options'),
          )).called(1);
    });

    test('UT-23 | should reject transaksi with reason', () async {
      // Arrange
      const transId = 2;
      final rejectData = {
        'status': 'ditolak',
        'alasan': 'Foto bukti buram dan tidak terbaca',
      };
      final mockResponseData = {
        'status': 200,
        'message': 'Transaksi ditolak',
        'data': {
          'id': transId,
          'status': 'ditolak',
          'alasan': 'Foto bukti buram dan tidak terbaca',
          'updated_at': '2026-05-30T10:00:00Z',
        },
      };

      when(() => mockDio.put(
            '/transaksi/$transId/status',
            data: rejectData,
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions:
                RequestOptions(path: '/transaksi/$transId/status'),
          ));

      // Act
      final result =
          await iuranService.updateStatusTransaksi(transId, rejectData, token);

      // Assert
      expect(result['status'], 200);
      expect(result['data']['status'], 'ditolak');
      expect(result['data']['alasan'], 'Foto bukti buram dan tidak terbaca');

      // Verify
      verify(() => mockDio.put(
            '/transaksi/$transId/status',
            data: rejectData,
            options: any(named: 'options'),
          )).called(1);
    });
  });

  // ============================================================
  // UT-24 | Get Iuran By ID — Riwayat Penolakan
  // ============================================================
  group('UT-24 | Get Iuran By ID - Riwayat Penolakan', () {
    test('should return iuran detail with rejection reason', () async {
      // Arrange
      const iuranId = 3;
      final mockResponseData = {
        'status': 200,
        'data': {
          'id': iuranId,
          'nama': 'Iuran Kebersihan',
          'status': 'ditolak',
          'alasan': 'Foto bukti buram dan tidak terbaca',
          'jumlah': 50000,
        },
      };

      when(() => mockDio.get(
            '/iuran/$iuranId',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/iuran/$iuranId'),
          ));

      // Act
      final result = await iuranService.getIuranById(iuranId, token);

      // Assert
      expect(result['status'], 200);
      expect(result['data'], isNotNull);
      expect(result['data']['status'], 'ditolak');
      expect(result['data']['alasan'], 'Foto bukti buram dan tidak terbaca');

      // Verify
      verify(() => mockDio.get(
            '/iuran/$iuranId',
            options: any(named: 'options'),
          )).called(1);
    });
  });

  // ============================================================
  // UT-25 | Get Iuran Saya — Riwayat Iuran Warga
  // ============================================================
  group('UT-25 | Get Iuran Saya - Riwayat Iuran Warga', () {
    test('should return list of user iuran transactions', () async {
      // Arrange
      final mockResponseData = {
        'status': 200,
        'data': [
          {
            'id': 1,
            'nama': 'Iuran Kebersihan',
            'bulan': 'Januari 2026',
            'status': 'disetujui',
            'jumlah': 50000,
          },
          {
            'id': 2,
            'nama': 'Iuran Keamanan',
            'bulan': 'Februari 2026',
            'status': 'disetujui',
            'jumlah': 25000,
          },
          {
            'id': 3,
            'nama': 'Iuran Kebersihan',
            'bulan': 'Maret 2026',
            'status': 'pending',
            'jumlah': 50000,
          },
        ],
      };

      when(() => mockDio.get(
            '/iuran/me',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/iuran/me'),
          ));

      // Act
      final result = await iuranService.getIuranSaya(token);

      // Assert
      expect(result['status'], 200);
      expect(result['data'], isA<List>());
      expect((result['data'] as List).length, 3);
      expect(result['data'][0]['nama'], 'Iuran Kebersihan');
      expect(result['data'][1]['status'], 'disetujui');

      // Verify
      verify(() => mockDio.get(
            '/iuran/me',
            options: any(named: 'options'),
          )).called(1);
    });

    test('should return empty list when no iuran history exists', () async {
      // Arrange
      final mockResponseData = {
        'status': 200,
        'data': [],
      };

      when(() => mockDio.get(
            '/iuran/me',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/iuran/me'),
          ));

      // Act
      final result = await iuranService.getIuranSaya(token);

      // Assert
      expect(result['status'], 200);
      expect(result['data'], isEmpty);
    });
  });

  // ============================================================
  // UT-26 | Create Transaksi — Sukses
  // ============================================================
  group('UT-26 | Create Transaksi - Sukses', () {
    test('should create transaksi successfully with valid data', () async {
      // Arrange
      final requestData = {
        'iuran_id': 1,
        'jumlah': 50000,
        'bukti_pembayaran': 'base64encodedimage...',
        'keterangan': 'Pembayaran iuran bulan Mei',
      };

      final mockResponseData = {
        'status': 201,
        'message': 'Transaksi berhasil dibuat',
        'data': {
          'id': 10,
          'iuran_id': 1,
          'jumlah': 50000,
          'status': 'pending',
          'created_at': '2026-05-30T10:00:00Z',
        },
      };

      when(() => mockDio.post(
            '/transaksi',
            data: requestData,
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 201,
            requestOptions: RequestOptions(path: '/transaksi'),
          ));

      // Act
      final result = await iuranService.createTransaksi(requestData, token);

      // Assert
      expect(result['status'], 201);
      expect(result['message'], 'Transaksi berhasil dibuat');
      expect(result['data']['status'], 'pending');
      expect(result['data']['jumlah'], 50000);

      // Verify
      verify(() => mockDio.post(
            '/transaksi',
            data: requestData,
            options: any(named: 'options'),
          )).called(1);
    });
  });
}
