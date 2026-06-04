import 'package:flutter/widgets.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';

class AddWargaViewModel extends ChangeNotifier {
  final WargaRepository repo;

  bool isSaving = false;
  String? errorMessage;

  // TextEditingControllers for two-way binding
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController tempatLahirController = TextEditingController();
  final TextEditingController pekerjaanController = TextEditingController();
  final TextEditingController namaAyahController = TextEditingController();
  final TextEditingController namaIbuController = TextEditingController();
  final TextEditingController negaraController = TextEditingController();
  final TextEditingController noPasporController = TextEditingController();
  final TextEditingController noKitapController = TextEditingController();

  String nama = '';
  String nik = '';
  String tempatLahir = '';
  String noPaspor = '';
  String noKitap = '';
  String namaAyah = '';
  String namaIbu = '';

  String? jenisKelamin;
  String? agama;
  String? pendidikan;
  String? pekerjaan;
  String? golonganDarah;
  String? statusPerkawinan;
  String? kewarganegaraan;
  String? statusHubungan;

  String? negara;

  DateTime? tanggalLahir;
  DateTime? tanggalPerkawinan;

  final int kkId;

  AddWargaViewModel({required this.repo, required this.kkId});

  /// Apply scan results from KTP
  void applyScanResults({
    String? scannedNik,
    String? scannedNama,
    String? scannedTempatLahir,
    String? scannedTanggalLahir,
    String? scannedJenisKelamin,
    String? scannedAlamat,
    String? scannedAgama,
    String? scannedStatusPerkawinan,
    String? scannedPekerjaan,
    String? scannedKewarganegaraan,
  }) {
    if (scannedNik != null && scannedNik.isNotEmpty) {
      nik = scannedNik;
      nikController.text = scannedNik;
    }
    if (scannedNama != null && scannedNama.isNotEmpty) {
      nama = scannedNama;
      namaController.text = scannedNama;
    }
    if (scannedTempatLahir != null && scannedTempatLahir.isNotEmpty) {
      tempatLahir = scannedTempatLahir;
      tempatLahirController.text = scannedTempatLahir;
    }
    if (scannedTanggalLahir != null && scannedTanggalLahir.isNotEmpty) {
      // Parse date from DD-MM-YYYY format
      final parts = scannedTanggalLahir.split('-');
      if (parts.length == 3) {
        try {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          tanggalLahir = DateTime(year, month, day);
        } catch (e) {
          print('Failed to parse date: $scannedTanggalLahir');
        }
      }
    }
    if (scannedJenisKelamin != null && scannedJenisKelamin.isNotEmpty) {
      jenisKelamin = scannedJenisKelamin;
    }
    if (scannedAgama != null && scannedAgama.isNotEmpty) {
      agama = scannedAgama;
    }
    if (scannedStatusPerkawinan != null && scannedStatusPerkawinan.isNotEmpty) {
      statusPerkawinan = scannedStatusPerkawinan;
    }
    if (scannedPekerjaan != null && scannedPekerjaan.isNotEmpty) {
      pekerjaan = scannedPekerjaan;
      pekerjaanController.text = scannedPekerjaan;
    }
    if (scannedKewarganegaraan != null && scannedKewarganegaraan.isNotEmpty) {
      kewarganegaraan = scannedKewarganegaraan;
    }
    notifyListeners();
  }

  void setNama(String v) => _set(() => nama = v);
  void setNik(String v) => _set(() => nik = v);
  void setTempatLahir(String v) => _set(() => tempatLahir = v);

  void setJenisKelamin(String? v) => _set(() => jenisKelamin = v);
  void setAgama(String? v) => _set(() => agama = v);
  void setPendidikan(String? v) => _set(() => pendidikan = v);
  void setPekerjaan(String? v) => _set(() => pekerjaan = v);
  void setGolDarah(String? v) => _set(() => golonganDarah = v);
  void setStatusPerkawinan(String? v) => _set(() => statusPerkawinan = v);
  void setStatusHubungan(String? v) => _set(() => statusHubungan = v);

  void setKewarganegaraan(String? v) {
    kewarganegaraan = v;

    if (v != 'WNA') {
      negara = null;
    }

    notifyListeners();
  }

  void setNegara(String v) => _set(() => negara = v);

  void setTanggalLahir(DateTime v) => _set(() => tanggalLahir = v);
  void setTanggalPerkawinan(DateTime v) => _set(() => tanggalPerkawinan = v);

  void _set(Function fn) {
    fn();
    notifyListeners();
  }

  bool _validate() {
    if (nama.isEmpty) return _error("Nama wajib diisi");
    if (nik.isEmpty) return _error("NIK wajib diisi");
    if (jenisKelamin == null) return _error("Jenis kelamin wajib dipilih");

    return true;
  }

  bool _error(String msg) {
    errorMessage = msg;
    return false;
  }

  JenisKelamin? _jkEnum() {
    switch (jenisKelamin) {
      case 'Laki-Laki':
        return JenisKelamin.lakiLaki;
      case 'Perempuan':
        return JenisKelamin.perempuan;
    }
    return null;
  }

  Agama? _agamaEnum() {
    switch (agama) {
      case 'Islam':
        return Agama.islam;
      case 'Kristen':
        return Agama.kristen;
      case 'Katolik':
        return Agama.katolik;
      case 'Hindu':
        return Agama.hindu;
      case 'Buddha':
        return Agama.buddha;
      case 'Konghucu':
        return Agama.konghucu;
    }
    return null;
  }

  StatusPerkawinan? _statusKawinEnum() {
    switch (statusPerkawinan) {
      case 'Belum Kawin':
        return StatusPerkawinan.belumKawin;
      case 'Kawin':
        return StatusPerkawinan.kawin;
      case 'Cerai Hidup':
        return StatusPerkawinan.ceraiHidup;
      case 'Cerai Mati':
        return StatusPerkawinan.ceraiMati;
    }
    return null;
  }

  StatusHubungan? _statusHubunganEnum() {
    switch (statusHubungan) {
      case 'Kepala Keluarga':
        return StatusHubungan.kepalaKeluarga;
      case 'Suami':
        return StatusHubungan.suami;
      case 'Istri':
        return StatusHubungan.istri;
      case 'Anak':
        return StatusHubungan.anak;
      case 'Menantu':
        return StatusHubungan.menantu;
      case 'Cucu':
        return StatusHubungan.cucu;
      case 'Orang Tua':
        return StatusHubungan.orangTua;
      case 'Mertua':
        return StatusHubungan.mertua;
      case 'Famili Lain':
        return StatusHubungan.familiLain;
    }
    return null;
  }

  Kewarganegaraan? _kwnEnum() {
    switch (kewarganegaraan) {
      case 'WNI':
        return Kewarganegaraan.wni;
      case 'WNA':
        return Kewarganegaraan.wna;
    }
    return null;
  }

  String? _nullable(String v) {
    return v.trim().isEmpty ? null : v;
  }

  Future<bool> saveWarga(Keluarga kel) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (!_validate()) throw Exception(errorMessage);

      final warga = Warga(
        nama: nama,
        nik: nik,
        jk: _jkEnum(),
        tempatLahir: _nullable(tempatLahir),
        tglLahir: tanggalLahir,
        agama: _agamaEnum(),
        pendidikan: _nullable(pendidikan ?? ''),
        jenisPekerjaan: _nullable(pekerjaan ?? ''),
        golonganDarah: _nullable(golonganDarah ?? ''),
        statusPerkawinan: _statusKawinEnum(),
        tglPerkawinan: tanggalPerkawinan,
        statusHubungan: _statusHubunganEnum(),
        kewarganegaraan: _kwnEnum(),
        wnaNegara: _nullable(negara ?? ''),
        noPaspor: _nullable(noPaspor),
        noKitap: _nullable(noKitap),
        namaAyah: _nullable(namaAyah),
        namaIbu: _nullable(namaIbu),
        keluarga: kel,
      );

      await repo.createWarga(warga);

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    tempatLahirController.dispose();
    pekerjaanController.dispose();
    namaAyahController.dispose();
    namaIbuController.dispose();
    negaraController.dispose();
    noPasporController.dispose();
    noKitapController.dispose();
    super.dispose();
  }
}
