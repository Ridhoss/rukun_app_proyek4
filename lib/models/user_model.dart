enum Role { warga, pengurus }

enum AppRole { warga, rt, rw }

class User {
  final int id;
  final int? wargaId;
  final Role role;
  final String? level;
  final DateTime? createdAt;

  User({
    required this.id,
    this.wargaId,
    required this.role,
    this.level,
    this.createdAt,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warga_id': wargaId,
      'role': role.name,
      'level': level,
      'waktu_dibuat': createdAt?.toIso8601String(),
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

  AppRole get appRole {
    if (role == Role.warga) return AppRole.warga;

    if (level == "RW") return AppRole.rw;
    return AppRole.rt; 
  }
  
}
