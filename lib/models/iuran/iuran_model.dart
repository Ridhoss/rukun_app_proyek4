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
  final DateTime? waktuDibuat;
  final DateTime? waktuDiubah;
  final DateTime? waktuDihapus;

  Iuran({
    this.id,
    required this.nama,
    this.jumlah,
    required this.level,
    this.rtId,
    this.rwId,
    required this.tipe,
    this.waktuDibuat,
    this.waktuDiubah,
    this.waktuDihapus,
  });

  factory Iuran.fromJson(Map<String, dynamic> json) {
    return Iuran(
      id: json['id'],
      nama: json['nama'],
      jumlah: json['jumlah'],
      level: _level(json['level']),
      rtId: json['rt_id'],
      rwId: json['rw_id'],
      tipe: _type(json['tipe']),
      waktuDibuat: json['waktu_dibuat'] != null
          ? DateTime.parse(json['waktu_dibuat'])
          : null,
      waktuDiubah: json['waktu_diubah'] != null
          ? DateTime.parse(json['waktu_diubah'])
          : null,
      waktuDihapus: json['waktu_dihapus'] != null
          ? DateTime.parse(json['waktu_dihapus'])
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
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  static IuranLevel _level(String v) =>
      v == "RT" ? IuranLevel.rt : IuranLevel.rw;

  static IuranType _type(String v) =>
      v == "reguler" ? IuranType.reguler : IuranType.insidentil;
}
