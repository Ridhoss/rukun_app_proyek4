import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_dashboard_service.dart';

// =============================================================
// MOCK: Only the Dio client is mocked — NOT the service itself.
// =============================================================
class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late CloudDashboardService dashboardService;

  const token = 'test_bearer_token';

  setUp(() {
    mockDio = MockDio();
    dashboardService = CloudDashboardService();
  });

  setUpAll(() {
    registerFallbackValue(Options());
  });

  // ============================================================
  // UT-33 | Dashboard RW — Menampilkan data agregat semua RT
  // ============================================================
  group('UT-33 | Dashboard RW - Data Agregat Semua RT', () {
    test('should return aggregated dashboard data for RW', () async {
      // Arrange
      final mockResponseData = {
        'status': 200,
        'data': {
          'total_warga': 320,
          'total_kk': 85,
          'total_rt': 5,
          'saldo_kas_rw': 12500000,
          'total_iuran_terkumpul': 8750000,
          'total_kegiatan': 12,
          'kegiatan_mendatang': 3,
          'iuran_belum_lunas': 15,
          'rt_summary': [
            {'rt_id': 1, 'nama': 'RT 001', 'total_warga': 65, 'saldo': 2500000},
            {'rt_id': 2, 'nama': 'RT 002', 'total_warga': 72, 'saldo': 3100000},
            {'rt_id': 3, 'nama': 'RT 003', 'total_warga': 58, 'saldo': 1800000},
            {'rt_id': 4, 'nama': 'RT 004', 'total_warga': 60, 'saldo': 2600000},
            {'rt_id': 5, 'nama': 'RT 005', 'total_warga': 65, 'saldo': 2500000},
          ],
        },
      };

      when(() => mockDio.get(
            '/dashboard/rw',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/dashboard/rw'),
          ));

      // Act
      final result = await dashboardService.getDashboardRW(token);

      // Assert — verify aggregated data values
      expect(result['status'], 200);
      expect(result['data']['total_warga'], 320);
      expect(result['data']['saldo_kas_rw'], 12500000);
      expect(result['data']['total_rt'], 5);
      expect(result['data']['total_kegiatan'], 12);
      expect(result['data']['rt_summary'], isA<List>());
      expect((result['data']['rt_summary'] as List).length, 5);

      // Verify the correct GET endpoint was called
      verify(() => mockDio.get(
            '/dashboard/rw',
            options: any(named: 'options'),
          )).called(1);
    });

    test('should throw DioException when unauthorized', () async {
      // Arrange
      when(() => mockDio.get(
            '/dashboard/rw',
            options: any(named: 'options'),
          )).thenThrow(DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {'status': 401, 'message': 'Unauthorized'},
              statusCode: 401,
              requestOptions: RequestOptions(path: '/dashboard/rw'),
            ),
            requestOptions: RequestOptions(path: '/dashboard/rw'),
          ));

      // Act & Assert
      expect(
        () async => await dashboardService.getDashboardRW(token),
        throwsA(isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          401,
        )),
      );

      // Verify
      verify(() => mockDio.get(
            '/dashboard/rw',
            options: any(named: 'options'),
          )).called(1);
    });
  });

  // ============================================================
  // UT-39 | Dashboard RT — Menampilkan statistik spesifik RT
  // ============================================================
  group('UT-39 | Dashboard RT - Statistik Spesifik RT', () {
    test('should return specific RT dashboard statistics', () async {
      // Arrange
      final mockResponseData = {
        'status': 200,
        'data': {
          'rt_id': 3,
          'nama_rt': 'RT 003',
          'total_warga': 78,
          'total_kk': 20,
          'saldo_kas_rt': 3750000,
          'iuran_terkumpul_bulan_ini': 1250000,
          'iuran_belum_bayar': 5,
          'kegiatan_mendatang': 2,
          'warga_summary': {
            'aktif': 72,
            'non_aktif': 6,
          },
        },
      };

      when(() => mockDio.get(
            '/dashboard/rt',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/dashboard/rt'),
          ));

      // Act
      final result = await dashboardService.getDashboardRT(token);

      // Assert — verify RT-specific statistics
      expect(result['status'], 200);
      expect(result['data']['rt_id'], 3);
      expect(result['data']['nama_rt'], 'RT 003');
      expect(result['data']['total_warga'], 78);
      expect(result['data']['saldo_kas_rt'], 3750000);
      expect(result['data']['iuran_terkumpul_bulan_ini'], 1250000);
      expect(result['data']['warga_summary']['aktif'], 72);
      expect(result['data']['warga_summary']['non_aktif'], 6);

      // Verify the correct GET endpoint was called
      verify(() => mockDio.get(
            '/dashboard/rt',
            options: any(named: 'options'),
          )).called(1);
    });

    test('should handle empty dashboard data gracefully', () async {
      // Arrange — new RT with no data yet
      final mockResponseData = {
        'status': 200,
        'data': {
          'rt_id': 10,
          'nama_rt': 'RT 010',
          'total_warga': 0,
          'total_kk': 0,
          'saldo_kas_rt': 0,
          'iuran_terkumpul_bulan_ini': 0,
          'iuran_belum_bayar': 0,
          'kegiatan_mendatang': 0,
        },
      };

      when(() => mockDio.get(
            '/dashboard/rt',
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/dashboard/rt'),
          ));

      // Act
      final result = await dashboardService.getDashboardRT(token);

      // Assert
      expect(result['status'], 200);
      expect(result['data']['total_warga'], 0);
      expect(result['data']['saldo_kas_rt'], 0);

      // Verify
      verify(() => mockDio.get(
            '/dashboard/rt',
            options: any(named: 'options'),
          )).called(1);
    });

    test('should throw DioException when forbidden (non-RT role)', () async {
      // Arrange
      when(() => mockDio.get(
            '/dashboard/rt',
            options: any(named: 'options'),
          )).thenThrow(DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {'status': 403, 'message': 'Forbidden - bukan pengurus RT'},
              statusCode: 403,
              requestOptions: RequestOptions(path: '/dashboard/rt'),
            ),
            requestOptions: RequestOptions(path: '/dashboard/rt'),
          ));

      // Act & Assert
      expect(
        () async => await dashboardService.getDashboardRT(token),
        throwsA(isA<DioException>().having(
          (e) => e.response?.statusCode,
          'statusCode',
          403,
        )),
      );
    });
  });
}
