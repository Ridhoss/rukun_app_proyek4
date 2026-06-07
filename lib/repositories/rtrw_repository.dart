import 'package:dio/dio.dart';
import 'package:rukun_app_proyek4/models/rt_model.dart';
import 'package:rukun_app_proyek4/models/rw_model.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_rtrw_service.dart';
import 'package:rukun_app_proyek4/services/utils/hive_service.dart';
import 'package:rukun_app_proyek4/utils/hive_cast_utils.dart';

class RTRWRepository {
  final CloudRtRwService service;
  final AuthLocalService local;

  RTRWRepository(this.service, this.local);

  static const String _rwCacheBox = 'offline_cache_rw';

  Future<RwModel?> getRWById(int rwId) async {
    final token = await _requireToken();

    try {
      final result = await _safeCall(() => service.getRtbyRwID(token, rwId));

      _validateStatus(result);

      final data = result['data'];

      if (data == null) return null;

      final rw = RwModel.fromJson(data);
      await _cacheRwData(rwId, data);
      return rw;
    } catch (e) {
      if (_canUseCache(e)) {
        return _getCachedRw(rwId);
      }
      rethrow;
    }
  }

  Future<RtModel?> getRTById(int rtId) async {
    final token = await _requireToken();

    try {
      final result = await _safeCall(() => service.getRtId(token, rtId));

      _validateStatus(result);

      final data = result['data'];

      if (data == null) return null;

      return RtModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheRwData(int rwId, dynamic data) async {
    final box = await HiveService().openBox<dynamic>(_rwCacheBox);
    await box.put('rw_$rwId', data);
  }

  Future<RwModel?> _getCachedRw(int rwId) async {
    final box = await HiveService().openBox<dynamic>(_rwCacheBox);
    final raw = box.get('rw_$rwId');
    if (raw is Map) {
      return RwModel.fromJson(deepCastMap(raw));
    }
    return null;
  }

  bool _canUseCache(Object error) {
    if (error is DioException) {
      return switch (error.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.unknown => true,
        _ => false,
      };
    }
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('connection refused') ||
        message.contains('network is unreachable');
  }

  Future<String> _requireToken() async {
    final token = await local.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }

    return token;
  }

  Future<Map<String, dynamic>> _safeCall(
    Future<Map<String, dynamic>> Function() fn,
  ) async {
    try {
      return await fn();
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _validateStatus(Map<String, dynamic> result) {
    if (result['status'] != 'success') {
      throw Exception(result['message'] ?? "Unknown error");
    }
  }
}
