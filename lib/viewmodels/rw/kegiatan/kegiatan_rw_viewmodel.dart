import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';

enum KegiatanFilterStatus { semua, dibuat, dibatalkan, selesai }

class KegiatanRwViewModel extends ChangeNotifier {
  bool isLoading = false;

  KegiatanLevel selectedLevel = KegiatanLevel.rw;
  KegiatanFilterStatus selectedStatus = KegiatanFilterStatus.semua;

  final List<Kegiatan> _allData = [
    Kegiatan(
      id: 1,
      nama: "Pelatihan UMKM Warga Cermat",
      deskripsi:
          "Penimbangan dan pemeriksaan gizi balita warga yang bekerja sama dengan puskesmas kelurahan",
      tanggalMulai: DateTime(2026, 4, 19),
      tanggalSelesai: DateTime(2026, 4, 21),
      level: KegiatanLevel.rw,
      rwId: 2,
      status: KegiatanStatus.dibuat,
      docReferensi: "proposal_umkm.pdf",
    ),

    Kegiatan(
      id: 2,
      nama: "Pembagian Sembako",
      deskripsi: "Pembagian sembako kepada warga terdampak",
      tanggalMulai: DateTime(2026, 4, 19),
      tanggalSelesai: DateTime(2026, 4, 21),
      level: KegiatanLevel.rw,
      rwId: 2,
      status: KegiatanStatus.selesai,
      docReferensi: "laporan_sembako.pdf",
      imgReferensi: "foto_kegiatan.png",
    ),

    Kegiatan(
      id: 3,
      nama: "Kerja Bakti RT 04",
      deskripsi: "Pembersihan saluran air RT",
      tanggalMulai: DateTime(2026, 4, 24),
      tanggalSelesai: DateTime(2026, 4, 24),
      level: KegiatanLevel.rt,
      rtId: 4,
      rwId: 2,
      status: KegiatanStatus.dibuat,
      docReferensi: "proposal_rt04.pdf",
    ),

    Kegiatan(
      id: 4,
      nama: "Posyandu RT 01",
      deskripsi: "Pemeriksaan kesehatan lansia",
      tanggalMulai: DateTime(2026, 4, 10),
      tanggalSelesai: DateTime(2026, 4, 10),
      level: KegiatanLevel.rt,
      rtId: 1,
      rwId: 2,
      status: KegiatanStatus.dibatalkan,
      docReferensi: "proposal_posyandu.pdf",
    ),
  ];

  List<Kegiatan> get data {
    return _allData.where((e) {
      final sameLevel = e.level == selectedLevel;

      bool sameStatus = true;

      switch (selectedStatus) {
        case KegiatanFilterStatus.semua:
          sameStatus = true;
          break;

        case KegiatanFilterStatus.dibuat:
          sameStatus = e.status == KegiatanStatus.dibuat;
          break;

        case KegiatanFilterStatus.dibatalkan:
          sameStatus = e.status == KegiatanStatus.dibatalkan;
          break;

        case KegiatanFilterStatus.selesai:
          sameStatus = e.status == KegiatanStatus.selesai;
          break;
      }

      return sameLevel && sameStatus;
    }).toList();
  }

  void setLevel(KegiatanLevel level) {
    selectedLevel = level;
    notifyListeners();
  }

  void setStatus(KegiatanFilterStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  bool isReadonly(Kegiatan kegiatan) {
    return kegiatan.level == KegiatanLevel.rt;
  }

  bool canEdit(Kegiatan kegiatan) {
    if (isReadonly(kegiatan)) return false;

    return kegiatan.status == KegiatanStatus.dibuat &&
        kegiatan.tanggalMulai.isAfter(DateTime.now());
  }

  bool canCancel(Kegiatan kegiatan) {
    return canEdit(kegiatan);
  }

  int get totalDibuat =>
      data.where((e) => e.status == KegiatanStatus.dibuat).length;

  int get totalDibatalkan =>
      data.where((e) => e.status == KegiatanStatus.dibatalkan).length;

  int get totalSelesai =>
      data.where((e) => e.status == KegiatanStatus.selesai).length;

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 700));
    notifyListeners();
  }
}
