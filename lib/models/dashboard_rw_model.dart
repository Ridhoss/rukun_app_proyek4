class DashboardRwModel {
  final int totalPenduduk;
  final int totalKK;
  final int totalRT;
  final int totalSurat;

  final double kasMasuk;
  final double kasKeluar;
  final double saldoKas;

  final List<PendudukKategori> kategoriPenduduk;
  final List<RtDistribution> distribusiRT;

  DashboardRwModel({
    required this.totalPenduduk,
    required this.totalKK,
    required this.totalRT,
    required this.totalSurat,
    required this.kasMasuk,
    required this.kasKeluar,
    required this.saldoKas,
    required this.kategoriPenduduk,
    required this.distribusiRT,
  });
}

class PendudukKategori {
  final String label;
  final int jumlah;

  PendudukKategori({
    required this.label,
    required this.jumlah,
  });
}

class RtDistribution {
  final String rt;
  final int jumlah;

  RtDistribution({
    required this.rt,
    required this.jumlah,
  });
}