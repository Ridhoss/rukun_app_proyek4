import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';

enum SuratRwFilterStatus { semua, disetujui, selesai }

class SuratRwViewModel extends ChangeNotifier {

  bool isLoading = false;
  String searchQuery = "";
  SuratRwFilterStatus selectedStatus = SuratRwFilterStatus.semua;

  final List<PengajuanSurat> _allData = [];
  final Map<int, Warga> _wargaMap = {};

  List<PengajuanSurat> get data {
    List<PengajuanSurat> result = _filterByStatus(_allData);

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
    if (searchQuery.isEmpty) {
      return source;
    }

    final query = searchQuery.toLowerCase();

    return source.where((e) {
      final namaWarga = getNamaWarga(e.wargaId ?? 0).toLowerCase();

      return e.keperluan.toLowerCase().contains(query) ||
          e.keterangan.toLowerCase().contains(query) ||
          namaWarga.contains(query);
    }).toList();
  }


  Warga? getWarga(int wargaId) {
    return _wargaMap[wargaId];
  }

  String getNamaWarga(int wargaId) {
    return _wargaMap[wargaId]?.nama ?? "Warga";
  }

  String getNikWarga(int wargaId) {
    return _wargaMap[wargaId]?.nik ?? "-";
  }

  String getAvatarInitial(int wargaId) {
    final nama = getNamaWarga(wargaId);

    if (nama.isEmpty) {
      return "?";
    }

    return nama[0].toUpperCase();
  }


  Future<void> fetchSurat() async {
    try {
      isLoading = true;

      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 700));

      _loadDummyWarga();

      _loadDummySurat();
    } catch (e) {
      debugPrint("ERROR FETCH SURAT RW: $e");
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }

  void _loadDummyWarga() {
    _wargaMap.clear();

    final warga1 = Warga(id: 1, nik: "3201010101010001", nama: "Budi Santoso");

    final warga2 = Warga(id: 2, nik: "3201010101010002", nama: "Aira Putri");

    final warga3 = Warga(
      id: 3,
      nik: "3201010101010003",
      nama: "Rizky Ramadhan",
    );

    _wargaMap[1] = warga1;
    _wargaMap[2] = warga2;
    _wargaMap[3] = warga3;
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
        docRef: "https://bckendari.id/assets/web/download/dummy1.pdf",
        waktuDibuat: DateTime.now().subtract(const Duration(days: 3)),
      ),

      PengajuanSurat(
        id: 3,
        wargaId: 3,
        keperluan: "Surat Keterangan Usaha",
        keterangan: "Untuk pengajuan UMKM",
        status: SuratStatus.disetujui,
        docRef: "https://bckendari.id/assets/web/download/dummy1.pdf",
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

  Future<void> refresh() async {
    await fetchSurat();
  }
}
