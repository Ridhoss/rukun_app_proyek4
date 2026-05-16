import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/repositories/surat_repository.dart';

enum SuratFilterStatus { semua, diajukan, disetujui, ditolak, selesai }

class SuratRwViewModel extends ChangeNotifier {
  final SuratRepository repository;

  SuratRwViewModel(this.repository);

  bool isLoading = false;

  List<PengajuanSurat> _allData = [];

  String searchQuery = "";

  SuratFilterStatus selectedStatus = SuratFilterStatus.semua;

  final Map<int, String> wargaDummy = {
    1: "Budi Santoso",
    2: "Aira Putri",
    3: "Ali Putra",
  };

  String getNamaWarga(int wargaId) {
    return wargaDummy[wargaId] ?? "Warga";
  }

  List<PengajuanSurat> get data {
    List<PengajuanSurat> result = [..._allData];

    switch (selectedStatus) {
      case SuratFilterStatus.diajukan:
        result = result.where((e) => e.status == SuratStatus.diajukan).toList();
        break;

      case SuratFilterStatus.disetujui:
        result = result
            .where((e) => e.status == SuratStatus.disetujui)
            .toList();
        break;

      case SuratFilterStatus.ditolak:
        result = result.where((e) => e.status == SuratStatus.ditolak).toList();
        break;

      case SuratFilterStatus.selesai:
        result = result.where((e) => e.status == SuratStatus.selesai).toList();
        break;

      case SuratFilterStatus.semua:
        break;
    }

    if (searchQuery.isNotEmpty) {
      result = result.where((e) {
        final query = searchQuery.toLowerCase();

        return e.keperluan.toLowerCase().contains(query) ||
            e.keterangan.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  int get totalDiajukan =>
      _allData.where((e) => e.status == SuratStatus.diajukan).length;

  int get totalDitolak =>
      _allData.where((e) => e.status == SuratStatus.ditolak).length;

  int get totalSelesai =>
      _allData.where((e) => e.status == SuratStatus.selesai).length;

  int get totalSemua => _allData.length;

  Future<void> fetchSurat() async {
    try {
      isLoading = true;

      notifyListeners();

      await Future.delayed(const Duration(seconds: 1));

      _allData = [
        PengajuanSurat(
          id: 1,
          wargaId: 1,
          keperluan: "Surat Domisili",
          keterangan: "Keperluan kerja",
          status: SuratStatus.diajukan,
          docRef:
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        ),

        PengajuanSurat(
          id: 2,
          wargaId: 2,
          keperluan: "Surat Pindah",
          keterangan: "Pindah luar kota",
          status: SuratStatus.selesai,
          docRef:
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        ),

        PengajuanSurat(
          id: 3,
          wargaId: 3,
          keperluan: "Surat Usaha",
          keterangan: "UMKM",
          status: SuratStatus.ditolak,
          docRef:
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        ),
      ];

      // _allData =
      //    await repository.getAllSurat();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setStatus(SuratFilterStatus status) {
    selectedStatus = status;

    notifyListeners();
  }

  void setSearch(String value) {
    searchQuery = value;

    notifyListeners();
  }

  Future<void> rejectSurat({required int id, required String reason}) async {
    final index = _allData.indexWhere((e) => e.id == id);

    if (index != -1) {
      _allData[index] = _allData[index].copyWith(status: SuratStatus.ditolak);

      notifyListeners();
    }
  }

  Future<void> approveSurat({
    required int id,
    required String signedDocPath,
  }) async {
    final index = _allData.indexWhere((e) => e.id == id);

    if (index != -1) {
      _allData[index] = _allData[index].copyWith(
        status: SuratStatus.selesai,
        docRef: signedDocPath,
      );

      notifyListeners();
    }
  }
}
