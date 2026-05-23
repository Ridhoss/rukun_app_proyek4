import 'dart:io';

import 'package:flutter/material.dart';

import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';

import 'package:rukun_app_proyek4/repositories/surat_repository.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';

enum SuratFilterStatus { semua, diajukan, disetujui, ditolak, selesai }

class SuratViewModel extends ChangeNotifier {
  final WargaRepository wargaRepo;
  final SuratRepository suratRepo;
  final CloudinaryService cloudinaryService;
  final AuthViewModel authVm;

  SuratViewModel(
    this.wargaRepo,
    this.suratRepo,
    this.cloudinaryService,
    this.authVm,
  );

  bool isUploading = false;
  bool isLoading = false;

  String searchQuery = "";
  SuratFilterStatus selectedStatus = SuratFilterStatus.semua;

  final List<PengajuanSurat> _allData = [];
  final Map<int, Warga> _wargaMap = {};

  Future<bool> uploadDraftByRt({required int id, required File file}) async {
    isUploading = true;
    notifyListeners();

    try {
      final url = await cloudinaryService.uploadFile(
        file,
        folder: 'surat/pengajuan/$id',
      );

      if (url == null) return false;

      final body = {
        "status": "Disetujui",
        "doc_referensi": url,
        "is_signed": false,
        "disetujui_oleh": authVm.currentUser?.id,
      };

      await suratRepo.updateSurat(id, body);

      final index = _allData.indexWhere((e) => e.id == id);

      if (index != -1) {
        _allData[index] = _allData[index].copyWith(
          status: SuratStatus.disetujui,
          docRef: url,
          isSigned: false,
        );
      }

      return true;
    } catch (e) {
      debugPrint("ERROR RT UPLOAD: $e");
      return false;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadSignedByRw({required int id, required File file}) async {
    isUploading = true;
    notifyListeners();

    try {
      final url = await cloudinaryService.uploadFile(
        file,
        folder: 'surat/pengajuan/$id',
      );

      if (url == null) return false;
      
      final body = {
        "status": "Selesai",
        "doc_referensi": url,
        "is_signed": true,
        "disetujui_oleh": authVm.currentUser?.id,
      };

      await suratRepo.updateSurat(id, body);

      final index = _allData.indexWhere((e) => e.id == id);

      if (index != -1) {
        _allData[index] = _allData[index].copyWith(
          status: SuratStatus.selesai,
          docRef: url,
          isSigned: true,
        );
      }

      return true;
    } catch (e) {
      debugPrint("ERROR RW UPLOAD: $e");
      return false;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  List<PengajuanSurat> get data {
    var result = _filterByStatus(accessibleData);
    result = _filterBySearch(result);

    return result;
  }

  int get totalDitolak =>
      _allData.where((e) => e.status == SuratStatus.ditolak).length;

  int get totalDisetujui =>
      _allData.where((e) => e.status == SuratStatus.disetujui).length;

  int get totalSelesai =>
      _allData.where((e) => e.status == SuratStatus.selesai).length;

  int get totalDiajukan =>
      _allData.where((e) => e.status == SuratStatus.diajukan).length;

  int get totalSemua => _allData.length;

  List<PengajuanSurat> _filterByStatus(List<PengajuanSurat> source) {
    switch (selectedStatus) {
      case SuratFilterStatus.diajukan:
        return source.where((e) => e.status == SuratStatus.diajukan).toList();

      case SuratFilterStatus.disetujui:
        return source.where((e) => e.status == SuratStatus.disetujui).toList();

      case SuratFilterStatus.selesai:
        return source.where((e) => e.status == SuratStatus.selesai).toList();

      case SuratFilterStatus.ditolak:
        return source.where((e) => e.status == SuratStatus.ditolak).toList();

      case SuratFilterStatus.semua:
        return source;
    }
  }

  List<PengajuanSurat> _filterBySearch(List<PengajuanSurat> source) {
    if (searchQuery.trim().isEmpty) return source;

    final query = searchQuery.toLowerCase().trim();

    return source.where((e) {
      final namaWarga = getNamaWarga(e.wargaId ?? 0).toLowerCase();

      final keperluan = (e.keperluan).toLowerCase();

      final keterangan = (e.keterangan ?? '').toLowerCase();

      return keperluan.contains(query) ||
          keterangan.contains(query) ||
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

  Future<void> fetchSurat({required int rwId}) async {
    try {
      isLoading = true;
      notifyListeners();

      await _loadWarga();

      final result = await suratRepo.getSuratByRw(rwId);

      _allData.clear();
      _allData.addAll(result);
    } catch (e) {
      debugPrint("ERROR FETCH SURAT: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<PengajuanSurat> get accessibleData {
    final user = authVm.currentUser;

    if (user?.pengurus?.level == "RW") {
      return _allData;
    }

    if (user?.pengurus?.level == "RT") {
      final rtId = user?.rt?.id;

      return _allData.where((e) {
        final warga = getWarga(e.wargaId ?? 0);

        return warga?.keluarga?.rtId == rtId;
      }).toList();
    }

    return [];
  }

  void setStatus(SuratFilterStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  void setSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  Future<void> setujuiSurat({
    required int id,
    required String signedDocument,
  }) async {
    final index = _allData.indexWhere((e) => e.id == id);

    if (index == -1) return;

    _allData[index] = _allData[index].copyWith(
      status: SuratStatus.disetujui,
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

  Future<void> refresh({required int rwId}) async {
    await fetchSurat(rwId: rwId);
  }
}
