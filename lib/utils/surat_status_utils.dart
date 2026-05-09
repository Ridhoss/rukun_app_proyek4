import 'package:flutter/material.dart';

enum SuratStatus {
  tertunda,
  disetujui,
  ditolak,
  selesai,
}

extension SuratStatusExtension on SuratStatus {
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