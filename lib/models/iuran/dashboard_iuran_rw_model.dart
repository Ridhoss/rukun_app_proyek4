class DashboardIuranRW {
  final DashboardSummary summary;
  final List<DashboardIuranItem> data;

  DashboardIuranRW({required this.summary, required this.data});

  factory DashboardIuranRW.fromJson(Map<String, dynamic> json) {
    return DashboardIuranRW(
      summary: DashboardSummary.fromJson(json['summary']),
      data: (json['data'] as List)
          .map((e) => DashboardIuranItem.fromJson(e))
          .toList(),
    );
  }
}

class DashboardSummary {
  final int totalTerkumpul;
  final int totalTarget;

  DashboardSummary({required this.totalTerkumpul, required this.totalTarget});

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalTerkumpul: json['total_terkumpul'] ?? 0,
      totalTarget: json['total_target'] ?? 0,
    );
  }
}

class DashboardIuranItem {
  final DashboardIuran iuran;
  final List<DashboardRTItem> rt;

  DashboardIuranItem({required this.iuran, required this.rt});

  factory DashboardIuranItem.fromJson(Map<String, dynamic> json) {
    return DashboardIuranItem(
      iuran: DashboardIuran.fromJson(json['iuran']),
      rt: (json['rt'] as List).map((e) => DashboardRTItem.fromJson(e)).toList(),
    );
  }
}

class DashboardIuran {
  final int id;
  final String nama;
  final int? jumlah;
  final String level;
  final String? cakupan;
  final String? periode;

  DashboardIuran({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.level,
    this.cakupan,
    this.periode,
  });

  factory DashboardIuran.fromJson(Map<String, dynamic> json) {
    return DashboardIuran(
      id: json['id'],
      nama: json['nama'],
      jumlah: json['jumlah'],
      level: json['level'],
      cakupan: json['cakupan'],
      periode: json['periode'],
    );
  }
}

class DashboardRTItem {
  final int rtId;
  final String rt;
  final String bendahara;
  final int jumlahTarget;
  final int totalTerkumpul;
  final int target;
  final String status;

  DashboardRTItem({
    required this.rtId,
    required this.rt,
    required this.bendahara,
    required this.jumlahTarget,
    required this.totalTerkumpul,
    required this.target,
    required this.status,
  });

  factory DashboardRTItem.fromJson(Map<String, dynamic> json) {
    return DashboardRTItem(
      rtId: json['rt_id'],
      rt: json['rt'],
      bendahara: json['bendahara'],
      jumlahTarget: json['jumlah_target'] ?? 0,
      totalTerkumpul: json['total_terkumpul'] ?? 0,
      target: json['target'] ?? 0,
      status: json['status'],
    );
  }
}
