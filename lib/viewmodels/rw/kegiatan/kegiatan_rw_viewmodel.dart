import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';

enum KegiatanFilterStatus { semua, dibuat, dibatalkan, selesai }

class KegiatanRwViewModel extends ChangeNotifier {
  bool isLoading = false;

  KegiatanLevel selectedLevel = KegiatanLevel.rw;

  KegiatanFilterStatus selectedStatus = KegiatanFilterStatus.semua;

//dummy data kegiatan
  final List<Kegiatan> _allData = [
    Kegiatan(
      id: 1,
      nama: "Pelatihan UMKM Warga Cermat",
      deskripsi:
          "Pelatihan pengembangan usaha warga RW untuk meningkatkan pemasukan UMKM lokal",
      tanggalMulai: DateTime.now().add(const Duration(days: 3)),
      tanggalSelesai: DateTime.now().add(const Duration(days: 5)),
      level: KegiatanLevel.rw,
      rwId: 2,
      status: KegiatanStatus.dibuat,
      docReferensi: "proposal_umkm.pdf",
    ),

    Kegiatan(
      id: 2,
      nama: "Pembagian Sembako",
      deskripsi:
          "Pembagian sembako kepada warga terdampak ekonomi di lingkungan RW",
      tanggalMulai: DateTime.now().subtract(const Duration(days: 7)),
      tanggalSelesai: DateTime.now().subtract(const Duration(days: 2)),
      level: KegiatanLevel.rw,
      rwId: 2,
      status: KegiatanStatus.selesai,
      docReferensi: "laporan_sembako.pdf",
      imgReferensi: "foto_kegiatan.png",
    ),

    Kegiatan(
      id: 3,
      nama: "Kerja Bakti RT 04",
      deskripsi: "Pembersihan saluran air dan lingkungan sekitar RT 04",
      tanggalMulai: DateTime.now().add(const Duration(days: 1)),
      tanggalSelesai: DateTime.now().add(const Duration(days: 1)),
      level: KegiatanLevel.rt,
      rtId: 4,
      rwId: 2,
      status: KegiatanStatus.dibuat,
      docReferensi: "proposal_rt04.pdf",
    ),

    Kegiatan(
      id: 4,
      nama: "Posyandu RT 01",
      deskripsi: "Pemeriksaan kesehatan lansia dan balita RT 01",
      tanggalMulai: DateTime.now().subtract(const Duration(days: 4)),
      tanggalSelesai: DateTime.now().subtract(const Duration(days: 4)),
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

  bool canUploadBukti(Kegiatan kegiatan) {
    if (isReadonly(kegiatan)) return false;

    final selesai = kegiatan.tanggalSelesai ?? kegiatan.tanggalMulai;

    final sudahSelesai = DateTime.now().isAfter(selesai);

    return sudahSelesai &&
        kegiatan.status == KegiatanStatus.selesai &&
        kegiatan.imgReferensi == null;
  }

  bool isFinished(Kegiatan kegiatan) {
    return kegiatan.status == KegiatanStatus.selesai;
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

  bool isOngoing(Kegiatan kegiatan) {
    final now = DateTime.now();

    final selesai = kegiatan.tanggalSelesai ?? kegiatan.tanggalMulai;

    return kegiatan.status == KegiatanStatus.dibuat &&
        now.isAfter(kegiatan.tanggalMulai) &&
        now.isBefore(selesai);
  }

  void cancelKegiatan(int id) {
    final index = _allData.indexWhere((e) => e.id == id);

    if (index == -1) return;

    final kegiatan = _allData[index];

    _allData[index] = Kegiatan(
      id: kegiatan.id,
      nama: kegiatan.nama,
      deskripsi: kegiatan.deskripsi,
      tanggalMulai: kegiatan.tanggalMulai,
      tanggalSelesai: kegiatan.tanggalSelesai,
      level: kegiatan.level,
      rtId: kegiatan.rtId,
      rwId: kegiatan.rwId,
      status: KegiatanStatus.dibatalkan,
      docReferensi: kegiatan.docReferensi,
      imgReferensi: kegiatan.imgReferensi,
    );

    notifyListeners();
  }

  void uploadDummyBukti(int id) {
    final index = _allData.indexWhere((e) => e.id == id);

    if (index == -1) return;

    final kegiatan = _allData[index];

    _allData[index] = Kegiatan(
      id: kegiatan.id,
      nama: kegiatan.nama,
      deskripsi: kegiatan.deskripsi,
      tanggalMulai: kegiatan.tanggalMulai,
      tanggalSelesai: kegiatan.tanggalSelesai,
      level: kegiatan.level,
      rtId: kegiatan.rtId,
      rwId: kegiatan.rwId,
      status: kegiatan.status,
      docReferensi: kegiatan.docReferensi,

      imgReferensi: "dummy_bukti_kegiatan.jpg",
    );

    notifyListeners();
  }

  String formatTanggalRange(Kegiatan kegiatan) {
    final mulai = DateFormat("dd MMM yyyy").format(kegiatan.tanggalMulai);

    final selesai = kegiatan.tanggalSelesai != null
        ? DateFormat("dd MMM yyyy").format(kegiatan.tanggalSelesai!)
        : null;

    if (selesai == null) {
      return mulai;
    }

    return "$mulai - $selesai";
  }
}
