import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';

class EditWargaViewModel extends ChangeNotifier {
  final WargaRepository repo;
  final int idWarga;

  EditWargaViewModel({required this.repo, required this.idWarga}) {
    getDetailWarga();
  }

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;

  Warga? warga;

  // ===== FORM FIELDS =====
  String nama = '';
  String nik = '';
  String tempatLahir = '';
  DateTime? tglLahir;

  String? jenisKelamin;
  String? agama;
  String? pendidikan;
  String? pekerjaan;
  String? golonganDarah;

  String? statusPerkawinan;
  DateTime? tglPerkawinan;

  String? kewarganegaraan;
  String? statusHubungan;

  String negaraWNA = '';
  String noPaspor = '';
  String noKITAP = '';

  String namaAyah = '';
  String namaIbu = '';

  // ============================

  Future<void> getDetailWarga() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final result = await repo.getWargaById(idWarga);

      if (result == null) {
        throw Exception("Data warga tidak ditemukan");
      }

      warga = result;

      // ===== init form =====
      nama = result.nama;
      nik = result.nik;
      tempatLahir = result.tempatLahir ?? '';
      tglLahir = result.tglLahir;

      jenisKelamin = result.jk?.display;
      agama = result.agama?.display;
      pendidikan = result.pendidikan;
      pekerjaan = result.jenisPekerjaan;
      golonganDarah = result.golonganDarah;

      statusPerkawinan = result.statusPerkawinan?.display;
      tglPerkawinan = result.tglPerkawinan;

      kewarganegaraan = result.kewarganegaraan?.display;
      statusHubungan = result.statusHubungan?.display;

      negaraWNA = result.wnaNegara ?? '';
      noPaspor = result.noPaspor ?? '';
      noKITAP = result.noKitap ?? '';

      namaAyah = result.namaAyah ?? '';
      namaIbu = result.namaIbu ?? '';

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    }

    isLoading = false;
    notifyListeners();
  }

  // ===== SETTERS =====

  void setNama(String v) {
    nama = v;
    notifyListeners();
  }

  void setNik(String v) {
    nik = v;
    notifyListeners();
  }

  void setTempatLahir(String v) {
    tempatLahir = v;
    notifyListeners();
  }

  void setTanggalLahir(DateTime v) {
    tglLahir = v;
    notifyListeners();
  }

  void setJenisKelamin(String? v) {
    jenisKelamin = v;
    notifyListeners();
  }

  void setAgama(String? v) {
    agama = v;
    notifyListeners();
  }

  void setPendidikan(String? v) {
    pendidikan = v;
    notifyListeners();
  }

  void setPekerjaan(String? v) {
    pekerjaan = v;
    notifyListeners();
  }

  void setGolDarah(String? v) {
    golonganDarah = v;
    notifyListeners();
  }

  void setStatusPerkawinan(String? v) {
    statusPerkawinan = v;
    notifyListeners();
  }

  void setTanggalPerkawinan(DateTime v) {
    tglPerkawinan = v;
    notifyListeners();
  }

  void setKewarganegaraan(String? v) {
    kewarganegaraan = v;
    notifyListeners();
  }

  void setStatusHubungan(String? v) {
    statusHubungan = v;
    notifyListeners();
  }

  void setNegara(String v) {
    negaraWNA = v;
    notifyListeners();
  }

  void setPaspor(String v) {
    noPaspor = v;
    notifyListeners();
  }

  void setKITAP(String v) {
    noKITAP = v;
    notifyListeners();
  }

  void setAyah(String v) {
    namaAyah = v;
    notifyListeners();
  }

  void setIbu(String v) {
    namaIbu = v;
    notifyListeners();
  }

  // ===== UPDATE =====

  Future<void> updateWarga() async {
    try {
      isSaving = true;
      errorMessage = null;
      notifyListeners();

      final warga = Warga(
        nama: nama,
        nik: nik,
        tempatLahir: tempatLahir,
        tglLahir: tglLahir,

        jk: JenisKelamin.from(jenisKelamin),
        agama: Agama.from(agama),
        statusPerkawinan: StatusPerkawinan.from(statusPerkawinan),
        statusHubungan: StatusHubungan.from(statusHubungan),
        kewarganegaraan: Kewarganegaraan.from(kewarganegaraan),

        pendidikan: pendidikan,
        jenisPekerjaan: pekerjaan,
        golonganDarah: golonganDarah,

        tglPerkawinan: tglPerkawinan,
        wnaNegara: negaraWNA,
        noPaspor: noPaspor,
        noKitap: noKITAP,
        namaAyah: namaAyah,
        namaIbu: namaIbu,
      );
      await repo.updateWarga(idWarga, warga);
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    }

    isSaving = false;
    notifyListeners();
  }
}
