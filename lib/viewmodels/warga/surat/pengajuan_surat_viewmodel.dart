import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';

enum FilterSurat { semua, tertunda, disetujui, ditolak, selesai }

class PengajuanSuratViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  final List<PengajuanSurat> _list = [];
  List<PengajuanSurat> get list => _filteredList;

  FilterSurat selectedFilter = FilterSurat.semua;

// dummy data
  Future<void> fetchDummy() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _list.clear();
    _list.addAll([
      PengajuanSurat(
        id: 1,
        wargaId: 1,
        jenisSurat: "Surat Domisili",
        subjectKeperluan: "Keperluan kerja",
        keterangan: "Melamar pekerjaan",
        status: SuratStatus.tertunda,
        waktuDibuat: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PengajuanSurat(
        id: 2,
        wargaId: 1,
        jenisSurat: "Surat Pengantar KTP",
        subjectKeperluan: "Pembuatan KTP",
        keterangan: "KTP hilang",
        status: SuratStatus.disetujui,
        waktuDibuat: DateTime.now().subtract(const Duration(days: 3)),
      ),
      PengajuanSurat(
        id: 3,
        wargaId: 1,
        jenisSurat: "SKTM",
        subjectKeperluan: "Beasiswa",
        keterangan: "Pengajuan bantuan",
        status: SuratStatus.ditolak,
        waktuDibuat: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ]);

    isLoading = false;
    notifyListeners();
  }

// filter surat
  void setFilter(FilterSurat f) {
    selectedFilter = f;
    notifyListeners();
  }

  List<PengajuanSurat> get _filteredList {
    if (selectedFilter == FilterSurat.semua) return _list;

    return _list.where((e) {
      switch (selectedFilter) {
        case FilterSurat.tertunda:
          return e.status == SuratStatus.tertunda;
        case FilterSurat.disetujui:
          return e.status == SuratStatus.disetujui;
        case FilterSurat.ditolak:
          return e.status == SuratStatus.ditolak;
        case FilterSurat.selesai:
          return e.status == SuratStatus.selesai;
        default:
          return true;
      }
    }).toList();
  }

// total per status
  int get totalTertunda =>
      _list.where((e) => e.status == SuratStatus.tertunda).length;

  int get totalDisetujui =>
      _list.where((e) => e.status == SuratStatus.disetujui).length;

  int get totalDitolak =>
      _list.where((e) => e.status == SuratStatus.ditolak).length;

  int get totalSelesai =>
      _list.where((e) => e.status == SuratStatus.selesai).length;

// simpan surat
  Future<bool> submit(PengajuanSurat data) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _list.insert(
      0,
      data.copyWith(
        id: _list.length + 1,
        waktuDibuat: DateTime.now(),
        status: SuratStatus.tertunda,
      ),
    );

    isLoading = false;
    notifyListeners();
    return true;
  }
}
