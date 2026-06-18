import 'ocr_post_processor.dart';

/// KTP field types — each line of OCR text is classified into one of these.
///
/// Adapted from PCD-B4's `_LineType` enum pattern which classifies receipt lines
/// into types (keyword, skip, qtyPrice, fullItem, etc). Here adapted for KTP/KK fields.
enum KtpFieldType {
  nik,
  nama,
  tempatTglLahir,
  jenisKelamin,
  golonganDarah,
  alamat,
  rtRw,
  kelDesa,
  kecamatan,
  agama,
  statusPerkawinan,
  pekerjaan,
  kewarganegaraan,
  berlakuHingga,
  headerSkip,
  separatorSkip,
  unknown,
}

/// KK field types
enum KkFieldType {
  noKK,
  namaKepalaKeluarga,
  alamat,
  rtRw,
  kelDesa,
  kecamatan,
  kota,
  kodePos,
  anggotaKeluarga,
  headerSkip,
  separatorSkip,
  unknown,
}

/// A classified KTP line with its field type and extracted value.
class ClassifiedKtpLine {
  final String rawText;
  final KtpFieldType type;
  final String? value;

  ClassifiedKtpLine(this.rawText, this.type, {this.value});
}

/// A classified KK line with its field type and extracted value.
class ClassifiedKkLine {
  final String rawText;
  final KkFieldType type;
  final String? value;

  ClassifiedKkLine(this.rawText, this.type, {this.value});
}

/// Line classifier for KTP/KK OCR text.
///
/// Adapted from PCD-B4's `_classifyLine()` and `_isSkipLine()` pattern.
/// Each line is classified by its label (with fuzzy matching) into a field type,
/// then the value after the label is extracted.
class KtpLineClassifier {
  // ============================================================
  // KTP LINE CLASSIFICATION
  // ============================================================

  /// Classify all lines in KTP OCR text.
  ///
  /// Returns a list of classified lines with field types and extracted values.
  /// Lines that are headers/separators are marked as skip.
  static List<ClassifiedKtpLine> classifyKtpLines(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final classified = <ClassifiedKtpLine>[];

    for (final line in lines) {
      classified.add(_classifyKtpLine(line));
    }

    return classified;
  }

  /// Classify a single KTP line.
  ///
  /// Checks labels in priority order (specific → general) to avoid misclassification.
  /// For example, "NIK" is checked before generic number patterns.
  static ClassifiedKtpLine _classifyKtpLine(String line) {
    final lower = line.toLowerCase().trim();

    // ── Skip patterns (headers, separators) ──────────────────────────────
    if (_isKtpHeaderSkip(lower)) {
      return ClassifiedKtpLine(line, KtpFieldType.headerSkip);
    }
    if (_isSeparator(line)) {
      return ClassifiedKtpLine(line, KtpFieldType.separatorSkip);
    }

    // ── Field label matching (fuzzy) ─────────────────────────────────────

    // NIK (16 digits after label)
    if (_matchesLabel(lower, ['nik'])) {
      final value = _extractAfterLabel(line, 'nik');
      return ClassifiedKtpLine(line, KtpFieldType.nik, value: value);
    }

    // Nama
    if (_matchesLabel(lower, ['nama', 'name'])) {
      final value = _extractAfterLabel(line, 'nama') ??
          _extractAfterLabel(line, 'name');
      return ClassifiedKtpLine(line, KtpFieldType.nama, value: value);
    }

    // Tempat/Tgl Lahir
    if (_matchesLabel(lower, [
      'tempat',
      'tgl lahir',
      'tanggal lahir',
      'tempat/tgl',
      'tempat, tgl',
    ])) {
      final value = _extractAfterLabelMulti(line, [
        'tempat/tgl lahir',
        'tempat, tgl lahir',
        'tempat tgl lahir',
        'tgl lahir',
        'tanggal lahir',
        'tempat',
      ]);
      return ClassifiedKtpLine(line, KtpFieldType.tempatTglLahir, value: value);
    }

    // Jenis Kelamin
    if (_matchesLabel(lower, ['jenis kelamin', 'kelamin', 'gender'])) {
      final value = _extractAfterLabelMulti(line, [
        'jenis kelamin',
        'kelamin',
        'gender',
      ]);
      return ClassifiedKtpLine(line, KtpFieldType.jenisKelamin, value: value);
    }

    // Golongan Darah
    if (_matchesLabel(lower, ['gol', 'darah', 'blood'])) {
      final value = _extractAfterLabelMulti(line, [
        'gol. darah',
        'gol darah',
        'darah',
      ]);
      return ClassifiedKtpLine(line, KtpFieldType.golonganDarah, value: value);
    }

    // Alamat
    if (_matchesLabel(lower, ['alamat', 'address'])) {
      final value = _extractAfterLabelMulti(line, ['alamat', 'address']);
      return ClassifiedKtpLine(line, KtpFieldType.alamat, value: value);
    }

    // RT/RW
    if (_matchesLabel(lower, ['rt/rw', 'rt rw', 'rt', 'rw'])) {
      final value = _extractAfterLabelMulti(line, ['rt/rw', 'rt rw', 'rt']);
      return ClassifiedKtpLine(line, KtpFieldType.rtRw, value: value);
    }

    // Kel/Desa
    if (_matchesLabel(lower, ['kel/desa', 'kel desa', 'kelurahan', 'desa'])) {
      final value = _extractAfterLabelMulti(line, [
        'kel/desa',
        'kel desa',
        'kelurahan',
        'desa',
      ]);
      return ClassifiedKtpLine(line, KtpFieldType.kelDesa, value: value);
    }

    // Kecamatan
    if (_matchesLabel(lower, ['kecamatan', 'kec'])) {
      final value = _extractAfterLabelMulti(line, ['kecamatan', 'kec']);
      return ClassifiedKtpLine(line, KtpFieldType.kecamatan, value: value);
    }

    // Agama
    if (_matchesLabel(lower, ['agama', 'religion'])) {
      final value = _extractAfterLabelMulti(line, ['agama', 'religion']);
      return ClassifiedKtpLine(line, KtpFieldType.agama, value: value);
    }

    // Status Perkawinan
    if (_matchesLabel(lower, ['status perkawinan', 'perkawinan', 'status'])) {
      final value = _extractAfterLabelMulti(line, [
        'status perkawinan',
        'perkawinan',
        'status',
      ]);
      return ClassifiedKtpLine(line, KtpFieldType.statusPerkawinan, value: value);
    }

    // Pekerjaan
    if (_matchesLabel(lower, ['pekerjaan', 'occupation', 'kerja'])) {
      final value = _extractAfterLabelMulti(line, [
        'pekerjaan',
        'occupation',
        'kerja',
      ]);
      return ClassifiedKtpLine(line, KtpFieldType.pekerjaan, value: value);
    }

    // Kewarganegaraan
    if (_matchesLabel(lower, ['kewarganegaraan', 'warga', 'citizenship'])) {
      final value = _extractAfterLabelMulti(line, [
        'kewarganegaraan',
        'warga',
        'citizenship',
      ]);
      return ClassifiedKtpLine(line, KtpFieldType.kewarganegaraan, value: value);
    }

    // Berlaku Hingga
    if (_matchesLabel(lower, ['berlaku hingga', 'berlaku', 'valid until'])) {
      final value = _extractAfterLabelMulti(line, [
        'berlaku hingga',
        'berlaku',
        'valid until',
      ]);
      return ClassifiedKtpLine(line, KtpFieldType.berlakuHingga, value: value);
    }

    // ── Unknown ──────────────────────────────────────────────────────────
    return ClassifiedKtpLine(line, KtpFieldType.unknown);
  }

  // ============================================================
  // KK LINE CLASSIFICATION
  // ============================================================

  /// Classify all lines in KK OCR text.
  static List<ClassifiedKkLine> classifyKkLines(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return lines.map(_classifyKkLine).toList();
  }

  /// Classify a single KK line.
  static ClassifiedKkLine _classifyKkLine(String line) {
    final lower = line.toLowerCase().trim();

    // Skip patterns
    if (_isKkHeaderSkip(lower)) {
      return ClassifiedKkLine(line, KkFieldType.headerSkip);
    }
    if (_isSeparator(line)) {
      return ClassifiedKkLine(line, KkFieldType.separatorSkip);
    }

    // No KK (16 digits after "No." label)
    if (_matchesLabel(lower, ['no.', 'no kk', 'no. kk', 'nomor'])) {
      final value = _extractAfterLabelMulti(line, ['no. kk', 'no kk', 'no.', 'nomor']);
      return ClassifiedKkLine(line, KkFieldType.noKK, value: value);
    }

    // Nama Kepala Keluarga — avoid generic 'nama' to prevent false matches
    if (_matchesLabel(lower, ['kepala keluarga', 'nama kepala keluarga', 'nama kepala'])) {
      final value = _extractAfterLabelMulti(line, [
        'nama kepala keluarga',
        'kepala keluarga',
        'nama kepala',
      ]);
      return ClassifiedKkLine(line, KkFieldType.namaKepalaKeluarga, value: value);
    }

    // Alamat
    if (_matchesLabel(lower, ['alamat', 'address'])) {
      final value = _extractAfterLabelMulti(line, ['alamat', 'address']);
      return ClassifiedKkLine(line, KkFieldType.alamat, value: value);
    }

    // RT/RW
    if (_matchesLabel(lower, ['rt/rw', 'rt rw', 'rt'])) {
      final value = _extractAfterLabelMulti(line, ['rt/rw', 'rt rw', 'rt']);
      return ClassifiedKkLine(line, KkFieldType.rtRw, value: value);
    }

    // Kel/Desa — KK format uses "Desa/Kelurahan"
    if (_matchesLabel(lower, ['desa/kelurahan', 'kel/desa', 'kel desa', 'kelurahan', 'desa'])) {
      final value = _extractAfterLabelMulti(line, [
        'desa/kelurahan',
        'kel/desa',
        'kel desa',
        'kelurahan',
        'desa',
      ]);
      return ClassifiedKkLine(line, KkFieldType.kelDesa, value: value);
    }

    // Kecamatan
    if (_matchesLabel(lower, ['kecamatan', 'kec'])) {
      final value = _extractAfterLabelMulti(line, ['kecamatan', 'kec']);
      return ClassifiedKkLine(line, KkFieldType.kecamatan, value: value);
    }

    // Kota/Kabupaten — KK format uses "Kabupaten/Kota"
    if (_matchesLabel(lower, ['kabupaten/kota', 'kab/kota', 'kota', 'kabupaten', 'kab'])) {
      final value = _extractAfterLabelMulti(line, [
        'kabupaten/kota',
        'kab/kota',
        'kota',
        'kabupaten',
        'kab',
      ]);
      // Try fuzzy match city name
      final matched = OcrPostProcessor.fuzzyMatchKota(value ?? '');
      return ClassifiedKkLine(line, KkFieldType.kota, value: matched ?? value);
    }

    // Kode Pos
    if (_matchesLabel(lower, ['kode pos', 'pos'])) {
      final value = _extractAfterLabelMulti(line, ['kode pos', 'pos']);
      return ClassifiedKkLine(line, KkFieldType.kodePos, value: value);
    }

    return ClassifiedKkLine(line, KkFieldType.unknown);
  }

  // ============================================================
  // HELPER METHODS (shared between KTP and KK)
  // ============================================================

  /// Check if line matches any of the given labels (fuzzy).
  ///
  /// Uses compact (spaces removed) comparison for fuzzy matching,
  /// same approach as PCD-B4's `_detectKeyword()`.
  static bool _matchesLabel(String lower, List<String> labels) {
    final compact = lower.replaceAll(' ', '');
    for (final label in labels) {
      final labelCompact = label.replaceAll(' ', '');
      if (compact.contains(labelCompact)) return true;
      // Also check with spaces preserved
      if (lower.contains(label)) return true;
    }
    return false;
  }

  /// Extract value after a label in the line.
  static String? _extractAfterLabel(String line, String label) {
    final lower = line.toLowerCase();
    final idx = lower.indexOf(label.toLowerCase());
    if (idx == -1) return null;

    final after = line.substring(idx + label.length).trim();
    final value = after.replaceFirst(RegExp(r'^[:\s\-=]+'), '').trim();
    return value.isNotEmpty ? value : null;
  }

  /// Extract value after trying multiple label variants.
  static String? _extractAfterLabelMulti(String line, List<String> labels) {
    // Try longest labels first (more specific matches first)
    final sorted = List<String>.from(labels)
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final label in sorted) {
      final value = _extractAfterLabel(line, label);
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Check if line is a KTP header to skip.
  static bool _isKtpHeaderSkip(String lower) {
    final patterns = [
      RegExp(r'republik\s*indonesia'),
      RegExp(r'kartu\s*tanda\s*penduduk'),
      RegExp(r'provinsi|kabupaten|kota(?!\s*[:\-=])'),
      RegExp(r'nik\s*$', caseSensitive: false), // Just "NIK" label alone
    ];
    return patterns.any((p) => p.hasMatch(lower));
  }

  /// Check if line is a KK header to skip.
  static bool _isKkHeaderSkip(String lower) {
    final patterns = [
      RegExp(r'republik\s*indonesia'),
      RegExp(r'kartu\s*keluarga\s*$'),
      RegExp(r'provinsi|kabupaten(?!\s*[:\-=])'),
    ];
    return patterns.any((p) => p.hasMatch(lower));
  }

  /// Check if line is just a separator (dashes, equals, dots).
  static bool _isSeparator(String line) {
    return RegExp(r'^[\-=\.=_\s]{3,}$').hasMatch(line);
  }
}
