import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/repositories/kegiatan_repository.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';

enum KegiatanFilterStatus { semua, dibuat, dibatalkan, selesai }

enum KegiatanValidationMode { create, uploadBukti, edit }

class KegiatanViewModel extends ChangeNotifier {
  final KegiatanRepository repository;
  final CloudinaryService cloudinaryService;

  KegiatanViewModel(this.repository, this.cloudinaryService);

  List<Kegiatan> _allKegiatan = [];

  bool isLoading = false;
  bool isUploading = false;
  String? errorMessage;

  File? selectedImage;
  File? selectedDocument;

  KegiatanLevel selectedLevel = KegiatanLevel.rw;
  KegiatanFilterStatus selectedStatus = KegiatanFilterStatus.semua;

  String _searchQuery = "";

  Future<void> fetchKegiatan() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _allKegiatan = await repository.getAllKegiatan();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchKegiatan();
  }

  List<Kegiatan> get kegiatanList {
    return _allKegiatan.where((kegiatan) {
      final matchLevel = kegiatan.level == selectedLevel;

      final matchStatus = switch (selectedStatus) {
        KegiatanFilterStatus.semua => true,
        KegiatanFilterStatus.dibuat => kegiatan.status == KegiatanStatus.dibuat,
        KegiatanFilterStatus.dibatalkan =>
          kegiatan.status == KegiatanStatus.dibatalkan,
        KegiatanFilterStatus.selesai =>
          kegiatan.status == KegiatanStatus.selesai,
      };

      final query = _searchQuery.toLowerCase();
      final matchSearch =
          kegiatan.nama.toLowerCase().contains(query) ||
          (kegiatan.deskripsi ?? "").toLowerCase().contains(query);

      return matchLevel && matchStatus && matchSearch;
    }).toList();
  }

  void setLevel(KegiatanLevel level) {
    selectedLevel = level;
    fetchKegiatan();
  }

  void setStatus(KegiatanFilterStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> createKegiatan({
    required String nama,
    required String deskripsi,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    if (selectedDocument == null) {
      errorMessage = "Dokumen wajib diupload";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final kegiatan = Kegiatan(
        id: 0,
        nama: nama,
        deskripsi: deskripsi,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        level: KegiatanLevel.rw,
        rwId: 2,
        status: KegiatanStatus.dibuat,

        // DOC wajib
        docReferensi: selectedDocument?.path.split("/").last,

        // IMAGE tidak dikirim saat create
        imgReferensi: null,

        waktuDibuat: DateTime.now(),
      );

      await repository.createKegiatan(kegiatan);

      _clearFile();
      await fetchKegiatan();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateKegiatan({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await repository.updateKegiatan(id, data);
      await fetchKegiatan();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteKegiatan(int id) async {
    try {
      await repository.deleteKegiatan(id);
      await fetchKegiatan();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> uploadBuktiKegiatan(int id) async {
    if (selectedImage == null) {
      errorMessage = "Foto bukti wajib diupload";
      notifyListeners();
      return;
    }

    isUploading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final url = await cloudinaryService.uploadFile(
        selectedImage!,
        folder: 'kegiatan/$id',
      );

      if (url == null) {
        errorMessage = "Upload gambar gagal";
        return;
      }

      await repository.updateKegiatan(id, {
        "img_referensi": url,
        "status": "selesai",
      });

      clearUpload();
      await fetchKegiatan();
    } catch (e) {
      errorMessage = e.toString();
    }

    isUploading = false;
    notifyListeners();
  }

  void clearUpload() {
    selectedImage = null;
    selectedDocument = null;
    notifyListeners();
  }

  bool isReadonly(Kegiatan k) => k.level == KegiatanLevel.rt;

  bool canEdit(Kegiatan k) {
    return !isReadonly(k) &&
        k.status == KegiatanStatus.dibuat &&
        k.tanggalMulai.isAfter(DateTime.now());
  }

  bool canCancel(Kegiatan k) => canEdit(k);

  bool canUploadBukti(Kegiatan k) {
    final selesai = k.tanggalSelesai ?? k.tanggalMulai;
    final isDone = DateTime.now().isAfter(selesai);

    return !isReadonly(k) &&
        isDone &&
        k.status == KegiatanStatus.selesai &&
        k.imgReferensi == null;
  }

  bool isOngoing(Kegiatan k) {
    final now = DateTime.now();
    final end = k.tanggalSelesai ?? k.tanggalMulai;

    return k.status == KegiatanStatus.dibuat &&
        now.isAfter(k.tanggalMulai) &&
        now.isBefore(end);
  }

  int get totalSemua => _allKegiatan.length;

  int get totalDibuat =>
      _allKegiatan.where((e) => e.status == KegiatanStatus.dibuat).length;

  int get totalSelesai =>
      _allKegiatan.where((e) => e.status == KegiatanStatus.selesai).length;

  int get totalDibatalkan =>
      _allKegiatan.where((e) => e.status == KegiatanStatus.dibatalkan).length;

  String formatTanggal(Kegiatan k) {
    final start = DateFormat("dd MMM yyyy").format(k.tanggalMulai);

    final end = k.tanggalSelesai != null
        ? DateFormat("dd MMM yyyy").format(k.tanggalSelesai!)
        : null;

    return end == null ? start : "$start - $end";
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    selectedImage = File(picked.path);
    notifyListeners();
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result == null) return;

    selectedDocument = File(result.files.single.path!);
    notifyListeners();
  }

  void _clearFile() {
    selectedImage = null;
    selectedDocument = null;
    notifyListeners();
  }

  String? validateKegiatan({
    required KegiatanValidationMode mode,
    required String nama,
    required String deskripsi,
    required DateTime? tanggalMulai,
    required DateTime? tanggalSelesai,

    Kegiatan? kegiatan,
  }) {
    if (nama.trim().isEmpty) {
      return "Nama kegiatan wajib diisi";
    }

    if (deskripsi.trim().isEmpty) {
      return "Deskripsi wajib diisi";
    }

    if (mode == KegiatanValidationMode.create ||
        mode == KegiatanValidationMode.edit) {
      if (tanggalMulai == null) {
        return "Tanggal mulai wajib diisi";
      }

      if (tanggalSelesai == null) {
        return "Tanggal selesai wajib diisi";
      }

      if (tanggalSelesai.isBefore(tanggalMulai)) {
        return "Tanggal selesai tidak boleh sebelum tanggal mulai";
      }
    }

    if (mode == KegiatanValidationMode.create) {
      if (selectedDocument == null) {
        return "Dokumen pendukung wajib diupload";
      }
    }

    if (mode == KegiatanValidationMode.uploadBukti) {
      if (kegiatan == null) {
        return "Data kegiatan tidak valid";
      }

      final selesai = kegiatan.tanggalSelesai ?? kegiatan.tanggalMulai;

      if (!DateTime.now().isAfter(selesai)) {
        return "Kegiatan belum selesai";
      }

      if (selectedImage == null) {
        return "Foto bukti wajib diupload";
      }

      if (kegiatan.imgReferensi != null) {
        return "Bukti sudah pernah diupload";
      }
    }

    return null;
  }
}
