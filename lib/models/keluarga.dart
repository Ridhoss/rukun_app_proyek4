class Keluarga {
  final int? id;
  final String noKK;
  final int rtId;
  final String alamat;
  final String kodePos;

  Keluarga({
    this.id,
    required this.noKK,
    required this.rtId,
    required this.alamat,
    required this.kodePos,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'no_kk': noKK,
    'rt_id': rtId,
    'alamat': alamat,
    'kodePos': kodePos,
  };

  factory Keluarga.fromMap(Map<dynamic, dynamic> map) {
    return Keluarga(
      id: map['id'] == null ? null : (map['id'] as num).toInt(),
      noKK: (map['no_kk'] ?? '') as String,
      rtId: (map['rt_id'] as num).toInt(),
      alamat: ((map['alamat'] ?? map['address']) ?? '') as String,
      kodePos: ((map['kodePos'] ?? '')) as String,
    );
  }
}
