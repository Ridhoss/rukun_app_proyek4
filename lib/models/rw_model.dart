class RwModel {
  final int id;
  final String noRw;
  final String kelurahanDesa;
  final String kecamatan;
  final String kabupatenKota;
  final String provinsi;
  final DateTime waktuDibuat;

  RwModel({
    required this.id,
    required this.noRw,
    required this.kelurahanDesa,
    required this.kecamatan,
    required this.kabupatenKota,
    required this.provinsi,
    required this.waktuDibuat,
  });

  factory RwModel.fromJson(Map<String, dynamic> json) {
    return RwModel(
      id: json['id'],
      noRw: json['no_rw'],
      kelurahanDesa: json['kelurahan_desa'],
      kecamatan: json['kecamatan'],
      kabupatenKota: json['kabupaten_kota'],
      provinsi: json['provinsi'],
      waktuDibuat: DateTime.parse(json['waktu_dibuat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no_rw': noRw,
      'kelurahan_desa': kelurahanDesa,
      'kecamatan': kecamatan,
      'kabupaten_kota': kabupatenKota,
      'provinsi': provinsi,
      'waktu_dibuat': waktuDibuat.toIso8601String(),
    };
  }
}