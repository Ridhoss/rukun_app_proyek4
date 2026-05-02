import 'package:rukun_app_proyek4/models/pengurus_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';

class User {
  final int id;
  final int wargaId;
  final bool? isAdmin;
  final DateTime? createdAt;
  final Warga? warga;
  final Pengurus? pengurus;

  User({
    required this.id,
    required this.wargaId,
    this.isAdmin,
    this.createdAt,
    this.warga,
    this.pengurus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      wargaId: json['warga_id'],
      isAdmin: json['is_admin'],
      createdAt: json['waktu_dibuat'] != null
          ? DateTime.parse(json['waktu_dibuat'])
          : null,

      warga: json['warga'] != null ? Warga.fromJson(json['warga']) : null,

      pengurus: json['pengurus'] != null ? Pengurus.fromJson(json['pengurus']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warga_id': wargaId,
      'is_admin': isAdmin,
      'waktu_dibuat': createdAt?.toIso8601String(),
      'warga': warga?.toJson(),
      'pengurus': pengurus?.toJson(),
    };
  }
}
