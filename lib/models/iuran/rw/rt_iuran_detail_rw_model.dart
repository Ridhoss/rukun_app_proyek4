class RtIuranDetailRW {
  final int rtId;
  final String noRt;
  final String ketua;
  final String bendahara;
  final int tagihan;
  final int totalBayar;
  final int sisa;
  final String status;

  RtIuranDetailRW({
    required this.rtId,
    required this.noRt,
    required this.ketua,
    required this.bendahara,
    required this.tagihan,
    required this.totalBayar,
    required this.sisa,
    required this.status,
  });

  factory RtIuranDetailRW.fromJson(Map<String, dynamic> json) {
    return RtIuranDetailRW(
      rtId: json['rt_id'],
      noRt: json['no_rt'],
      ketua: json['ketua'] ?? "-",
      bendahara: json['bendahara'] ?? "-",
      tagihan: json['tagihan'] ?? 0,
      totalBayar: json['total_bayar'] ?? 0,
      sisa: json['sisa'] ?? 0,
      status: json['status'] ?? "belum",
    );
  }
}