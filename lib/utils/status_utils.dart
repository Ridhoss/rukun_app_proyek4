import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

extension StatusPembayaranUI on StatusPembayaran {
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
        return Colors.orange;
      case StatusPembayaran.diproses:
        return Colors.blue;
      case StatusPembayaran.dibayar:
        return Colors.green;
      case StatusPembayaran.ditolak:
        return Colors.red;
    }
  }
}

enum SuratStatus { tertunda, disetujui, ditolak, selesai }

extension SuratStatusUI on SuratStatus {
  String get label {
    switch (this) {
      case SuratStatus.tertunda:
        return "Tertunda";
      case SuratStatus.disetujui:
        return "Disetujui";
      case SuratStatus.ditolak:
        return "Ditolak";
      case SuratStatus.selesai:
        return "Selesai";
    }
  }

  Color get color {
    switch (this) {
      case SuratStatus.tertunda:
        return Colors.orange;
      case SuratStatus.disetujui:
        return Colors.green;
      case SuratStatus.ditolak:
        return Colors.red;
      case SuratStatus.selesai:
        return Colors.blue;
    }
  }
}

class KegiatanUiStatus {
  final String label;
  final Color color;

  const KegiatanUiStatus({required this.label, required this.color});
}

enum FilterKegiatanStatus { semua, berlangsung, segera, selesai, dibatalkan }
