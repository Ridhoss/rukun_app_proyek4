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

/// Parse Indonesian Kartu Keluarga — ONLY extract No KK (16 digits)
class KkParserHelper {
  static KkParseResult parse(OcrResult ocrResult) {
    final rawText = ocrResult.fullText;
    print('\n=== KK PARSER ===');

    // Fix OCR digit errors
    var corrected = rawText;
    corrected = corrected.replaceAllMapped(RegExp(r'(?<=\d)[Oo](?=\d)'), (m) => '0');
    corrected = corrected.replaceAllMapped(RegExp(r'(?<=\d)[Il|L](?=\d)'), (m) => '1');
    corrected = corrected.replaceAllMapped(RegExp(r'(?<=\d)[Ss](?=\d)'), (m) => '5');
    corrected = corrected.replaceAllMapped(RegExp(r'(?<=\d)[B](?=\d)'), (m) => '8');
    corrected = corrected.replaceAllMapped(RegExp(r'(?<=\d)[\?](?=\d)'), (m) => '7');

    final noKK = _extractNoKk(corrected, rawText);
    final confidence = noKK != null ? 1.0 : 0.0;

    print('No KK: ${noKK ?? "NOT FOUND"}');
    print('Confidence: ${(confidence * 100).round()}%');
    print('=== END ===\n');

    return KkParseResult(noKK: noKK, rawText: rawText, confidence: confidence);
  }

  /// Extract No KK — find label, validate format
  static String? _extractNoKk(String corrected, String original) {
    // Strategy 1: "No." followed by 16 digits
    final noLabel = RegExp(
      r'No\.?\s*[:\-=]?\s*[\r\n]*\s*(\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4})',
      caseSensitive: false,
    ).firstMatch(corrected);

    if (noLabel != null) {
      final digits = noLabel.group(1)!.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 16) {
        final noKK = digits.substring(0, 16);
        if (isValidNoKK(noKK)) {
          print('Found No KK (after "No.", valid): $noKK');
          return noKK;
        }
      }
    }

    // Strategy 2: "Kartu Keluarga" title → 16 digits nearby
    final kkTitle = RegExp(
      r'kartu\s*keluarga|KARTU\s*KELUARGA',
      caseSensitive: false,
    ).firstMatch(original);

    if (kkTitle != null) {
      final searchCorrected = corrected.substring(
          kkTitle.start, (kkTitle.end + 500).clamp(0, corrected.length));
      final digitsOnly = searchCorrected.replaceAll(RegExp(r'[^0-9]'), '');
      final match = RegExp(r'\d{16}').firstMatch(digitsOnly);
      if (match != null && isValidNoKK(match.group(0)!)) {
        print('Found No KK (near "Kartu Keluarga", valid): ${match.group(0)}');
        return match.group(0);
      }
    }

    // Strategy 3: Any 16 digits — validate
    final allDigits = corrected.replaceAll(RegExp(r'[^0-9]'), '');
    final matches = RegExp(r'\d{16}').allMatches(allDigits).toList();

    for (final m in matches) {
      final noKK = m.group(0)!;
      if (isValidNoKK(noKK)) {
        print('Found No KK (global, valid): $noKK');
        return noKK;
      }
    }

    print('No valid No KK found');
    return null;
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
