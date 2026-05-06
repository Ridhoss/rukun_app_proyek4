enum IuranLevel { rt, rw }
enum IuranType { reguler, insidentil }
enum IuranScope { keluarga, warga }
enum PeriodeType { bulanan, sekali }

class Iuran {
  final int id;
  final String nama;
  final int jumlah;
  final IuranLevel level;
  final int? rtId;
  final int? rwId;
  final IuranType type;
  final IuranScope cakupan;
  final PeriodeType periode;
  final DateTime? waktuDibuat;

  Iuran({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.level,
    this.rtId,
    this.rwId,
    required this.type,
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
      type: _type(json['type']),
      cakupan: _scope(json['cakupan']),
      periode: _periode(json['periode']),
      waktuDibuat: json['waktu_dibuat'] != null
          ? DateTime.parse(json['waktu_dibuat'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'level': level.name,
      'rt_id': rtId,
      'rw_id': rwId,
      'type': type.name,
      'cakupan': cakupan.name,
      'periode': periode.name,
      'waktu_dibuat': waktuDibuat?.toIso8601String(),
    };
  }

  static IuranLevel _level(String v) =>
      v == "RT" ? IuranLevel.rt : IuranLevel.rw;

  static IuranType _type(String v) =>
      v == "reguler" ? IuranType.reguler : IuranType.insidentil;

  static IuranScope _scope(String v) =>
      v == "keluarga" ? IuranScope.keluarga : IuranScope.warga;

  static PeriodeType _periode(String v) =>
      v == "bulanan" ? PeriodeType.bulanan : PeriodeType.sekali;
}

