import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';

import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';

enum SuratRwFilterStatus { semua, disetujui, selesai }

class SuratRwViewModel extends ChangeNotifier {
  final WargaRepository wargaRepo;

  SuratRwViewModel(this.wargaRepo);

  File? signedFile;
  bool isUploading = false;
  bool isLoading = false;

  String searchQuery = "";
  SuratRwFilterStatus selectedStatus = SuratRwFilterStatus.semua;

  final List<PengajuanSurat> _allData = [];
  final Map<int, Warga> _wargaMap = {};

  Future<void> pickSignedFile() async {
    try {
      final result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.single.path == null) return;

      signedFile = File(result.files.single.path!);
      notifyListeners();
    } catch (e) {
      debugPrint("ERROR PICK FILE: $e");
    }
  }

  void clearSignedFile() {
    signedFile = null;
    notifyListeners();
  }

  Future<void> uploadSignedSurat({required int id}) async {
    if (signedFile == null) return;

    isUploading = true;
    notifyListeners();

    try {
      //  sesuaikan
      await selesaiSurat(id: id, signedDocument: signedFile!.path);

      clearSignedFile();
    } catch (e) {
      debugPrint("ERROR UPLOAD SURAT: $e");
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  List<PengajuanSurat> get data {
    var result = _filterByStatus(_allData);
    result = _filterBySearch(result);
    return result;
  }

  int get totalDisetujui =>
      _allData.where((e) => e.status == SuratStatus.disetujui).length;

  int get totalSelesai =>
      _allData.where((e) => e.status == SuratStatus.selesai).length;

  int get totalSemua => _allData.length;

  List<PengajuanSurat> _filterByStatus(List<PengajuanSurat> source) {
    switch (selectedStatus) {
      case SuratRwFilterStatus.disetujui:
        return source.where((e) => e.status == SuratStatus.disetujui).toList();

      case SuratRwFilterStatus.selesai:
        return source.where((e) => e.status == SuratStatus.selesai).toList();

      case SuratRwFilterStatus.semua:
        return source;
    }
  }

  List<PengajuanSurat> _filterBySearch(List<PengajuanSurat> source) {
    if (searchQuery.trim().isEmpty) return source;

    final query = searchQuery.toLowerCase().trim();

    return source.where((e) {
      final namaWarga = getNamaWarga(e.wargaId ?? 0).toLowerCase();

      return e.keperluan.toLowerCase().contains(query) ||
          e.keterangan.toLowerCase().contains(query) ||
          namaWarga.contains(query);
    }).toList();
  }

  Future<void> _loadWarga() async {
    try {
      final list = await wargaRepo.getAllWarga();

      _wargaMap.clear();

      for (final w in list) {
        if (w.id != null) {
          _wargaMap[w.id!] = w;
        }
      }
    } catch (e) {
      debugPrint("ERROR LOAD WARGA: $e");
    }
  }

  Warga? getWarga(int wargaId) => _wargaMap[wargaId];

  String getNamaWarga(int wargaId) => _wargaMap[wargaId]?.nama ?? "Warga";

  String getNikWarga(int wargaId) => _wargaMap[wargaId]?.nik ?? "-";

  String getAvatarInitial(int wargaId) {
    final nama = getNamaWarga(wargaId);
    return nama.isNotEmpty ? nama[0].toUpperCase() : "?";
  }

  Future<void> fetchSurat() async {
    try {
      isLoading = true;
      notifyListeners();

      await _loadWarga();

      _loadDummySurat(); //dummy surat
    } catch (e) {
      debugPrint("ERROR FETCH SURAT RW: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _loadDummySurat() {
    _allData.clear();

    _allData.addAll([
      PengajuanSurat(
        id: 1,
        wargaId: 1,
        keperluan: "Surat Domisili",
        keterangan: "Digunakan untuk keperluan kerja",
        status: SuratStatus.disetujui,
        docRef: "https://example.com/surat-domisili.pdf",
        waktuDibuat: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PengajuanSurat(
        id: 2,
        wargaId: 2,
        keperluan: "Surat Pengantar Nikah",
        keterangan: "Digunakan untuk syarat KUA",
        status: SuratStatus.selesai,
        docRef: "https://example.com/surat2.pdf",
        waktuDibuat: DateTime.now().subtract(const Duration(days: 3)),
      ),
      PengajuanSurat(
        id: 3,
        wargaId: 3,
        keperluan: "Surat Keterangan Usaha",
        keterangan: "Untuk pengajuan UMKM",
        status: SuratStatus.disetujui,
        docRef: "https://example.com/surat3.pdf",
        waktuDibuat: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);
  }

  void setStatus(SuratRwFilterStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  void setSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  Future<void> selesaiSurat({
    required int id,
    required String signedDocument,
  }) async {
    final index = _allData.indexWhere((e) => e.id == id);
    if (index == -1) return;

    _allData[index] = _allData[index].copyWith(
      status: SuratStatus.selesai,
      docRef: signedDocument,
    );

    notifyListeners();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "-";

    return "${date.day}/${date.month}/${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> refresh() async {
    await fetchSurat();
  }
}
