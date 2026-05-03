import 'package:rukun_app_proyek4/models/pengurus_model.dart';
import 'package:rukun_app_proyek4/models/rt_model.dart';
import 'package:rukun_app_proyek4/models/rw_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';

class User {
  final int id;
  final int wargaId;
  final bool? isAdmin;
  final DateTime? createdAt;
  final Warga? warga;
  final Pengurus? pengurus;
  final RtModel? rt;
  final RwModel? rw;

  User({
    required this.id,
    required this.wargaId,
    this.isAdmin,
    this.createdAt,
    this.warga,
    this.pengurus,
    this.rt,
    this.rw,
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
      rt: json['rt'] != null ? RtModel.fromJson(json['rt']) : null,
      rw: json['rw'] != null ? RwModel.fromJson(json['rw']) : null,
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
      'rt': rt?.toJson(),
      'rw': rw?.toJson(),
    };
  }
}
