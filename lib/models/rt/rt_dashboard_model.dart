class RtDashboardModel {
  final String saldoKas;
  final String kasMasuk;
  final String kasKeluar;
  final int totalPenduduk;
  final int jumlahKk;
  final int suratPending;
  final int suratDiproses;
  final int totalPria;
  final int totalWanita;

  // Tambahan untuk kelompok usia
  final int totalAnak;
  final int totalProduktif;
  final int totalLansia;

  RtDashboardModel({
    required this.saldoKas,
    required this.kasMasuk,
    required this.kasKeluar,
    required this.totalPenduduk,
    required this.jumlahKk,
    required this.suratPending,
    required this.suratDiproses,
    required this.totalPria,
    required this.totalWanita,
    required this.totalAnak,
    required this.totalProduktif,
    required this.totalLansia,
  });

  factory RtDashboardModel.fromJson(Map<String, dynamic> json) {
    return RtDashboardModel(
      saldoKas: json['saldo_kas'] ?? "Rp 0",
      kasMasuk: json['kas_masuk'] ?? "Rp 0",
      kasKeluar: json['kas_keluar'] ?? "Rp 0",
      totalPenduduk: json['total_penduduk'] ?? 0,
      jumlahKk: json['jumlah_kk'] ?? 0,
      suratPending: json['surat_pending'] ?? 0,
      suratDiproses: json['surat_diproses'] ?? 0,
      totalPria: json['total_pria'] ?? 0,
      totalWanita: json['total_wanita'] ?? 0,
      totalAnak: json['total_anak'] ?? 0,
      totalProduktif: json['total_produktif'] ?? 0,
      totalLansia: json['total_lansia'] ?? 0,
    );
  }
}