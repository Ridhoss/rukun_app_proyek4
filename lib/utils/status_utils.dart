import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
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

extension SuratStatusExtention on SuratStatus {
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

enum FilterKegiatanStatus {
  semua,
  berlangsung,
  segera,
  selesai,
  dibatalkan,
}

class KegiatanUiStatus {
  final String label;
  final Color color;
  final FilterKegiatanStatus type;

  const KegiatanUiStatus({
    required this.label,
    required this.color,
    required this.type,
  });
}

extension KegiatanStatusExtension on KegiatanStatus {
  KegiatanUiStatus get ui {
    switch (this) {
      case KegiatanStatus.dibuat:
        return const KegiatanUiStatus(
          label: "Dibuat",
          color: ColorsUtils.b300,
          type: FilterKegiatanStatus.segera,
        );

      case KegiatanStatus.dibatalkan:
        return const KegiatanUiStatus(
          label: "Dibatalkan",
          color: ColorsUtils.red,
          type: FilterKegiatanStatus.dibatalkan,
        );

      case KegiatanStatus.selesai:
        return const KegiatanUiStatus(
          label: "Selesai",
          color: ColorsUtils.g100,
          type: FilterKegiatanStatus.selesai,
        );
    }
  }
}
