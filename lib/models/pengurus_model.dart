class Pengurus {
  final int id;
  final int userId;
  final String level;
  final int? rtId;
  final int? rwId;
  final String? posisi;
  final DateTime? createdAt;

  Pengurus({
    required this.id,
    required this.userId,
    required this.level,
    this.rtId,
    this.rwId,
    this.posisi,
    this.createdAt,
  });

  factory Pengurus.fromJson(Map<String, dynamic> json) {
    return Pengurus(
      id: json['id'],
      userId: json['user_id'],
      level: json['level'],
      rtId: json['rt_id'],
      rwId: json['rw_id'],
      posisi: json['posisi'],
      createdAt: json['waktu_dibuat'] != null
          ? DateTime.parse(json['waktu_dibuat'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'level': level,
      'rt_id': rtId,
      'rw_id': rwId,
      'posisi': posisi,
      'waktu_dibuat': createdAt?.toIso8601String(),
    };
  }
}
