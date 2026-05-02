import 'package:rukun_app_proyek4/models/warga_model.dart';
enum Role { warga, pengurus }

enum AppRole { warga, rt, rw }

class User {
  final int id;
  final int? wargaId;
  final Role role;
  final String? level;
  final DateTime? createdAt;
  final Warga? warga;

  User({
    required this.id,
    this.wargaId,
    required this.role,
    this.createdAt,
    this.warga,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      wargaId: json['warga_id'],
      role: _roleFromString(json['role']),
      level: json['level'],
      createdAt: json['waktu_dibuat'] != null
          ? DateTime.parse(json['waktu_dibuat'])
          : null,

      warga: json['warga'] != null
          ? Warga.fromJson(json['warga'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warga_id': wargaId,
      'role': role.name,
      'level': level,
      'waktu_dibuat': createdAt?.toIso8601String(),
      'warga': warga?.toJson(),
    };
  }

  static Role _roleFromString(String value) {
    switch (value) {
      case 'Warga':
        return Role.warga;
      case 'Pengurus':
        return Role.pengurus;
      default:
        throw Exception('Unknown role: $value');
    }
  }
}
