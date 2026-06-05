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

/// Parse Indonesian KTP — ONLY extract NIK (16 digits)
class KtpParserHelper {
  static KtpParseResult parse(OcrResult ocrResult) {
    final rawText = ocrResult.fullText;
    print('\n=== KTP PARSER ===');

    final nik = _findNik(rawText);
    final confidence = nik != null ? 1.0 : 0.0;

    print('NIK: ${nik ?? "NOT FOUND"}');
    print('Confidence: ${(confidence * 100).round()}%');
    print('=== END ===\n');

    return KtpParseResult(nik: nik, rawText: rawText, confidence: confidence);
  }

  /// Find NIK — label "NIK" followed by 16 digits, with validation
  static String? _findNik(String text) {
    // Fix OCR digit errors
    var corrected = text;
    corrected = corrected.replaceAllMapped(RegExp(r'(?<=\d)[Oo](?=\d)'), (m) => '0');
    corrected = corrected.replaceAllMapped(RegExp(r'(?<=\d)[Il|L](?=\d)'), (m) => '1');
    corrected = corrected.replaceAllMapped(RegExp(r'(?<=\d)[Ss](?=\d)'), (m) => '5');
    corrected = corrected.replaceAllMapped(RegExp(r'(?<=\d)[B](?=\d)'), (m) => '8');
    corrected = corrected.replaceAllMapped(RegExp(r'(?<=\d)[\?](?=\d)'), (m) => '7');

    // Strategy 1: Find "NIK" label → extract digits
    final labelMatch = RegExp(
      r'NIK\s*[:\-=]?\s*[\r\n]*\s*([0-9\s\-\.]{16,})',
      caseSensitive: false,
    ).firstMatch(corrected);

    if (labelMatch != null) {
      final digits = labelMatch.group(1)!.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 16) {
        final nik = digits.substring(0, 16);
        if (isValidNik(nik)) {
          print('Found NIK (after label, valid): $nik');
          return nik;
        } else {
          print('NIK after label failed validation: $nik');
        }
      }
    }

    // Strategy 2: Find any 16 digits — validate each
    final allDigits = corrected.replaceAll(RegExp(r'[^0-9]'), '');
    final matches = RegExp(r'\d{16}').allMatches(allDigits).toList();

    for (final m in matches) {
      final nik = m.group(0)!;
      if (isValidNik(nik)) {
        print('Found NIK (valid): $nik');
        return nik;
      }
    }

    // No valid NIK found
    print('No valid NIK found');
    return null;
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
