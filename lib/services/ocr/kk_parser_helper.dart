import 'ocr_post_processor.dart';
import 'ocr_service.dart';

/// Result of parsing KK - only No KK
class KkParseResult {
  final String? noKK;
  final String rawText;
  final double confidence;

  KkParseResult({
    this.noKK,
    required this.rawText,
    this.confidence = 0.0,
  });

  bool get hasNoKK => noKK != null && noKK!.isNotEmpty;
  bool get hasAnyData => hasNoKK;
}

/// Parse Indonesian Kartu Keluarga — extract No KK (16 digits) with fuzzy label matching.
///
/// Adapted from PCD-B4's keyword detection pattern:
/// - Fuzzy label matching (handles "N0.", "NO .", "Kartu Keluarga" variants)
/// - Multi-factor confidence scoring
/// - Multi-strategy digit extraction
class KkParserHelper {
  // Fuzzy patterns for "No." label — handles common OCR misreads
  static final List<RegExp> _noLabelPatterns = [
    // Exact: "No." or "NO." followed by 16 digits (grouped or continuous)
    RegExp(
      r'No\.?\s*[:\-=]?\s*[\r\n]*\s*(\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4})',
      caseSensitive: false,
    ),
    // Fuzzy: "N0." (O→0), "NO ." (extra space), "No:" (no dot)
    RegExp(
      r'[Nn][Oo0]\.?\s*[:\-=]?\s*[\r\n]*\s*(\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4})',
    ),
    // Very fuzzy: "N o ." with spaces between characters
    RegExp(
      r'[Nn]\s*[Oo0]\s*\.?\s*[:\-=]?\s*[\r\n]*\s*(\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4})',
    ),
    // "No KK" or "NO. KK" pattern
    RegExp(
      r'[Nn][Oo0]\.?\s*[Kk][Kk]\s*[:\-=]?\s*[\r\n]*\s*(\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4})',
    ),
  ];

  // Fuzzy patterns for "Kartu Keluarga" title
  static final List<RegExp> _kkTitlePatterns = [
    RegExp(r'kartu\s*keluarga', caseSensitive: false),
    RegExp(r'KARTU\s*KELUARGA'),
    // Fuzzy: "Kartu Keluarga" with OCR errors
    RegExp(r'[Kk]artu\s*[Kk]eluarga'),
    // Very fuzzy: "KARTU KELUARGA" with possible misreads
    RegExp(r'[Kk][Aa4]rtu\s*[Kk][Ee3]luarga'),
  ];

  static KkParseResult parse(OcrResult ocrResult) {
    final rawText = ocrResult.fullText;
    print('\n=== KK PARSER (fuzzy) ===');

    final noKK = _extractNoKk(rawText);
    final confidence = _calculateConfidence(ocrResult, noKK);

    print('No KK: ${noKK ?? "NOT FOUND"}');
    print('Confidence: ${(confidence * 100).round()}%');
    print('=== END ===\n');

    return KkParseResult(noKK: noKK, rawText: rawText, confidence: confidence);
  }

  /// Extract No KK with fuzzy label matching + multi-strategy extraction.
  static String? _extractNoKk(String text) {
    // Apply OCR digit corrections
    var corrected = _applyDigitCorrections(text);

    // Strategy 1: Fuzzy "No." label match
    for (final pattern in _noLabelPatterns) {
      final match = pattern.firstMatch(corrected);
      if (match != null) {
        final digits = match.group(1)!.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length >= 16) {
          final noKK = digits.substring(0, 16);
          if (isValidNoKK(noKK)) {
            print('Found No KK (fuzzy "No." label, valid): $noKK');
            return noKK;
          }
        }
      }
    }

    // Strategy 2: "Kartu Keluarga" title → search nearby 16 digits
    for (final titlePattern in _kkTitlePatterns) {
      final titleMatch = titlePattern.firstMatch(corrected);
      if (titleMatch != null) {
        // Search in a window after the title (up to 500 chars)
        final searchEnd =
            (titleMatch.end + 500).clamp(0, corrected.length);
        final searchRegion = corrected.substring(titleMatch.start, searchEnd);
        final digitsOnly =
            searchRegion.replaceAll(RegExp(r'[^0-9]'), '');
        final match = RegExp(r'\d{16}').firstMatch(digitsOnly);
        if (match != null && isValidNoKK(match.group(0)!)) {
          print('Found No KK (near "Kartu Keluarga", valid): ${match.group(0)}');
          return match.group(0);
        }
      }
    }

    // Strategy 3: Find 16 digits near "No" text (within 200 chars)
    final noRegion = RegExp(r'[Nn][Oo0].{0,200}', caseSensitive: false)
        .firstMatch(corrected);
    if (noRegion != null) {
      final regionDigits =
          noRegion.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      final match = RegExp(r'\d{16}').firstMatch(regionDigits);
      if (match != null && isValidNoKK(match.group(0)!)) {
        print('Found No KK (near "No" region, valid): ${match.group(0)}');
        return match.group(0);
      }
    }

    // Strategy 4: Any 16-digit sequence — validate each
    final allDigits = corrected.replaceAll(RegExp(r'[^0-9]'), '');
    final matches = RegExp(r'\d{16}').allMatches(allDigits).toList();

    for (final m in matches) {
      final noKK = m.group(0)!;
      if (isValidNoKK(noKK)) {
        print('Found No KK (global scan, valid): $noKK');
        return noKK;
      }
    }

    print('No valid No KK found');
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
  /// - No KK found (40%)
  /// - Text quality — clean character ratio (20%)
  /// - KK labels detected (20%)
  /// - No KK validation passes (20%)
  static double _calculateConfidence(OcrResult ocrResult, String? noKK) {
    if (ocrResult.fullText.isEmpty) return 0.0;

    double score = 0;

    // Factor 1: No KK found (40%)
    if (noKK != null) score += 0.4;

    // Factor 2: Text quality — ratio of clean characters (20%)
    final allText = ocrResult.fullText;
    final cleanChars =
        RegExp(r'[a-zA-Z0-9.,\s:/\-]').allMatches(allText).length;
    final cleanRatio = allText.isNotEmpty ? cleanChars / allText.length : 0.0;
    score += cleanRatio * 0.2;

    // Factor 3: KK labels detected (20%)
    final labels = [
      RegExp(r'Kartu\s*Keluarga', caseSensitive: false),
      RegExp(r'[Nn][Oo]\.', caseSensitive: false),
      RegExp(r'Kepala\s*Keluarga', caseSensitive: false),
    ];
    int labelsFound = 0;
    for (final label in labels) {
      if (label.hasMatch(allText)) labelsFound++;
    }
    score += (labelsFound / labels.length) * 0.2;

    // Factor 4: No KK validation passes (20%)
    if (noKK != null && isValidNoKK(noKK)) score += 0.2;

    return score.clamp(0.0, 1.0);
  }

  /// Validate No KK structure (lenient)
  ///
  /// Only checks:
  /// - 16 digits
  /// - Province code 11-99
  /// - Not all zeros / not all same digit
  static bool isValidNoKK(String noKK) {
    if (noKK.length != 16) return false;
    if (!RegExp(r'^\d{16}$').hasMatch(noKK)) return false;

    final pp = int.tryParse(noKK.substring(0, 2)) ?? 0;

    // Province code: must be 11-99
    if (pp < 11 || pp > 99) return false;

    // All zeros = invalid
    if (noKK == '0000000000000000') return false;

    // All same digit = invalid
    if (RegExp(r'^(\d)\1{15}$').hasMatch(noKK)) return false;

    return true;
  }
}
