enum IuranLevel { rt, rw }

enum IuranType { wajib, sedekah }

enum IuranScope { keluarga, warga }

enum PeriodeType { bulanan, sekali }

class Iuran {
  final int? id;
  final String nama;
  final int? jumlah;
  final IuranLevel level;
  final int? rtId;
  final int? rwId;
  final IuranType tipe;
  final IuranScope cakupan;
  final PeriodeType periode;
  final DateTime? waktuDibuat;

  Iuran({
    this.id,
    required this.nama,
    this.jumlah,
    required this.level,
    this.rtId,
    this.rwId,
    required this.tipe,
    required this.cakupan,
    required this.periode,
    this.waktuDibuat,
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
      cakupan: _scope(json['cakupan']),
      periode: _periode(json['periode']),
      waktuDibuat: json['waktu_dibuat'] != null
          ? DateTime.parse(json['waktu_dibuat'])
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
      'cakupan': cakupan.name,
      'periode': periode.name,
      'waktu_dibuat': waktuDibuat?.toIso8601String(),
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  static IuranLevel _level(String v) =>
      v == "RT" ? IuranLevel.rt : IuranLevel.rw;

  static IuranType _type(String v) =>
      v == "wajib" ? IuranType.wajib : IuranType.sedekah;

  static IuranScope _scope(String v) =>
      v == "keluarga" ? IuranScope.keluarga : IuranScope.warga;

  static PeriodeType _periode(String v) =>
      v == "bulanan" ? PeriodeType.bulanan : PeriodeType.sekali;
}
