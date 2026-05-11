class Keluarga {
  final int? id;
  final String noKK;
  final int rtId;
  final String? alamat;
  final String? kodePos;
  final String? imgRef;
  final DateTime? waktuDibuat;

  Keluarga({
    this.id,
    required this.noKK,
    required this.rtId,
    this.alamat,
    this.kodePos,
    this.imgRef,
    this.waktuDibuat,
  });

  factory Keluarga.fromJson(Map<String, dynamic> json) {
    return Keluarga(
      id: json['id'] as int?,
      noKK: json['no_kk'] ?? '',
      rtId: json['rt_id'] ?? 0,
      alamat: json['alamat'],
      kodePos: json['kode_pos'],
      imgRef: json['img_referensi'],
      waktuDibuat: json['waktu_dibuat'] != null
          ? DateTime.parse(json['waktu_dibuat'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no_kk': noKK,
      'rt_id': rtId,
      'alamat': alamat,
      'kode_pos': kodePos,
      'img_referensi': imgRef,
    };
  }

  Keluarga copyWith({
    int? id,
    String? noKK,
    int? rtId,
    String? alamat,
    String? kodePos,
    String? imgRef,
  }) {
    return Keluarga(
      id: id ?? this.id,
      noKK: noKK ?? this.noKK,
      rtId: rtId ?? this.rtId,
      alamat: alamat ?? this.alamat,
      kodePos: kodePos ?? this.kodePos,
      imgRef: imgRef ?? this.imgRef,
    );
  }
}
