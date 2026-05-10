import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';


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


enum SuratStatus {
  tertunda,
  disetujui,
  ditolak,
  selesai,
}

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


extension KegiatanStatusUI on Kegiatan {
  String get statusLabel {
    if (isBerlangsung) return "Berlangsung";

    switch (status) {
      case KegiatanStatus.dibuat:
        return "Dibuat";
      case KegiatanStatus.ditunda:
        return "Ditunda";
      case KegiatanStatus.dibatalkan:
        return "Dibatalkan";
      case KegiatanStatus.selesai:
        return "Selesai";
    }
  }

  Color get statusColor {
    if (isBerlangsung) return Colors.blue;

    switch (status) {
      case KegiatanStatus.dibuat:
        return Colors.orange;
      case KegiatanStatus.ditunda:
        return Colors.grey;
      case KegiatanStatus.dibatalkan:
        return Colors.red;
      case KegiatanStatus.selesai:
        return Colors.green;
    }
  }
}