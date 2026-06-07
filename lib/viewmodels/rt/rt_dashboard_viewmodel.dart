import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/dashboard_model.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/repositories/dashboard_repository.dart';
import 'package:rukun_app_proyek4/services/local/local_dashboard_cache_service.dart';

class RtDashboardViewModel extends ChangeNotifier {
  final DashboardRepository repository;

  RtDashboardViewModel(this.repository);

  final DashboardLocalCacheService _cache = DashboardLocalCacheService();

  DashboardModel? dashboard;

  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchDashboard() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      dashboard = await repository.getDashboardRT();
    } catch (e) {
      debugPrint("ERROR DASHBOARD RT: $e");
      dashboard = await _getCachedDashboard();
      if (dashboard == null) {
        errorMessage = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<DashboardModel?> _getCachedDashboard() async {
    try {
      final raw = await _cache.readRaw('rt_dashboard');
      if (raw != null) {
        return DashboardModel.fromJson(raw);
      }
    } catch (_) {}
    return null;
  }

  double get saldoKas => (dashboard?.rt?.saldoKas ?? 0).toDouble();
  double get kasMasuk => (dashboard?.kas?.totalMasuk ?? 0).toDouble();
  double get kasKeluar => (dashboard?.kas?.totalKeluar ?? 0).toDouble();

  // Convenience getters
  int get totalPenduduk => dashboard?.totalPenduduk ?? 0;
  int get jumlahKk => dashboard?.jumlahKk ?? 0;
  int get totalSurat => dashboard?.statusSurat.total ?? 0;
  int get suratPending => dashboard?.statusSurat.diajukan ?? 0;
  int get suratDiproses => dashboard?.statusSurat.disetujui ?? 0;
  int get totalPria => dashboard?.gender.pria ?? 0;
  int get totalWanita => dashboard?.gender.wanita ?? 0;
  int get totalAnak => dashboard?.ageDistribution.anak ?? 0;
  int get totalProduktif => dashboard?.ageDistribution.produktif ?? 0;
  int get totalLansia => dashboard?.ageDistribution.lansia ?? 0;

  List<Kegiatan> get kegiatan => dashboard?.kegiatan ?? [];
}
