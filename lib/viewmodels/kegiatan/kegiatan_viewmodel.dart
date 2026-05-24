import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/repositories/kegiatan_repository.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';

enum KegiatanFilterStatus { semua, dibuat, dibatalkan, selesai }

enum KegiatanValidationMode { create, uploadBukti, edit }

class KegiatanViewModel extends ChangeNotifier {
  static const int createKey = -1;
  final KegiatanRepository repository;
  final CloudinaryService cloudinaryService;

  KegiatanViewModel(this.repository, this.cloudinaryService);

  User? _currentUser;
  User? get currentUser => _currentUser;
  List<Kegiatan> _allKegiatan = [];

  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  final Map<int, File?> _selectedImages = {};
  final Map<int, File?> _selectedDocuments = {};

  File? getSelectedImage(int kegiatanId) {
    return _selectedImages[kegiatanId];
  }

  File? getSelectedDocument(int kegiatanId) {
    return _selectedDocuments[kegiatanId];
  }

  KegiatanLevel selectedLevel = KegiatanLevel.rw;
  KegiatanFilterStatus selectedStatus = KegiatanFilterStatus.semua;

  String _searchQuery = "";

  Future<void> fetchKegiatan() async {
    try {
      _setLoading(true);
      _setError(null);

      _allKegiatan = await repository.getAllKegiatan();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
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
    notifyListeners();
  }

  void setStatus(KegiatanFilterStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
  }

  void setSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<bool> createKegiatan({
    required String nama,
    required String deskripsi,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final document = _selectedDocuments[createKey];

      if (document == null) {
        throw Exception("Dokumen wajib diupload");
      }

      if (_currentUser == null) {
        throw Exception("User belum dimuat");
      }

      final docUrl = await cloudinaryService.uploadFile(
        document,
        folder: 'kegiatan/dokumen',
      );

      if (docUrl == null) {
        throw Exception("Upload dokumen gagal");
      }

      final kegiatan = Kegiatan(
        id: null,
        nama: nama,
        deskripsi: deskripsi,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        level: selectedLevel,
        rwId: _currentUser!.rw!.id,
        rtId: selectedLevel == KegiatanLevel.rt ? _currentUser!.rt?.id : null,
        status: KegiatanStatus.dibuat,
        docReferensi: docUrl,
        imgReferensi: null,
        waktuDibuat: DateTime.now(),
      );

      await repository.createKegiatan(kegiatan);

      await fetchKegiatan();
      clearFiles(createKey);

      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  void _setError(dynamic e) {
    _errorMessage = e.toString().replaceAll("Exception: ", "");
    notifyListeners();
  }

  Future<void> updateKegiatan({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final document = _selectedDocuments[id];

      if (document != null) {
        final documentUrl = await cloudinaryService.uploadFile(
          document,
          folder: 'kegiatan/dokumen',
        );

        if (documentUrl == null) {
          throw Exception("Upload dokumen gagal");
        }

        data['doc_referensi'] = documentUrl;
      }

      await repository.updateKegiatan(id, data);

      clearFiles(id);

      await fetchKegiatan();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteKegiatan(int id) async {
    try {
      await repository.deleteKegiatan(id);
      await fetchKegiatan();
    } catch (e) {
      _setError(e);
      notifyListeners();
    }
  }

  Future<void> uploadBuktiKegiatan(int kegiatanId) async {
    try {
      _setUploading(true);

      final image = _selectedImages[kegiatanId];

      if (image == null) {
        throw Exception("Foto bukti wajib diupload");
      }

      final url = await cloudinaryService.uploadFile(
        image,
        folder: 'kegiatan/$kegiatanId',
      );

      if (url == null) {
        throw Exception("Upload gambar gagal");
      }

      await repository.updateKegiatan(kegiatanId, {
        "img_referensi": url,
        "status": "Selesai",
      });

      clearFiles(kegiatanId);

      await fetchKegiatan();
    } catch (e) {
      _setError(e);
    } finally {
      _setUploading(false);
    }
  }

  void clearUpload(int kegiatanId) {
    _selectedImages.remove(kegiatanId);
    _selectedDocuments.remove(kegiatanId);

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

    final sudahLewatTanggal = DateTime.now().isAfter(selesai);

    return !isReadonly(k) &&
        sudahLewatTanggal &&
        k.status == KegiatanStatus.dibuat &&
        k.imgReferensi == null;
  }

  bool isMenungguBukti(Kegiatan k) {
    final selesai = k.tanggalSelesai ?? k.tanggalMulai;

    return DateTime.now().isAfter(selesai) &&
        k.status == KegiatanStatus.dibuat &&
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

  Future<void> pickImage(int kegiatanId) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    _selectedImages[kegiatanId] = File(picked.path);

    notifyListeners();
  }

  Future<void> pickDocument(int kegiatanId) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result == null) return;

    final path = result.files.single.path;

    if (path == null) return;

    _selectedDocuments[kegiatanId] = File(path);

    notifyListeners();
  }

  void clearFiles(int kegiatanId) {
    _selectedImages.remove(kegiatanId);
    _selectedDocuments.remove(kegiatanId);

    notifyListeners();
  }

  String? validateKegiatan({
    required int fileKey,
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
      if (_selectedDocuments[fileKey] == null) {
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

      if (_selectedImages[fileKey] == null) {
        return "Foto bukti wajib diupload";
      }

      if (kegiatan.imgReferensi != null) {
        return "Bukti sudah pernah diupload";
      }
    }

    return null;
  }
}
