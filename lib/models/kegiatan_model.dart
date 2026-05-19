enum KegiatanLevel { rt, rw }

enum KegiatanStatus { dibuat, dibatalkan, selesai }

class Kegiatan {
  final int? id;
  final String nama;
  final String? deskripsi;
  final DateTime tanggalMulai;
  final DateTime? tanggalSelesai;
  final KegiatanLevel level;
  final int? rtId;
  final int? rwId;
  final KegiatanStatus status;
  final String? imgReferensi;
  final String? docReferensi;
  final DateTime? waktuDibuat;
  final DateTime? waktuDiubah;
  final DateTime? waktuDihapus;

  Kegiatan({
    this.id,
    required this.nama,
    this.deskripsi,
    required this.tanggalMulai,
    this.tanggalSelesai,
    required this.level,
    this.rtId,
    this.rwId,
    required this.status,
    this.imgReferensi,
    this.docReferensi,
    this.waktuDibuat,
    this.waktuDiubah,
    this.waktuDihapus,
  });

  factory Kegiatan.fromJson(Map<String, dynamic> json) {
    return Kegiatan(
      id: json['id'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      tanggalMulai: DateTime.parse(json['tanggal_mulai']),
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.parse(json['tanggal_selesai'])
          : null,
      level: _level(json['level']),
      rtId: json['rt_id'],
      rwId: json['rw_id'],
      status: _status(json['status']),
      imgReferensi: json['img_referensi'],
      docReferensi: json['doc_referensi'],
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
      'deskripsi': deskripsi,
      'tanggal_mulai': tanggalMulai.toUtc().toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toUtc().toIso8601String(),
      'level': level == KegiatanLevel.rt ? 'RT' : 'RW',
      'rt_id': rtId,
      'rw_id': rwId,
      'status': _statusToString(status),
      'img_referensi': imgReferensi,
      'doc_referensi': docReferensi,
    };

    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  bool get isBerlangsung {
    final now = DateTime.now();
    if (status != KegiatanStatus.dibuat) return false;
    if (tanggalSelesai == null) return now.isAfter(tanggalMulai);
    return now.isAfter(tanggalMulai) && now.isBefore(tanggalSelesai!);
  }

  static KegiatanLevel _level(String v) =>
      v == "RT" ? KegiatanLevel.rt : KegiatanLevel.rw;

  static KegiatanStatus _status(String v) {
    switch (v) {
      case "Dibuat":
        return KegiatanStatus.dibuat;
      case "Ditunda":
      case "Dibatalkan":
        return KegiatanStatus.dibatalkan;
      default:
        return KegiatanStatus.selesai;
    }
  }

  static String _statusToString(KegiatanStatus status) {
    switch (status) {
      case KegiatanStatus.dibuat:
        return "Dibuat";
      case KegiatanStatus.dibatalkan:
        return "Dibatalkan";
      case KegiatanStatus.selesai:
        return "Selesai";
    }
  }
}
