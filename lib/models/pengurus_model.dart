class Pengurus {
  final int? id;
  final int userId;
  final String level;
  final int? rtId;
  final int? rwId;
  final String? posisi;
  final DateTime? waktuDibuat;

  Pengurus({
    this.id,
    required this.userId,
    required this.level,
    this.rtId,
    this.rwId,
    this.posisi,
    this.waktuDibuat,
  });

  factory Pengurus.fromJson(Map<String, dynamic> json) {
    return Pengurus(
      id: json['id'] as int?,
      userId: json['user_id'] ?? 0,
      level: json['level'] ?? '',
      rtId: json['rt_id'] as int?,
      rwId: json['rw_id'] as int?,
      posisi: json['posisi'],
      waktuDibuat: json['waktu_dibuat'] != null
          ? DateTime.tryParse(json['waktu_dibuat'])
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
    };
  }
}