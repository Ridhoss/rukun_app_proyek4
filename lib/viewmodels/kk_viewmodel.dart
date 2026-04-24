import 'package:flutter/foundation.dart';
import 'package:rukun_app_proyek4/models/keluarga.dart';
import 'package:rukun_app_proyek4/services/warga_service.dart';

// ================================================================
// KKViewModel
// Tanggung jawab: menyimpan state form KK + manajemen anggota.
//
// PEMBAGIAN KERJA:
//   ViewModel (FE) : definisi state, notifyListeners, struktur method
//   Service  (BE)  : isi koneksi Hive / API di warga_service.dart
// ================================================================

class KKViewModel extends ChangeNotifier {
  final WargaService _service;

  KKViewModel({WargaService? service}) : _service = service ?? WargaService();

  // ── State ──────────────────────────────────────────────────────

  bool isLoadingRT = true;
  bool isLoadingKK = false;
  bool kkSaved = false;

  String? errorMessage;

  List<Map<String, dynamic>> rtList = [];
  int? selectedRTId;
  int? savedKKId; // diisi BE setelah KK berhasil disimpan

  List<WargaModel> anggotaList = [];

  // ── Init ───────────────────────────────────────────────────────

  Future<void> init({Keluarga? editData}) async {
    await loadRTList();
    if (editData != null) {
      selectedRTId = editData.rtId;
      kkSaved = true;
      savedKKId = editData.id;
      if (editData.id != null) {
        anggotaList = await _service.getWargaByKK(editData.id!);
      }
    }
    notifyListeners();
  }

  // ── RT List ────────────────────────────────────────────────────

  /// Load daftar RT untuk dropdown.
  /// TODO (BE): sambungkan _service.getRTList() ke Hive / API.
  Future<void> loadRTList() async {
    isLoadingRT = true;
    notifyListeners();

    rtList = await _service.getRTList();

    isLoadingRT = false;
    notifyListeners();
  }

  void selectRT(int? id) {
    selectedRTId = id;
    notifyListeners();
  }

  // ── Save KK ────────────────────────────────────────────────────

  /// Simpan data KK baru / update KK.
  /// TODO (BE): isi _service.saveKK() / _service.updateKK() di warga_service.dart.
  Future<bool> saveKK(Keluarga kk) async {
    isLoadingKK = true;
    errorMessage = null;
    notifyListeners();

    final success = await _service.saveKK(kk);

    isLoadingKK = false;
    if (success) {
      kkSaved = true;
      savedKKId = _service.lastSavedKKId;
    } else {
      errorMessage = _service.lastError ?? 'Gagal menyimpan KK. Coba lagi.';
    }
    notifyListeners();
    return success;
  }

  /// Buka kembali form KK untuk diedit.
  void unlockKK() {
    kkSaved = false;
    notifyListeners();
  }

  // ── Anggota Keluarga ────────────────────────────────────────────

  void addAnggota(WargaModel warga) {
    anggotaList = [...anggotaList, warga];
    notifyListeners();
  }

  void updateAnggota(int index, WargaModel updated) {
    final list = [...anggotaList];
    list[index] = updated;
    anggotaList = list;
    notifyListeners();
  }

  /// Hapus anggota dari list lokal.
  /// TODO (BE): panggil _service.deleteWarga(id) sebelum remove dari list.
  Future<void> removeAnggota(int index) async {
    final wargaId = anggotaList[index].id;
    if (wargaId != null) {
      await _service.deleteWarga(wargaId.toString());
    }
    final list = [...anggotaList];
    list.removeAt(index);
    anggotaList = list;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
