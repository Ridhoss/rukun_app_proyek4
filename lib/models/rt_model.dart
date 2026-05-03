class RtModel {
  final int id;
  final String noRt;
  final int rwId;
  final DateTime waktuDibuat;

  RtModel({
    required this.id,
    required this.noRt,
    required this.rwId,
    required this.waktuDibuat,
  });

  factory RtModel.fromJson(Map<String, dynamic> json) {
    return RtModel(
      id: json['id'],
      noRt: json['no_rt'],
      rwId: json['rw_id'],
      waktuDibuat: DateTime.parse(json['waktu_dibuat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no_rt': noRt,
      'rw_id': rwId,
      'waktu_dibuat': waktuDibuat.toIso8601String(),
    };
  }
}