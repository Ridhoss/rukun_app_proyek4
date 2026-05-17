import 'package:rukun_app_proyek4/models/keluarga_model.dart';

class KeluargaStatus {
  final Keluarga keluarga;
  final bool sudahBayar;
  final int nominal;

  final DateTime? waktuBayar;
  final String? disetujuiOleh;
  final String? imgBukti;

  KeluargaStatus({
    required this.keluarga,
    required this.sudahBayar,
    required this.nominal,
    this.waktuBayar,
    this.disetujuiOleh,
    this.imgBukti,
  });
}
