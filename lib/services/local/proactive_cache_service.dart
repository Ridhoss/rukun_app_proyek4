import 'package:flutter/foundation.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repository.dart';
import 'package:rukun_app_proyek4/repositories/surat_repository.dart';
import 'package:rukun_app_proyek4/repositories/kegiatan_repository.dart';
import 'package:rukun_app_proyek4/repositories/setoran_iuran_repository.dart';
import 'package:rukun_app_proyek4/repositories/rtrw_repository.dart';
import 'package:rukun_app_proyek4/services/local/offline_sync_status_service.dart';
import 'package:rukun_app_proyek4/services/utils/hive_service.dart';

class ProactiveCacheService {
  final WargaRepository _wargaRepo;
  final KKRepository _kkRepo;
  final IuranRepository _iuranRepo;
  final SuratRepository _suratRepo;
  final KegiatanRepository _kegiatanRepo;
  final SetoranIuranRtRepository _setoranRepo;
  final RTRWRepository _rtrwRepo;

  ProactiveCacheService(
    this._wargaRepo,
    this._kkRepo,
    this._iuranRepo,
    this._suratRepo,
    this._kegiatanRepo,
    this._setoranRepo,
    this._rtrwRepo,
  );

  bool _isCaching = false;
  bool get isCaching => _isCaching;

  Future<void> cacheAllData({int? rwId, int? rtId}) async {
    if (_isCaching) return;
    _isCaching = true;

    debugPrint('[ProactiveCache] Mulai cache semua data...');

    final futures = <Future>[];

    futures.add(_safeCache('Warga', () => _wargaRepo.getAllWarga()));
    futures.add(_safeCache('KK', () => _kkRepo.getAllKK()));
    futures.add(_safeCache('Iuran', () => _iuranRepo.getAllIuran()));
    futures.add(_safeCache('Surat', () => _suratRepo.getAllSurat()));
    futures.add(_safeCache('Kegiatan', () => _kegiatanRepo.getAllKegiatan()));
    futures.add(_safeCache('Setoran', () => _setoranRepo.getAllSetoran()));

    if (rwId != null) {
      futures.add(_safeCache('IuranRW', () => _iuranRepo.getIuranByRWId(rwId)));
      futures.add(_safeCache('SuratRW', () => _suratRepo.getSuratByRw(rwId)));
    }

    if (rtId != null) {
      futures.add(_safeCache('SuratRT', () => _suratRepo.getSuratByRt(rtId)));
    }

    await Future.wait(futures, eagerError: false);

    await _saveLastCacheTime();
    await OfflineSyncStatusService.instance.refresh();

    _isCaching = false;
    debugPrint('[ProactiveCache] Selesai cache semua data.');
  }

  Future<void> _safeCache(String name, Future<void> Function() fn) async {
    try {
      await fn();
      debugPrint('[ProactiveCache] $name ✓');
    } catch (e) {
      debugPrint('[ProactiveCache] $name gagal: $e');
    }
  }

  static const String _cacheMetaBox = 'cache_meta';

  Future<void> _saveLastCacheTime() async {
    final box = await HiveService().openBox<dynamic>(_cacheMetaBox);
    await box.put('last_full_cache', DateTime.now().toIso8601String());
  }

  static Future<DateTime?> getLastCacheTime() async {
    final box = await HiveService().openBox<dynamic>(_cacheMetaBox);
    final raw = box.get('last_full_cache');
    if (raw is String) {
      return DateTime.tryParse(raw);
    }
    return null;
  }
}
