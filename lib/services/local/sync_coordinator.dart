import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repository.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/repositories/kegiatan_repository.dart';
import 'package:rukun_app_proyek4/repositories/surat_repository.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';
import 'package:rukun_app_proyek4/repositories/setoran_iuran_repository.dart';
import 'package:rukun_app_proyek4/services/local/offline_sync_status_service.dart';
import 'package:rukun_app_proyek4/services/local/navigation_service.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';

class SyncCoordinator {
  final Connectivity _connectivity;
  final IuranRepository _iuranRepo;
  final SuratRepository _suratRepo;
  final WargaRepository _wargaRepo;
  final SetoranIuranRtRepository _setoranRepo;
  final KKRepository _kkRepo;
  final KegiatanRepository _kegiatanRepo;

  StreamSubscription<dynamic>? _sub;
  bool _isSyncing = false;
  bool _isOnline = false;
  Timer? _retryTimer;

  static final _queueNotifier = StreamController<void>.broadcast();

  static void notifyQueueChanged() {
    debugPrint('[Sync] notifyQueueChanged called');
    _queueNotifier.add(null);
  }

  SyncCoordinator(
    this._connectivity,
    this._iuranRepo,
    this._suratRepo,
    this._wargaRepo,
    this._setoranRepo,
    this._kkRepo,
    this._kegiatanRepo,
  );

  void start() {
    debugPrint('[Sync] start() called');

    _sub = _connectivity.onConnectivityChanged.listen((dynamic result) {
      final online = _parseConnectivity(result);
      debugPrint('[Sync] onConnectivityChanged: ${online ? "ONLINE" : "OFFLINE"}');

      _isOnline = online;

      if (online) {
        debugPrint('[Sync] Device is ONLINE — scheduling sync with delay...');
        _scheduleSync('connectivity', delay: const Duration(seconds: 3));
      }
    });

    _queueNotifier.stream.listen((_) {
      debugPrint('[Sync] Queue notifier fired. _isOnline=$_isOnline');
      if (_isOnline) {
        _scheduleSync('queue', delay: const Duration(seconds: 1));
      } else {
        debugPrint('[Sync] Offline — skipping sync from queue notifier');
      }
    });

    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = _parseConnectivity(result);
      debugPrint('[Sync] _initConnectivity: _isOnline=$_isOnline');

      if (_isOnline) {
        _scheduleSync('init', delay: const Duration(seconds: 2));
      }
    } catch (e) {
      debugPrint('[Sync] _initConnectivity error: $e');
    }
  }

  bool _parseConnectivity(dynamic result) {
    if (result is List) {
      return result.any((e) => e != ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    return false;
  }

  void _scheduleSync(String source, {Duration delay = Duration.zero}) {
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      _runSyncOnce(source);
    });
  }

  Future<void> syncNow() async {
    debugPrint('[Sync] Manual sync triggered');
    await _runSyncOnce('manual');
  }

  Future<void> _runSyncOnce(String source, {int retryCount = 0}) async {
    if (_isSyncing) {
      debugPrint('[Sync] Already syncing, skip ($source)');
      return;
    }

    _isSyncing = true;
    debugPrint('[Sync] ====== SYNC START (triggered by: $source, retry: $retryCount) ======');

    var anyFailed = false;

    try {
      debugPrint('[Sync] Syncing iuran...');
      await _iuranRepo.syncPending();
      debugPrint('[Sync] iuran ✓');
    } catch (e) {
      debugPrint('[Sync] iuran ✗: $e');
      anyFailed = true;
    }

    try {
      debugPrint('[Sync] Syncing surat...');
      await _suratRepo.syncPending();
      debugPrint('[Sync] surat ✓');
    } catch (e) {
      debugPrint('[Sync] surat ✗: $e');
      anyFailed = true;
    }

    try {
      debugPrint('[Sync] Syncing warga...');
      await _wargaRepo.syncPending();
      debugPrint('[Sync] warga ✓');
    } catch (e) {
      debugPrint('[Sync] warga ✗: $e');
      anyFailed = true;
    }

    try {
      debugPrint('[Sync] Syncing setoran...');
      await _setoranRepo.syncPending();
      debugPrint('[Sync] setoran ✓');
    } catch (e) {
      debugPrint('[Sync] setoran ✗: $e');
      anyFailed = true;
    }

    try {
      debugPrint('[Sync] Syncing kk...');
      await _kkRepo.syncPending();
      debugPrint('[Sync] kk ✓');
    } catch (e) {
      debugPrint('[Sync] kk ✗: $e');
      anyFailed = true;
    }

    try {
      debugPrint('[Sync] Syncing kegiatan...');
      await _kegiatanRepo.syncPending();
      debugPrint('[Sync] kegiatan ✓');
    } catch (e) {
      debugPrint('[Sync] kegiatan ✗: $e');
      anyFailed = true;
    }

    await OfflineSyncStatusService.instance.refresh();

    final pendingCount = OfflineSyncStatusService.instance.pendingCount.value;
    debugPrint('[Sync] Pending items after sync: $pendingCount');
    debugPrint('[Sync] ====== SYNC DONE (failed: $anyFailed) ======');

    if (anyFailed && retryCount < 3) {
      final delaySeconds = (retryCount + 1) * 5;
      debugPrint('[Sync] Some failed. Retrying in ${delaySeconds}s...');
      _isSyncing = false;
      _scheduleSync('retry_$retryCount', delay: Duration(seconds: delaySeconds));
      return;
    }

    final ctx = NavigationService.context;
    if (ctx != null) {
      if (anyFailed) {
        NotificationUtils.showError(
          ctx,
          'Sinkronisasi sebagian gagal. Periksa koneksi.',
        );
      } else if (pendingCount == 0) {
        NotificationUtils.showSuccess(
          ctx,
          'Semua data berhasil disinkronisasi.',
        );
      }
    }

    _isSyncing = false;
  }

  void dispose() {
    _sub?.cancel();
    _retryTimer?.cancel();
    _queueNotifier.close();
  }
}
