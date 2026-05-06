import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';

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