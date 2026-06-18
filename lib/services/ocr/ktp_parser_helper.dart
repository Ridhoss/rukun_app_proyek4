import 'ocr_post_processor.dart';
import 'ocr_service.dart';

/// Result of parsing KTP - only NIK
class KtpParseResult {
  final String? nik;
  final String rawText;
  final double confidence;

  KtpParseResult({
    this.nik,
    required this.rawText,
    this.confidence = 0.0,
  });

  bool get hasNik => nik != null && nik!.isNotEmpty;
  bool get hasAnyData => hasNik;
}

/// Parse Indonesian KTP — extract NIK (16 digits) with fuzzy label matching.
///
/// Adapted from PCD-B4's keyword detection pattern:
/// - Fuzzy NIK label matching (handles OCR misreads like "NlK", "N1K", "NI K")
/// - Multi-factor confidence scoring
/// - Multi-strategy digit extraction
class KtpParserHelper {
  // Fuzzy patterns for NIK label — handles common OCR misreads
  static final List<RegExp> _nikLabelPatterns = [
    // Exact: "NIK" followed by digits
    RegExp(r'NIK\s*[:\-=]?\s*[\r\n]*\s*([0-9\s\-\.]{16,})', caseSensitive: false),
    // Fuzzy: "NlK", "N1K", "NIK" (I→1, l→1 confusion)
    RegExp(r'[Nn][Iil1][Kk]\s*[:\-=]?\s*[\r\n]*\s*([0-9\s\-\.]{16,})'),
    // Very fuzzy: "N I K", "N-I-K", with optional separators
    RegExp(r'[Nn]\s*[Iil1]\s*[Kk]\s*[:\-=]?\s*[\r\n]*\s*([0-9\s\-\.]{16,})'),
    // Loose: "NI" or "Nl" followed by K and digits (handles "NI K", "Nl K")
    RegExp(r'[Nn][Iil1]\s*[Kk]\s*[:\-=]?\s*[\r\n]*\s*([0-9\s\-\.]{16,})'),
    // After "PENDUDUK" or "KTP" header — NIK usually appears next
    RegExp(r'(?:penduduk|ktp|tanda)\s*[.\s]*\s*([0-9\s\-\.]{16,})',
        caseSensitive: false),
  ];

  // Skip patterns — lines that are NOT NIK (headers, labels, etc.)
  static final List<RegExp> _skipPatterns = [
    RegExp(r'republik\s*indonesia', caseSensitive: false),
    RegExp(r'kartu\s*tanda\s*penduduk', caseSensitive: false),
    RegExp(r'provinsi|kabupaten|kota', caseSensitive: false),
    RegExp(r'alamat|rt\s*/\s*rw|kel\s*/\s*desa', caseSensitive: false),
    RegExp(r'kecamatan|agama|pekerjaan', caseSensitive: false),
    RegExp(r'status\s*perkawinan|kewarganegaraan', caseSensitive: false),
    RegExp(r'berlaku\s*hingga|gol\.\s*darah', caseSensitive: false),
    RegExp(r'nama|tempat[,\s/\-]*tgl\s*lahir|jenis\s*kelamin', caseSensitive: false),
  ];

  static KtpParseResult parse(OcrResult ocrResult) {
    final rawText = ocrResult.fullText;
    print('\n=== KTP PARSER (fuzzy) ===');

    final nik = _findNik(rawText);
    final confidence = _calculateConfidence(ocrResult, nik);

    print('NIK: ${nik ?? "NOT FOUND"}');
    print('Confidence: ${(confidence * 100).round()}%');
    print('=== END ===\n');

    return KtpParseResult(nik: nik, rawText: rawText, confidence: confidence);
  }

  /// Find NIK with fuzzy label matching + multi-strategy extraction.
  static String? _findNik(String text) {
    // Apply OCR digit corrections
    var corrected = _applyDigitCorrections(text);

    // Strategy 1: Fuzzy NIK label match
    for (final pattern in _nikLabelPatterns) {
      final match = pattern.firstMatch(corrected);
      if (match != null) {
        final digits = match.group(1)!.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length >= 16) {
          final nik = digits.substring(0, 16);
          if (isValidNik(nik)) {
            print('Found NIK (fuzzy label, valid): $nik');
            return nik;
          }
        }
      }
    }

    // Strategy 2: Find 16 digits near NIK-like text (within 200 chars)
    final nikRegion = RegExp(r'[Nn][Iil1][Kk].{0,200}', caseSensitive: false)
        .firstMatch(corrected);
    if (nikRegion != null) {
      final regionDigits =
          nikRegion.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      final match = RegExp(r'\d{16}').firstMatch(regionDigits);
      if (match != null && isValidNik(match.group(0)!)) {
        print('Found NIK (near label region, valid): ${match.group(0)}');
        return match.group(0);
      }
    }

    // Strategy 3: Any 16-digit sequence — validate each
    final allDigits = corrected.replaceAll(RegExp(r'[^0-9]'), '');
    final matches = RegExp(r'\d{16}').allMatches(allDigits).toList();

    for (final m in matches) {
      final nik = m.group(0)!;
      if (isValidNik(nik)) {
        print('Found NIK (global scan, valid): $nik');
        return nik;
      }
    }

    print('No valid NIK found');
    return null;
  }

  /// Apply common OCR digit corrections.
  /// Only corrects characters between digits (context-aware).
  static String _applyDigitCorrections(String text) {
    var out = text;
    // O/o → 0 between digits
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[Oo](?=\d)'), (m) => '0');
    // I/l/|/L → 1 between digits
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[Il|L](?=\d)'), (m) => '1');
    // S/s → 5 between digits
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[Ss](?=\d)'), (m) => '5');
    // B → 8 between digits
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[B](?=\d)'), (m) => '8');
    // ? → 7 between digits
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[\?](?=\d)'), (m) => '7');
    return out;
  }

  /// Multi-factor confidence scoring (adapted from PCD-B4).
  ///
  /// Factors:
  /// - NIK found (40%)
  /// - Text quality — clean character ratio (20%)
  /// - KTP labels detected (20%)
  /// - NIK validation passes (20%)
  static double _calculateConfidence(OcrResult ocrResult, String? nik) {
    if (ocrResult.fullText.isEmpty) return 0.0;

    double score = 0;

    // Factor 1: NIK found (40%)
    if (nik != null) score += 0.4;

    // Factor 2: Text quality — ratio of clean characters (20%)
    final allText = ocrResult.fullText;
    final cleanChars =
        RegExp(r'[a-zA-Z0-9.,\s:/\-]').allMatches(allText).length;
    final cleanRatio = allText.isNotEmpty ? cleanChars / allText.length : 0.0;
    score += cleanRatio * 0.2;

    // Factor 3: KTP labels detected (20%)
    // Check if common KTP labels are present in the text
    final labels = [
      RegExp(r'NIK', caseSensitive: false),
      RegExp(r'Nama', caseSensitive: false),
      RegExp(r'Provinsi|Kabupaten|Kota', caseSensitive: false),
    ];
    int labelsFound = 0;
    for (final label in labels) {
      if (label.hasMatch(allText)) labelsFound++;
    }
    score += (labelsFound / labels.length) * 0.2;

    // Factor 4: NIK validation passes (20%)
    if (nik != null && isValidNik(nik)) score += 0.2;

    return score.clamp(0.0, 1.0);
  }

  /// Validate NIK structure (lenient)
  ///
  /// Only checks:
  /// - 16 digits
  /// - Province code 11-99
  /// - Not all zeros / not all same digit
  static bool isValidNik(String nik) {
    if (nik.length != 16) return false;
    if (!RegExp(r'^\d{16}$').hasMatch(nik)) return false;

    final pp = int.tryParse(nik.substring(0, 2)) ?? 0;

    // Province code: must be 11-99
    if (pp < 11 || pp > 99) return false;

    // All zeros = invalid
    if (nik == '0000000000000000') return false;

    // All same digit = invalid (e.g., 1111111111111111)
    if (RegExp(r'^(\d)\1{15}$').hasMatch(nik)) return false;

    return true;
  }
}
