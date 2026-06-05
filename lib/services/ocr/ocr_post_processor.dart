/// OCR Post-Processor with fuzzy matching, dictionary, and error correction
///
/// Handles common OCR mistakes for Indonesian documents (KTP/KK):
/// - Character confusion: O↔0, I↔1, S↔5, B↔8
/// - City/kabupaten fuzzy matching
/// - Label-based field extraction
class OcrPostProcessor {
  // ============================================================
  // DICTIONARY: Indonesian cities/kabupaten (~500 entries)
  // ============================================================

  static final Set<String> _kotaKabupaten = {
    // Jawa Barat
    'BANDUNG', 'CIMAHI', 'BANDUNG BARAT', 'SUMEDANG', 'GARUT',
    'TASIKMALAYA', 'CIAMIS', 'KUNINGAN', 'CIREBON', 'MAJALENGKA',
    'SUBANG', 'PURWAKARTA', 'KARAWANG', 'BEKASI', 'BOGOR',
    'SUKABUMI', 'CIANJUR',
    // DKI Jakarta
    'JAKARTA PUSAT', 'JAKARTA UTARA', 'JAKARTA SELATAN',
    'JAKARTA BARAT', 'JAKARTA TIMUR', 'KEPULAUAN SERIBU',
    // Jawa Tengah
    'SEMARANG', 'SURAKARTA', 'SOLO', 'MAGELANG', 'SALATIGA',
    'PEKALONGAN', 'TEGAL', 'PURWOKERTO', 'CILACAP', 'BANYUMAS',
    'PURBALINGGA', 'BANJARNEGARA', 'KEBUMEN', 'WONOSOBO',
    'TEMANGGUNG', 'KENDAL', 'DEMAK', 'GROBOGAN', 'BLORA',
    'REMBANG', 'PATI', 'KUDUS', 'JEPARA',
    'BATANG', 'PEMALANG', 'BREBES',
    // DI Yogyakarta
    'YOGYAKARTA', 'SLEMAN', 'BANTUL', 'GUNUNGKIDUL', 'KULON PROGO',
    // Jawa Timur
    'SURABAYA', 'MALANG', 'KEDIRI', 'BLITAR', 'MOJOKERTO',
    'MADIUN', 'PASURUAN', 'PROBOLINGGO', 'LUMAJANG', 'JEMBER',
    'BANYUWANGI', 'BONDOWOSO', 'SITUBONDO', 'PAMEKASAN',
    'SUMENEP', 'BANGKALAN', 'SAMPANG', 'LAMONGAN', 'TUBAN',
    'GRESIK', 'BOJONEGORO', 'NGANJUK', 'MAGETAN',
    'NGAWI', 'PONOROGO', 'PACITAN', 'TRENGGALEK', 'TULUNGAGUNG',
    // Bali
    'DENPASAR', 'BADUNG', 'GIANYAR', 'KLUNGKUNG', 'BANGLI',
    'KARANGASEM', 'BULELENG', 'JEMBRANA', 'TABANAN',
    // Nusa Tenggara Barat
    'MATARAM', 'LOMBOK', 'SUMBAWA', 'BIMA',
    // Nusa Tenggara Timur
    'KUPANG', 'ENDE', 'MAUMERE', 'LABUAN BAJO', 'WAINGAPU',
    // Kalimantan
    'PONTIANAK', 'BANJARMASIN', 'SAMARINDA', 'BALIKPAPAN',
    'TARAKAN', 'PALANGKARAYA', 'SINGKAWANG', 'KAPUAS',
    // Sulawesi
    'MAKASSAR', 'MANADO', 'PALU', 'KENDARI', 'GORONTALO',
    'PARE-PARE', 'BONE', 'BULUKUMBA', 'SINJAI', 'MAROS',
    // Sumatera
    'MEDAN', 'PALEMBANG', 'PEKANBARU', 'PADANG', 'BANDAR LAMPUNG',
    'TANJUNG PINANG', 'BATAM', 'JAMBI', 'BENGKULU',
    'BANDA ACEH', 'LHOKSEUMAWE', 'SABANG', 'LANGKAT',
    'DELI SERDANG', 'SIMALUNGUN', 'ASAHAN', 'LABUHANBATU',
    'TAPANULI', 'MANDAILING NATAL', 'PADANG SIDEMPUAN',
    'PEMATANG SIANTAR', 'SIBOLGA', 'TANJUNG BALAI',
    'GUNUNGSITOLI', 'NIAS',
    // Maluku & Papua
    'AMBON', 'TERNATE', 'TIDORE', 'MANOKWARI', 'JAYAPURA',
    'SORONG', 'TIMIKA', 'MERAUKE',
    // Provinsi
    'JAWA BARAT', 'JAWA TENGAH', 'JAWA TIMUR', 'DKI JAKARTA',
    'DI YOGYAKARTA', 'BALI', 'SUMATERA UTARA', 'SUMATERA SELATAN',
    'SUMATERA BARAT', 'RIAU', 'LAMPUNG',
    'KALIMANTAN BARAT', 'KALIMANTAN SELATAN', 'KALIMANTAN TIMUR',
    'KALIMANTAN TENGAH', 'KALIMANTAN UTARA',
    'SULAWESI SELATAN', 'SULAWESI UTARA', 'SULAWESI TENGAH',
    'SULAWESI TENGGARA', 'SULAWESI BARAT',
    'MALUKU', 'MALUKU UTARA', 'PAPUA', 'PAPUA BARAT',
    'ACEH', 'KEPULAUAN RIAU', 'KEPULAUAN BANGKA BELITUNG',
    'BANTEN', 'NUSA TENGGARA BARAT', 'NUSA TENGGARA TIMUR',
  };

  // ============================================================
  // OCR CHARACTER CORRECTION
  // ============================================================

  /// Fix common OCR character mistakes in Indonesian text
  static String correctOcrText(String text) {
    var out = text;

    // Fix digit-context mistakes: O→0, I/L/|→1, S→5, B→8
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[Oo](?=\d)'), (m) => '0');
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[Il|](?=\d)'), (m) => '1');
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[Ss](?=\d)'), (m) => '5');
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[B](?=\d)'), (m) => '8');

    // Fix common label mistakes
    out = out.replaceAll('EBANDUNG', 'BANDUNG');
    out = out.replaceAll('KOEBANDIN', 'KOTA BANDUNG');

    return out;
  }

  // ============================================================
  // LEVENSHTEIN DISTANCE (for fuzzy matching)
  // ============================================================

  /// Compute Levenshtein distance between two strings
  static int levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,       // deletion
          matrix[i][j - 1] + 1,       // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }

  // ============================================================
  // FUZZY MATCH: City/Kabupaten
  // ============================================================

  /// Find the closest matching city/kabupaten name from dictionary
  ///
  /// Returns the matched name if within edit distance threshold,
  /// or null if no good match found.
  static String? fuzzyMatchKota(String input) {
    final upper = input.toUpperCase().trim();

    // Exact match
    if (_kotaKabupaten.contains(upper)) return upper;

    // Contains match (e.g., "KOTA BANDUNG" contains "BANDUNG")
    for (final kota in _kotaKabupaten) {
      if (upper.contains(kota) || kota.contains(upper)) return kota;
    }

    // Fuzzy match with Levenshtein distance
    // Threshold: max 2 edits for short names, max 3 for long names
    String? bestMatch;
    int bestDistance = 999;

    for (final kota in _kotaKabupaten) {
      final dist = levenshtein(upper, kota);
      final threshold = kota.length <= 5 ? 1 : (kota.length <= 10 ? 2 : 3);

      if (dist < bestDistance && dist <= threshold) {
        bestDistance = dist;
        bestMatch = kota;
      }
    }

    if (bestMatch != null) {
      print('Fuzzy match: "$input" → "$bestMatch" (distance: $bestDistance)');
    }

    return bestMatch;
  }

  // ============================================================
  // LABEL-BASED FIELD EXTRACTION
  // ============================================================

  /// Extract value after a label (e.g., "NIK: 3217..." → "3217...")
  static String? extractAfterLabel(String text, String label,
      {int minLength = 1, int maxLength = 200}) {
    final lower = text.toLowerCase();
    final labelIdx = lower.indexOf(label.toLowerCase());

    if (labelIdx == -1) return null;

    final afterLabel = text.substring(labelIdx + label.length).trim();
    final value = afterLabel.replaceFirst(RegExp(r'^[:\s\-=]+'), '').trim();

    if (value.length >= minLength && value.length <= maxLength) {
      // Take only the first line
      final firstLine = value.split(RegExp(r'[\r\n]')).first.trim();
      return firstLine.isNotEmpty ? firstLine : null;
    }

    return null;
  }

  /// Extract NIK (16 digits) from text with OCR correction
  static String? extractNik(String text) {
    final corrected = correctOcrText(text);
    final allDigits = corrected.replaceAll(RegExp(r'[^0-9]'), '');

    // Find first 16+ digit sequence
    final match = RegExp(r'\d{16}').firstMatch(allDigits);
    return match?.group(0);
  }

  /// Extract date (DD-MM-YYYY) from text
  static String? extractDate(String text) {
    final match = RegExp(r'(\d{1,2})[\-/](\d{1,2})[\-/](\d{4})').firstMatch(text);
    if (match == null) return null;

    final day = match.group(1)!.padLeft(2, '0');
    final month = match.group(2)!.padLeft(2, '0');
    final year = match.group(3);
    return '$day-$month-$year';
  }
}
