import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

extension PembayaranUiStatus on StatusPembayaran {
  String get label {
    switch (this) {
      case StatusPembayaran.belumDibayar:
        return "Belum Dibayar";
      case StatusPembayaran.diproses:
        return "Diproses";
      case StatusPembayaran.dibayar:
        return "Dibayar";
      case StatusPembayaran.ditolak:
        return "Ditolak";
    }
  }

  Color get color {
    switch (this) {
      case StatusPembayaran.belumDibayar:
        return ColorsUtils.yellow;
      case StatusPembayaran.diproses:
        return Colors.blue;
      case StatusPembayaran.dibayar:
        return ColorsUtils.g100;
      case StatusPembayaran.ditolak:
        return ColorsUtils.red;
    }
  }
}

class SuratUiStatus {
  final String label;
  final Color color;

  const SuratUiStatus({required this.label, required this.color});
}

extension SuratStatusExt on SuratStatus {
  SuratUiStatus get ui {
    switch (this) {
      case SuratStatus.diajukan:
        return const SuratUiStatus(label: "Diajukan", color: ColorsUtils.o100);

      case SuratStatus.disetujui:
        return const SuratUiStatus(label: "Disetujui", color: ColorsUtils.b200);

      case SuratStatus.ditolak:
        return const SuratUiStatus(label: "Ditolak", color: ColorsUtils.red);

      case SuratStatus.selesai:
        return const SuratUiStatus(label: "Selesai", color: ColorsUtils.g100);
    }
  }
}

class KegiatanUiStatus {
  final String label;
  final Color color;

  const KegiatanUiStatus({required this.label, required this.color});
}

enum FilterKegiatanStatus { semua, berlangsung, segera, selesai, dibatalkan }
