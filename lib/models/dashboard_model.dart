import 'package:rukun_app_proyek4/models/kegiatan_model.dart';

class DashboardModel {
  final RtSimple rt;

  final int totalPenduduk;

  final GenderStat gender;
  final AgeDistribution ageDistribution;

  final int jumlahKk;

  final StatusSurat statusSurat;

  final List<Kegiatan> kegiatan;

  DashboardModel({
    required this.rt,
    required this.totalPenduduk,
    required this.gender,
    required this.ageDistribution,
    required this.jumlahKk,
    required this.statusSurat,
    required this.kegiatan,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      rt: RtSimple.fromJson(json['rt'] ?? {}),
      totalPenduduk: json['total_penduduk'] ?? 0,
      gender: GenderStat.fromJson(json['gender'] ?? {}),
      ageDistribution: AgeDistribution.fromJson(json['age_distribution'] ?? {}),
      jumlahKk: json['jumlah_kk'] ?? 0,
      statusSurat: StatusSurat.fromJson(json['status_surat'] ?? {}),
      kegiatan: (json['kegiatan'] as List? ?? [])
          .map((e) => Kegiatan.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rt': rt.toJson(),
      'total_penduduk': totalPenduduk,
      'gender': gender.toJson(),
      'age_distribution': ageDistribution.toJson(),
      'jumlah_kk': jumlahKk,
      'status_surat': statusSurat.toJson(),
      'kegiatan': kegiatan.map((e) => e.toJson()).toList(),
    };
  }
}

class RtSimple {
  final int id;
  final int rwId;

  RtSimple({required this.id, required this.rwId});

  factory RtSimple.fromJson(Map<String, dynamic> json) {
    return RtSimple(id: json['id'] ?? 0, rwId: json['rw_id'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'rw_id': rwId};
  }
}

class GenderStat {
  final int pria;
  final int wanita;

  GenderStat({required this.pria, required this.wanita});

  factory GenderStat.fromJson(Map<String, dynamic> json) {
    return GenderStat(pria: json['pria'] ?? 0, wanita: json['wanita'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'pria': pria, 'wanita': wanita};
  }
}

class AgeDistribution {
  final int anak;
  final int produktif;
  final int lansia;

  AgeDistribution({
    required this.anak,
    required this.produktif,
    required this.lansia,
  });

  factory AgeDistribution.fromJson(Map<String, dynamic> json) {
    return AgeDistribution(
      anak: json['anak'] ?? 0,
      produktif: json['produktif'] ?? 0,
      lansia: json['lansia'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'anak': anak, 'produktif': produktif, 'lansia': lansia};
  }
}

class StatusSurat {
  final int total;
  final int diajukan;
  final int disetujui;
  final int selesai;
  final int ditolak;

  StatusSurat({
    required this.total,
    required this.diajukan,
    required this.disetujui,
    required this.selesai,
    required this.ditolak,
  });

  factory StatusSurat.fromJson(Map<String, dynamic> json) {
    return StatusSurat(
      total: json['total'] ?? 0,
      diajukan: json['diajukan'] ?? 0,
      disetujui: json['disetujui'] ?? 0,
      selesai: json['selesai'] ?? 0,
      ditolak: json['ditolak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'diajukan': diajukan,
      'disetujui': disetujui,
      'selesai': selesai,
      'ditolak': ditolak,
    };
  }
}
