import 'ktp_line_classifier.dart';
import 'ocr_post_processor.dart';
import 'ocr_service.dart';

/// Result of parsing KK — No KK + all extracted fields.
class KkParseResult {
  final String? noKK;
  final String? namaKepalaKeluarga;
  final String? alamat;
  final String? rtRw;
  final String? kelDesa;
  final String? kecamatan;
  final String? kota;
  final String? kodePos;
  final String rawText;
  final double confidence;

  KkParseResult({
    this.noKK,
    this.namaKepalaKeluarga,
    this.alamat,
    this.rtRw,
    this.kelDesa,
    this.kecamatan,
    this.kota,
    this.kodePos,
    required this.rawText,
    this.confidence = 0.0,
  });

  bool get hasNoKK => noKK != null && noKK!.isNotEmpty;
  bool get hasNamaKepala => namaKepalaKeluarga != null && namaKepalaKeluarga!.isNotEmpty;
  bool get hasAnyData => hasNoKK || hasNamaKepala;
}

/// Parse Indonesian Kartu Keluarga — extract No KK (16 digits) + all fields.
///
/// Improvements over basic OCR:
/// - ROI cropping: only top 35% of KK is OCR'd (header region)
/// - Spatial-aware blocks: each line has bounding box from ML Kit
/// - Fuzzy label matching (handles "N0.", "NO .", "Kartu Keluarga" variants)
/// - KtpLineClassifier integration: extracts Alamat, Kode Pos, etc.
/// - Multi-factor confidence scoring
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
    print('\n=== KK PARSER (fuzzy + spatial) ===');

    final noKK = _extractNoKk(rawText, ocrResult.blocks);
    final classified = KtpLineClassifier.classifyKkLines(rawText);
    final fields = _extractFields(classified);
    final confidence = _calculateConfidence(ocrResult, noKK);

    print('No KK: ${noKK ?? "NOT FOUND"}');
    print('Nama Kepala: ${fields['namaKepalaKeluarga'] ?? "-"}');
    print('Confidence: ${(confidence * 100).round()}%');
    print('=== END ===\n');

    return KkParseResult(
      noKK: noKK,
      namaKepalaKeluarga: fields['namaKepalaKeluarga'],
      alamat: fields['alamat'],
      rtRw: fields['rtRw'],
      kelDesa: fields['kelDesa'],
      kecamatan: fields['kecamatan'],
      kota: fields['kota'],
      kodePos: fields['kodePos'],
      rawText: rawText,
      confidence: confidence,
    );
  }

  /// Extract field values from classified KK lines.
  static Map<String, String> _extractFields(List<ClassifiedKkLine> classified) {
    final result = <String, String>{};

    for (final line in classified) {
      if (line.value == null || line.value!.isEmpty) continue;

      switch (line.type) {
        case KkFieldType.namaKepalaKeluarga:
          result.putIfAbsent('namaKepalaKeluarga', () => line.value!);
          break;
        case KkFieldType.alamat:
          result.putIfAbsent('alamat', () => line.value!);
          break;
        case KkFieldType.rtRw:
          result.putIfAbsent('rtRw', () => line.value!);
          break;
        case KkFieldType.kelDesa:
          result.putIfAbsent('kelDesa', () => line.value!);
          break;
        case KkFieldType.kecamatan:
          result.putIfAbsent('kecamatan', () => line.value!);
          break;
        case KkFieldType.kota:
          result.putIfAbsent('kota', () => line.value!);
          break;
        case KkFieldType.kodePos:
          result.putIfAbsent('kodePos', () => line.value!);
          break;
        default:
          break;
      }
    }

    return result;
  }

  /// Extract No KK with fuzzy label matching + spatial-aware extraction.
  ///
  /// Strategy priority:
  /// 1. Fuzzy "No." label match (highest confidence — label present)
  /// 2. Block-based: find "No" block then check next blocks for 16 digits
  /// 3. "Kartu Keluarga" title → search nearby 16 digits
  /// 4. 16 digits near "No" text (within 200 chars)
  /// 5. First valid 16-digit sequence in full text (lowest confidence)
  static String? _extractNoKk(String text, List<OcrBlock> blocks) {
    // Apply OCR digit corrections
    var corrected = _applyDigitCorrections(text);

    // Strategy 1: Fuzzy "No." label match (highest confidence)
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

    // Strategy 2: Block-based — find "No" block, check next blocks for 16 digits
    if (blocks.isNotEmpty) {
      final noKK = _findNoKkFromBlocks(blocks);
      if (noKK != null) return noKK;
    }

    // Strategy 3: "Kartu Keluarga" title → search nearby 16 digits
    for (final titlePattern in _kkTitlePatterns) {
      final titleMatch = titlePattern.firstMatch(corrected);
      if (titleMatch != null) {
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

    // Strategy 4: Find 16 digits near "No" text (within 200 chars)
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

    // Strategy 5: Any 16-digit sequence — validate each
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

  /// Search blocks for No KK using spatial proximity to "No" label block.
  static String? _findNoKkFromBlocks(List<OcrBlock> blocks) {
    for (int i = 0; i < blocks.length; i++) {
      final blockText = blocks[i].text.trim();
      // Check if this block contains a "No" label
      if (RegExp(r'^[Nn][Oo0]\.?\s*[:\-=]?\s*$').hasMatch(blockText) ||
          RegExp(r'^[Nn][Oo0]\.?\s*[Kk][Kk]?\s*[:\-=]?\s*$').hasMatch(blockText)) {
        // Check this block and next 2 blocks for 16 digits
        for (int j = i; j < blocks.length && j <= i + 2; j++) {
          final corrected = _applyDigitCorrections(blocks[j].text);
          final digits = corrected.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.length >= 16) {
            final noKK = digits.substring(0, 16);
            if (isValidNoKK(noKK)) {
              print('Found No KK (block near label "${blocks[i].text}"): $noKK');
              return noKK;
            }
          }
        }
      }
    }
    return null;
  }

  /// Apply common OCR digit corrections.
  /// Corrects characters at start/end of digit sequences too (not just between digits).
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

    // Also fix at sequence boundaries: "O3217..." → "03217..."
    out = out.replaceAllMapped(RegExp(r'\b[Oo](?=\d{15})'), (m) => '0');
    out = out.replaceAllMapped(RegExp(r'\b[Il|L](?=\d{15})'), (m) => '1');
    // Fix trailing: "...3217O" → "...32170"
    out = out.replaceAllMapped(RegExp(r'(?<=\d{15})[Oo]\b'), (m) => '0');
    out = out.replaceAllMapped(RegExp(r'(?<=\d{15})[Il|L]\b'), (m) => '1');

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
