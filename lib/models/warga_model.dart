enum JenisKelamin { lakiLaki, perempuan }

enum Agama { islam, kristen, katolik, hindu, buddha, konghucu }

enum StatusPerkawinan { belumKawin, kawin, ceraiHidup, ceraiMati }

enum StatusHubungan {
  kepalaKeluarga,
  suami,
  istri,
  anak,
  menantu,
  cucu,
  orangTua,
  mertua,
  familiLain,
}

enum Kewarganegaraan { wni, wna }

class Warga {
  final int? id;
  final String nama;
  final String nik;

  final JenisKelamin? jk;
  final String? tempatLahir;
  final DateTime? tglLahir;

  final Agama? agama;
  final String? pendidikan;
  final String? jenisPekerjaan;
  final String? golonganDarah;

  final StatusPerkawinan? statusPerkawinan;
  final DateTime? tglPerkawinan;

  final StatusHubungan? statusHubungan;
  final Kewarganegaraan? kewarganegaraan;
  final String? wnaNegara;

  final String? noPaspor;
  final String? noKitap;

  final String? namaAyah;
  final String? namaIbu;

  final int? keluargaId;

  Warga({
    this.id,
    required this.nama,
    required this.nik,
    this.jk,
    this.tempatLahir,
    this.tglLahir,
    this.agama,
    this.pendidikan,
    this.jenisPekerjaan,
    this.golonganDarah,
    this.statusPerkawinan,
    this.tglPerkawinan,
    this.statusHubungan,
    this.kewarganegaraan,
    this.wnaNegara,
    this.noPaspor,
    this.noKitap,
    this.namaAyah,
    this.namaIbu,
    this.keluargaId,
  });

  factory Warga.fromJson(Map<String, dynamic> json) {
    return Warga(
      id: json['id'] as int?,
      nama: json['nama'],
      nik: json['nik'],

      jk: _parseJenisKelamin(json['jk']),
      agama: _parseAgama(json['agama']),
      statusPerkawinan: _parseStatusKawin(json['status_perkawinan']),
      statusHubungan: _parseStatusHubungan(json['status_hubungan']),
      kewarganegaraan: _parseKwn(json['kewarganegaraan']),
      wnaNegara: json['wna_negara'],

      tempatLahir: json['tempat_lahir'],
      tglLahir: json['tgl_lahir'] != null
          ? DateTime.parse(json['tgl_lahir'])
          : null,

      pendidikan: json['pendidikan'],
      jenisPekerjaan: json['jenis_pekerjaan'],
      golonganDarah: json['golongan_darah'],

      tglPerkawinan: json['tgl_perkawinan'] != null
          ? DateTime.parse(json['tgl_perkawinan'])
          : null,

      noPaspor: json['no_paspor'],
      noKitap: json['no_kitap'],
      namaAyah: json['nama_ayah'],
      namaIbu: json['nama_ibu'],

      keluargaId: json['keluarga_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nik': nik,

      'jk': _jkToString(jk),
      'tempat_lahir': tempatLahir,
      'tgl_lahir': tglLahir != null
          ? "${tglLahir!.year.toString().padLeft(4, '0')}-${tglLahir!.month.toString().padLeft(2, '0')}-${tglLahir!.day.toString().padLeft(2, '0')}"
          : null,

      'agama': _agamaToString(agama),
      'pendidikan': pendidikan,
      'jenis_pekerjaan': jenisPekerjaan,
      'golongan_darah': golonganDarah,

      'status_perkawinan': _statusKawinToString(statusPerkawinan),
      'tgl_perkawinan': tglPerkawinan != null
          ? "${tglPerkawinan!.year.toString().padLeft(4, '0')}-${tglPerkawinan!.month.toString().padLeft(2, '0')}-${tglPerkawinan!.day.toString().padLeft(2, '0')}"
          : null,

      'status_hubungan': _statusHubunganToString(statusHubungan),
      'kewarganegaraan': _kwnToString(kewarganegaraan),
      'wna_negara': wnaNegara,

      'no_paspor': noPaspor,
      'no_kitap': noKitap,
      'nama_ayah': namaAyah,
      'nama_ibu': namaIbu,

      'keluarga_id': keluargaId,
    };
  }

  static JenisKelamin? _parseJenisKelamin(String? value) {
    switch (value) {
      case "Laki-Laki":
        return JenisKelamin.lakiLaki;
      case "Perempuan":
        return JenisKelamin.perempuan;
      default:
        return null;
    }
  }

  static Agama? _parseAgama(String? value) {
    switch (value) {
      case "Islam":
        return Agama.islam;
      case "Kristen":
        return Agama.kristen;
      case "Katolik":
        return Agama.katolik;
      case "Hindu":
        return Agama.hindu;
      case "Buddha":
        return Agama.buddha;
      case "Konghucu":
        return Agama.konghucu;
      default:
        return null;
    }
  }

  static StatusPerkawinan? _parseStatusKawin(String? value) {
    switch (value) {
      case "Belum Kawin":
        return StatusPerkawinan.belumKawin;
      case "Kawin":
        return StatusPerkawinan.kawin;
      case "Cerai Hidup":
        return StatusPerkawinan.ceraiHidup;
      case "Cerai Mati":
        return StatusPerkawinan.ceraiMati;
      default:
        return null;
    }
  }

  static StatusHubungan? _parseStatusHubungan(String? value) {
    switch (value) {
      case "Kepala_Keluarga":
        return StatusHubungan.kepalaKeluarga;
      case "Suami":
        return StatusHubungan.suami;
      case "Istri":
        return StatusHubungan.istri;
      case "Anak":
        return StatusHubungan.anak;
      case "Menantu":
        return StatusHubungan.menantu;
      case "Cucu":
        return StatusHubungan.cucu;
      case "Orang Tua":
        return StatusHubungan.orangTua;
      case "Mertua":
        return StatusHubungan.mertua;
      case "Famili Lain":
        return StatusHubungan.familiLain;
      default:
        return null;
    }
  }

  static Kewarganegaraan? _parseKwn(String? value) {
    switch (value) {
      case "WNI":
        return Kewarganegaraan.wni;
      case "WNA":
        return Kewarganegaraan.wna;
      default:
        return null;
    }
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;

    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');

    return "$y-$m-$d";
  }

  static String? _jkToString(JenisKelamin? value) {
    switch (value) {
      case JenisKelamin.lakiLaki:
        return "Laki-Laki";
      case JenisKelamin.perempuan:
        return "Perempuan";
      default:
        return null;
    }
  }

  static String? _agamaToString(Agama? value) {
    switch (value) {
      case Agama.islam:
        return "Islam";
      case Agama.kristen:
        return "Kristen";
      case Agama.katolik:
        return "Katolik";
      case Agama.hindu:
        return "Hindu";
      case Agama.buddha:
        return "Buddha";
      case Agama.konghucu:
        return "Konghucu";
      default:
        return null;
    }
  }

  static String? _statusKawinToString(StatusPerkawinan? value) {
    switch (value) {
      case StatusPerkawinan.belumKawin:
        return "Belum Kawin";
      case StatusPerkawinan.kawin:
        return "Kawin";
      case StatusPerkawinan.ceraiHidup:
        return "Cerai Hidup";
      case StatusPerkawinan.ceraiMati:
        return "Cerai Mati";
      default:
        return null;
    }
  }

  static String? _statusHubunganToString(StatusHubungan? value) {
    switch (value) {
      case StatusHubungan.kepalaKeluarga:
        return "Kepala Keluarga";
      case StatusHubungan.suami:
        return "Suami";
      case StatusHubungan.istri:
        return "Istri";
      case StatusHubungan.anak:
        return "Anak";
      case StatusHubungan.menantu:
        return "Menantu";
      case StatusHubungan.cucu:
        return "Cucu";
      case StatusHubungan.orangTua:
        return "Orang Tua";
      case StatusHubungan.mertua:
        return "Mertua";
      case StatusHubungan.familiLain:
        return "Famili Lain";
      default:
        return null;
    }
  }

  static String? _kwnToString(Kewarganegaraan? value) {
    switch (value) {
      case Kewarganegaraan.wni:
        return "WNI";
      case Kewarganegaraan.wna:
        return "WNA";
      default:
        return null;
    }
  }
}
