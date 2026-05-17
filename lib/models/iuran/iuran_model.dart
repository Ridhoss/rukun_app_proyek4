import 'package:rukun_app_proyek4/models/transaksi_model.dart';

enum IuranLevel { rt, rw }

enum IuranType { reguler, insidentil }

class Iuran {
  final int? id;
  final String nama;
  final int? jumlah;
  final IuranLevel level;
  final int? rtId;
  final int? rwId;
  final IuranType tipe;
  final bool? isActive;
  final DateTime? waktuDibuat;
  final DateTime? waktuDiubah;
  final DateTime? waktuDihapus;
  final int? totalTerkumpul;
  final List<Transaksi>? transaksi;

  Iuran({
    this.id,
    required this.nama,
    this.jumlah,
    required this.level,
    this.rtId,
    this.rwId,
    required this.tipe,
    this.isActive,
    this.waktuDibuat,
    this.waktuDiubah,
    this.waktuDihapus,
    this.totalTerkumpul,
    this.transaksi,
  });

  factory Iuran.fromJson(Map<String, dynamic> json) {
    return Iuran(
      id: json['id'],
      nama: json['nama']?.toString() ?? '',
      jumlah: json['jumlah'] != null
          ? int.tryParse(json['jumlah'].toString())
          : null,
      level: _level(json['level']),
      rtId: json['rt_id'],
      rwId: json['rw_id'],
      tipe: _type(json['tipe']),
      isActive: json['is_active'],
      waktuDibuat: json['waktu_dibuat'] != null
          ? DateTime.tryParse(json['waktu_dibuat'].toString())
          : null,
      waktuDiubah: json['waktu_diubah'] != null
          ? DateTime.tryParse(json['waktu_diubah'].toString())
          : null,
      waktuDihapus: json['waktu_dihapus'] != null
          ? DateTime.tryParse(json['waktu_dihapus'].toString())
          : null,
      totalTerkumpul: json['total_terkumpul'],
      transaksi: json['transaksi'] != null
          ? (json['transaksi'] as List)
                .map((e) => Transaksi.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'nama': nama,
      'jumlah': jumlah,
      'level': level == IuranLevel.rt ? 'RT' : 'RW',
      'rt_id': rtId,
      'rw_id': rwId,
      'tipe': tipe.name,
      'is_active': isActive,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  static IuranLevel _level(dynamic v) {
    final value = v?.toString().toUpperCase();
    if (value == "RT") return IuranLevel.rt;
    return IuranLevel.rw;
  }

  static IuranType _type(dynamic v) {
    final value = v?.toString().toLowerCase();
    if (value == "reguler") return IuranType.reguler;
    return IuranType.insidentil;
  }
}
