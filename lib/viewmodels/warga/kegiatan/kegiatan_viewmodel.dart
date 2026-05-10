import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';

class KegiatanViewmodel extends ChangeNotifier {
  final List<Kegiatan> _all = [];

  bool isLoading = false;
  String? errorMessage;

  List<Kegiatan> get data => _all;

  Future<void> loadDummy() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      _all.clear();

      _all.addAll([
        Kegiatan(
          id: 1,
          nama: "Kerja Bakti",
          deskripsi: "Bersih-bersih lingkungan",
          tanggalMulai: DateTime.now().subtract(const Duration(days: 1)),
          tanggalSelesai: DateTime.now().add(const Duration(days: 1)),
          level: KegiatanLevel.rt,
          status: KegiatanStatus.dibuat,
        ),
        Kegiatan(
          id: 2,
          nama: "Rapat Warga",
          deskripsi: "Pembahasan keamanan",
          tanggalMulai: DateTime.now().add(const Duration(days: 2)),
          tanggalSelesai: DateTime.now().add(const Duration(days: 2)),
          level: KegiatanLevel.rw,
          status: KegiatanStatus.dibuat,
        ),
        Kegiatan(
          id: 3,
          nama: "Lomba 17an",
          tanggalMulai: DateTime.now().subtract(const Duration(days: 5)),
          tanggalSelesai: DateTime.now().subtract(const Duration(days: 2)),
          level: KegiatanLevel.rw,
          status: KegiatanStatus.selesai,
        ),
        Kegiatan(
          id: 4,
          nama: "Posyandu",
          tanggalMulai: DateTime.now().add(const Duration(days: 1)),
          tanggalSelesai: DateTime.now().add(const Duration(days: 3)),
          level: KegiatanLevel.rt,
          status: KegiatanStatus.ditunda,
        ),
      ]);
    } catch (e) {
      errorMessage = "Gagal load data";
    }

    isLoading = false;
    notifyListeners();
  }
}
