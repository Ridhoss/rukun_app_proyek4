class RtModel {
  final int? id;
  final String noRt;
  final int rwId;
  final DateTime? waktuDibuat;
  final DateTime? waktuDiubah;
  final DateTime? waktuDihapus;

  RtModel({
    this.id,
    required this.noRt,
    required this.rwId,
    this.waktuDibuat,
    this.waktuDiubah,
    this.waktuDihapus,
  });

  factory RtModel.fromJson(Map<String, dynamic> json) {
    return RtModel(
      id: json['id'] as int?,
      noRt: json['no_rt'],
      rwId: json['rw_id'],
      waktuDibuat: json['waktu_dibuat'] != null
          ? DateTime.tryParse(json['waktu_dibuat'])
          : null,
      waktuDiubah: json['waktu_diubah'] != null
          ? DateTime.parse(json['waktu_diubah'])
          : null,
      waktuDihapus: json['waktu_dihapus'] != null
          ? DateTime.parse(json['waktu_dihapus'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'no_rt': noRt, 'rw_id': rwId};
  }
}
