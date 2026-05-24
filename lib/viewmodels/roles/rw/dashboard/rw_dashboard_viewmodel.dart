import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/dashboard_model.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/repositories/dashboard_repository.dart';

class DashboardRwViewModel extends ChangeNotifier {
  final DashboardRepository repository;

  DashboardRwViewModel(this.repository);

  bool isLoading = false;
  String? errorMessage;

  DashboardModel? dashboard;

  // dummy
  final double saldoKas = 8450000;
  final double kasMasuk = 12300000;
  final double kasKeluar = 3850000;

  Future<void> fetchDashboard() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await repository.getDashboardRW();

      dashboard = result;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("ERROR DASHBOARD RW: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int get totalPenduduk => dashboard?.totalPenduduk ?? 0;
  int get totalKK => dashboard?.jumlahKk ?? 0;
  int get totalRT => dashboard?.jumlahRt ?? 0;
  int get totalSurat => dashboard?.statusSurat.total ?? 0;
  int get suratPending => dashboard?.statusSurat.diajukan ?? 0;
  int get suratDiproses => dashboard?.statusSurat.disetujui ?? 0;
  int get suratSelesai => dashboard?.statusSurat.selesai ?? 0;
  int get suratDitolak => dashboard?.statusSurat.ditolak ?? 0;
  int get pria => dashboard?.gender.pria ?? 0;
  int get wanita => dashboard?.gender.wanita ?? 0;
  int get anak => dashboard?.ageDistribution.anak ?? 0;
  int get produktif => dashboard?.ageDistribution.produktif ?? 0;
  int get lansia => dashboard?.ageDistribution.lansia ?? 0;


  List<PendudukPerRT> get pendudukPerRt => dashboard?.pendudukPerRt ?? [];
  List<Kegiatan> get kegiatan => dashboard?.kegiatan ?? [];

  Kegiatan? get kegiatanAktif {
    try {
      return kegiatan.firstWhere((e) => e.isBerlangsung);
    } catch (_) {
      return null;
    }
  }
}
