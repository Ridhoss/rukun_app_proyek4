import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/status_utils.dart';

class KegiatanViewmodel extends ChangeNotifier {
  final List<Kegiatan> _all = [];

  bool isLoading = false;
  String? errorMessage;

  FilterKegiatanStatus selectedStatus = FilterKegiatanStatus.semua;

  List<Kegiatan> get data {
    switch (selectedStatus) {
      case FilterKegiatanStatus.semua:
        return _all;

      case FilterKegiatanStatus.berlangsung:
        return _all
            .where(
              (e) => getUiStatus(e).type == FilterKegiatanStatus.berlangsung,
            )
            .toList();

      case FilterKegiatanStatus.segera:
        return _all
            .where((e) => getUiStatus(e).type == FilterKegiatanStatus.segera)
            .toList();

      case FilterKegiatanStatus.selesai:
        return _all
            .where((e) => getUiStatus(e).type == FilterKegiatanStatus.selesai)
            .toList();

      case FilterKegiatanStatus.dibatalkan:
        return _all
            .where((e) => getUiStatus(e).type == FilterKegiatanStatus.dibatalkan)
            .toList();
    }
  }

  void setStatus(FilterKegiatanStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  KegiatanUiStatus getUiStatus(Kegiatan item) {
    final now = DateTime.now();

    final selesai = item.tanggalSelesai ?? item.tanggalMulai;

    if (item.status == KegiatanStatus.dibatalkan) {
      return const KegiatanUiStatus(
        label: "Dibatalkan",
        color: ColorsUtils.red,
        type: FilterKegiatanStatus.dibatalkan,
      );
    }

    if (item.status == KegiatanStatus.selesai) {
      return const KegiatanUiStatus(
        label: "Selesai",
        color: ColorsUtils.g100,
        type: FilterKegiatanStatus.selesai,
      );
    }

    final isBerlangsung =
        now.isAfter(item.tanggalMulai) && now.isBefore(selesai);

    if (isBerlangsung) {
      return const KegiatanUiStatus(
        label: "Berlangsung",
        color: ColorsUtils.b200,
        type: FilterKegiatanStatus.berlangsung,
      );
    }

    final isSegera = now.isBefore(item.tanggalMulai);

    if (isSegera) {
      return const KegiatanUiStatus(
        label: "Segera",
        color: ColorsUtils.o100,
        type: FilterKegiatanStatus.segera,
      );
    }

    return const KegiatanUiStatus(
      label: "Selesai",
      color: ColorsUtils.g100,
      type: FilterKegiatanStatus.selesai,
    );
  }

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
          deskripsi:
              "Kegiatan membersihkan lingkungan bersama warga agar tetap nyaman dan sehat",
          tanggalMulai: DateTime.now().subtract(const Duration(days: 1)),
          tanggalSelesai: DateTime.now().add(const Duration(days: 1)),
          level: KegiatanLevel.rt,
          status: KegiatanStatus.dibuat,
        ),

        Kegiatan(
          id: 2,
          nama: "Rapat Warga",
          deskripsi:
              "Pertemuan rutin membahas keamanan lingkungan serta program kegiatan masyarakat",
          tanggalMulai: DateTime.now().add(const Duration(days: 2)),
          tanggalSelesai: DateTime.now().add(const Duration(days: 2)),
          level: KegiatanLevel.rw,
          status: KegiatanStatus.dibuat,
        ),

        Kegiatan(
          id: 3,
          nama: "Lomba 17an",
          deskripsi:
              "Persiapan perlombaan kemerdekaan untuk meningkatkan kebersamaan antar warga sekitar",
          tanggalMulai: DateTime.now().subtract(const Duration(days: 5)),
          tanggalSelesai: DateTime.now().subtract(const Duration(days: 2)),
          level: KegiatanLevel.rw,
          status: KegiatanStatus.selesai,
        ),

        Kegiatan(
          id: 4,
          nama: "Posyandu",
          deskripsi:
              "Pelayanan kesehatan balita dan ibu hamil oleh kader posyandu setempat",
          tanggalMulai: DateTime.now().add(const Duration(days: 1)),
          tanggalSelesai: DateTime.now().add(const Duration(days: 3)),
          level: KegiatanLevel.rt,
          status: KegiatanStatus.dibatalkan,
        ),
      ]);
    } catch (e) {
      errorMessage = "Gagal load data";
    }

    isLoading = false;
    notifyListeners();
  }
}
