import 'package:rukun_app_proyek4/models/rt/rt_dashboard_model.dart';

//masih static


class CloudRtDashboardService {
  Future<RtDashboardModel> fetchDashboardData(int rtId) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      return RtDashboardModel(
        saldoKas: "Rp 8.450.000",
        kasMasuk: "+ Rp 12.300.000",
        kasKeluar: "- Rp 3.850.000",
        totalPenduduk: 143,
        jumlahKk: 34,
        suratPending: 12,
        suratDiproses: 7,
        totalPria: 65,
        totalWanita: 78,
        totalAnak: 47,
        totalProduktif: 72,
        totalLansia: 24,
      );
    } catch (e) {
      throw Exception('Gagal memuat data dashboard RT: $e');
    }
  }
}