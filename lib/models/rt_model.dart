class RtModel {
  final int id;
  final String noRt;
  final int rwId;
  final DateTime? waktuDibuat;

  RtModel({
    required this.id,
    required this.noRt,
    required this.rwId,
    this.waktuDibuat,
  });

  factory RtModel.fromJson(Map<String, dynamic> json) {
    return RtModel(
      id: json['id'],
      noRt: json['no_rt'],
      rwId: json['rw_id'],
      waktuDibuat: json['waktu_dibuat'] != null
          ? DateTime.tryParse(json['waktu_dibuat'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'no_rt': noRt, 'rw_id': rwId};
  }
}
