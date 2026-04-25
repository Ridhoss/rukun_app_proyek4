import 'package:flutter/foundation.dart';
import 'package:rukun_app_proyek4/models/warga.dart';
import 'package:rukun_app_proyek4/services/warga_service.dart';

// ================================================================
// WargaViewModel
// Tanggung jawab: menyimpan state form warga + submit ke service.
//
// PEMBAGIAN KERJA:
//   ViewModel (FE) : definisi state, notifyListeners, struktur method
//   Service  (BE)  : isi koneksi Hive / API di warga_service.dart
// ================================================================

class WargaViewModel extends ChangeNotifier {
  final WargaService _service;

  WargaViewModel({WargaService? service})
    : _service = service ?? WargaService();

  // ── State ──────────────────────────────────────────────────────

  bool isLoading = false;
  bool isSaved = false;
  String? errorMessage;

  // Field state (non-text — dropdown & date tidak pakai TextEditingController)
  String? selectedJK;
  DateTime? tglLahir;
  DateTime? tglPerkawinan;
  String? selectedAgama;
  String? selectedPendidikan;
  String? selectedPekerjaan;
  String? selectedGolDarah;
  String? selectedStatusKawin;
  String? selectedStatusHubungan;
  String? selectedKewarganegaraan;

  // ── Init (mode edit) ───────────────────────────────────────────

  void populateFromModel(WargaModel w) {
    selectedJK = w.jk;
    tglLahir = w.tglLahir;
    tglPerkawinan = w.tglPerkawinan;
    selectedAgama = w.agama;
    selectedPendidikan = w.pendidikan;
    selectedPekerjaan = w.jenisPekerjaan;
    selectedGolDarah = w.golonganDarah;
    selectedStatusKawin = w.statusPerkawinan;
    selectedStatusHubungan = w.statusHubungan;
    selectedKewarganegaraan = w.kewarganegaraan;
    notifyListeners();
  }

  // ── Setters dropdown ───────────────────────────────────────────

  void setJK(String? v) {
    selectedJK = v;
    notifyListeners();
  }

  void setTglLahir(DateTime? v) {
    tglLahir = v;
    notifyListeners();
  }

  void setTglPerkawinan(DateTime? v) {
    tglPerkawinan = v;
    notifyListeners();
  }

  void setAgama(String? v) {
    selectedAgama = v;
    notifyListeners();
  }

  void setPendidikan(String? v) {
    selectedPendidikan = v;
    notifyListeners();
  }

  void setPekerjaan(String? v) {
    selectedPekerjaan = v;
    notifyListeners();
  }

  void setGolDarah(String? v) {
    selectedGolDarah = v;
    notifyListeners();
  }

  void setStatusKawin(String? v) {
    selectedStatusKawin = v;
    notifyListeners();
  }

  void setStatusHubungan(String? v) {
    selectedStatusHubungan = v;
    notifyListeners();
  }

  void setKewarganegaraan(String? v) {
    selectedKewarganegaraan = v;
    notifyListeners();
  }

  // ── Save / Update ──────────────────────────────────────────────

  /// Simpan warga baru.
  /// TODO (BE): isi _service.saveWarga() di warga_service.dart.
  Future<bool> saveWarga(WargaModel warga) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final success = await _service.saveWarga(warga);

    isLoading = false;
    if (success) {
      isSaved = true;
    } else {
      errorMessage =
          _service.lastError ?? 'Gagal menyimpan data warga. Coba lagi.';
    }
    notifyListeners();
    return success;
  }

  /// Update warga yang sudah ada.
  /// TODO (BE): isi _service.updateWarga() di warga_service.dart.
  Future<bool> updateWarga(String id, WargaModel warga) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final success = await _service.updateWarga(id, warga);

    isLoading = false;
    if (!success) {
      errorMessage = _service.lastError ?? 'Gagal memperbarui data. Coba lagi.';
    }
    notifyListeners();
    return success;
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
