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
  bool get hasNamaKepala =>
      namaKepalaKeluarga != null && namaKepalaKeluarga!.isNotEmpty;
  bool get hasAnyData => hasNoKK || hasNamaKepala;
}

// ================================================================
// INTERNAL HELPERS
// ================================================================

/// Label definition: field name + regex patterns to locate the label in text.
class _FieldDef {
  final String fieldName;
  final List<RegExp> patterns;
  const _FieldDef(this.fieldName, this.patterns);
}

/// Position of a found label in the OCR text.
class _LabelPos {
  final String fieldName;
  final int start;
  final int labelEnd;
  const _LabelPos(this.fieldName, this.start, this.labelEnd);
}

/// Parse Indonesian Kartu Keluarga (KK) — extract No KK + header fields.
///
/// v2: **Label-position tokenization** approach.
///
/// Instead of classifying lines one-by-one (which fails when ML Kit splits
/// labels and values into different blocks), this parser:
///
/// 1. Finds ALL known label positions in the full OCR text
/// 2. Sorts them by position
/// 3. Extracts the value between each label and the next label
/// 4. Cleans extracted values per field type (format-aware)
///
/// This handles all ML Kit output variations:
/// - Labels and values on same line with ":" separator
/// - Labels and values on different blocks/lines
/// - Two-column KK layout (left + right fields interleaved)
/// - Missing ":" separators
/// - Labels split across lines (e.g., "Nama Kepala\nKeluarga")
class KkParserHelper {
  // ================================================================
  // FIELD DEFINITIONS
  // ================================================================

  /// Known KK header field labels and their regex patterns.
  /// Each pattern should match the COMPLETE label text to avoid partial
  /// matches (e.g., extracting "Keluarga" from "Nama Kepala Keluarga").
  ///
  /// Patterns are tried in order; first match per field wins.
  static final List<_FieldDef> _fieldDefs = [
    _FieldDef('namaKepalaKeluarga', [
      // Full label with possible newlines between words
      RegExp(r'[Nn]ama\s+[Kk]epala\s+[Kk]eluarga'),
      // Fuzzy: "Nana Kepala Keluarga" (m→n OCR error)
      RegExp(r'[Nn]a[mn]a\s+[Kk]epala\s+[Kk]eluarga'),
      // Without "Nama" prefix (some KK variants)
      // Negative lookbehind excludes "KARTU KELUARGA"
      RegExp(r'(?<![Aa4]rtu\s)(?<![Aa4]rtu)[Kk]epala\s+[Kk]eluarga'),
    ]),
    _FieldDef('alamat', [
      RegExp(r'[Aa]lamat'),
    ]),
    _FieldDef('rtRw', [
      RegExp(r'RT\s*/?\s*RW', caseSensitive: false),
    ]),
    _FieldDef('kodePos', [
      RegExp(r'[Kk]ode\s*[Pp]os'),
    ]),
    _FieldDef('kelDesa', [
      // KK format: "Desa/Kelurahan"
      RegExp(r'[Dd]esa\s*/?\s*[Kk]elurahan'),
      // Alternative: "Kel/Desa"
      RegExp(r'[Kk]el(?:urahan)?\s*/?\s*[Dd]esa'),
    ]),
    _FieldDef('kecamatan', [
      RegExp(r'[Kk]ecamat[ae]n'),
    ]),
    _FieldDef('kota', [
      // KK format: "Kabupaten/Kota"
      RegExp(r'[Kk]abupat[ae]n\s*/?\s*[Kk]ota'),
      RegExp(r'[Kk]ab\s*/?\s*[Kk]ota'),
    ]),
    _FieldDef('provinsi', [
      RegExp(r'[Pp]rov[il]ns[il]'),
    ]),
  ];

  /// Regex patterns that indicate the start of the data table.
  /// Used as value terminators to prevent extracting table data.
  static final List<RegExp> _tableStartMarkers = [
    RegExp(r'Nama\s+Lengkap', caseSensitive: false),
    RegExp(r'Jenis\s*Kelamin', caseSensitive: false),
    RegExp(r'Tempat\s*Lahir', caseSensitive: false),
  ];

  // ================================================================
  // No KK PATTERNS
  // ================================================================

  /// Fuzzy patterns for "No." label — handles common OCR misreads.
  /// Each pattern captures 16 digits (possibly separated by spaces/dots/dashes).
  static final List<RegExp> _noLabelPatterns = [
    // Exact: "No." or "NO." followed by 16 digits
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
    // Digits with single-character spacing: "3 6 7 4 0 6 ..."
    RegExp(
      r'[Nn][Oo0]\.?\s*[:\-=]?\s*[\r\n]*\s*(\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d[\s\.\-]?\d)',
      caseSensitive: false,
    ),
  ];

  /// Fuzzy patterns for "Kartu Keluarga" title (used for No KK proximity search)
  static final List<RegExp> _kkTitlePatterns = [
    RegExp(r'kartu\s*keluarga', caseSensitive: false),
    RegExp(r'KARTU\s*KELUARGA'),
    RegExp(r'[Kk][Aa4]rtu\s*[Kk][Ee3]luarga'),
  ];

  // ================================================================
  // MAIN PARSE METHOD
  // ================================================================

  static KkParseResult parse(OcrResult ocrResult) {
    final rawText = ocrResult.fullText;
    print('\n=== KK PARSER v2 (label-position tokenization) ===');
    print('Raw text length: ${rawText.length}, blocks: ${ocrResult.blocks.length}');

    // Step 1: Extract No KK (multi-strategy)
    final noKK = _extractNoKk(rawText, ocrResult.blocks);

    // Step 2: Extract header fields using label-position tokenization
    final fields = _extractFieldsByLabelPositions(rawText);

    // Step 3: Fallback — try block-based extraction for missing fields
    _tryBlockBasedFallback(fields, ocrResult.blocks);

    // Step 4: Clean extracted values per field type
    _cleanExtractedValues(fields);

    final confidence = _calculateConfidence(ocrResult, noKK, fields);

    print('─── Results ───');
    print('  No KK: ${noKK ?? "NOT FOUND"}');
    fields.forEach((k, v) => print('  $k: $v'));
    print('  Confidence: ${(confidence * 100).round()}%');
    print('=== END KK PARSER ===\n');

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

  // ================================================================
  // LABEL-POSITION TOKENIZATION (core algorithm)
  // ================================================================

  /// Extract fields by finding all label positions and extracting values
  /// between consecutive labels.
  ///
  /// How it works:
  /// 1. Find the position (start, end) of every known label in the text
  /// 2. Sort all found positions by their start index
  /// 3. For each label, the "value" is the text between labelEnd and the
  ///    start of the next label (regardless of newlines or column layout)
  ///
  /// This naturally handles:
  /// - Two-column layout: "Alamat : JL.ABC  Kecamatan : KEBAYORAN"
  ///   → Alamat value stops at "Kecamatan" position
  /// - Split blocks: "Nama Kepala Keluarga\n: AZWAR EFFENDI\nAlamat..."
  ///   → Value extracted between "Keluarga" end and "Alamat" start
  /// - Missing colons: "Alamat JL.ABC" → colon removal is optional
  static Map<String, String> _extractFieldsByLabelPositions(String text) {
    final result = <String, String>{};

    // Step A: Find positions of all known labels
    final positions = <_LabelPos>[];
    for (final def in _fieldDefs) {
      for (final pattern in def.patterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          positions.add(_LabelPos(def.fieldName, match.start, match.end));
          break; // First matching pattern per field wins
        }
      }
    }

    // Step B: Find table-start markers as value terminators
    for (final marker in _tableStartMarkers) {
      final match = marker.firstMatch(text);
      if (match != null) {
        positions.add(_LabelPos('_table_', match.start, match.end));
        break; // Only need one
      }
    }

    // Sort by position in text
    positions.sort((a, b) => a.start.compareTo(b.start));

    print('  Labels found (${positions.length}): '
        '${positions.map((p) => '${p.fieldName}@${p.start}').join(', ')}');

    // Step C: Extract value between each label and the next
    for (int i = 0; i < positions.length; i++) {
      final current = positions[i];
      if (current.fieldName.startsWith('_')) continue; // Skip markers

      // Value ends at next label start, or end of text (max 300 chars)
      final nextStart = (i + 1 < positions.length)
          ? positions[i + 1].start
          : text.length;

      final maxLen = 300;
      final endPos = (nextStart - current.labelEnd > maxLen)
          ? current.labelEnd + maxLen
          : nextStart;

      final valueRegion = text.substring(current.labelEnd, endPos);

      // Clean: remove colon/separator prefix, collapse whitespace
      var value = valueRegion
          .replaceFirst(RegExp(r'^\s*[:=\-]+\s*'), '') // Remove ": " prefix
          .replaceAll(RegExp(r'[\r\n]+'), ' ') // Newlines → space
          .replaceAll(RegExp(r'\s{3,}'), ' ') // Collapse 3+ spaces
          .trim();

      if (value.isNotEmpty && value.length > 1) {
        result[current.fieldName] = value;
        print('  [label-pos] ${current.fieldName}: "$value"');
      }
    }

    return result;
  }

  // ================================================================
  // BLOCK-BASED FALLBACK
  // ================================================================

  /// For fields not found by label-position tokenization, try block-based
  /// extraction using ML Kit's spatial block data.
  ///
  /// Searches blocks for label text, then extracts value from the same
  /// block (after label) or the next block.
  static void _tryBlockBasedFallback(
      Map<String, String> fields, List<OcrBlock> blocks) {
    if (blocks.isEmpty) return;

    for (final def in _fieldDefs) {
      if (fields.containsKey(def.fieldName)) continue;
      if (def.fieldName == 'provinsi') continue; // Skip, not in result

      for (int i = 0; i < blocks.length; i++) {
        final blockText = blocks[i].text.trim();
        bool found = false;

        for (final pattern in def.patterns) {
          final match = pattern.firstMatch(blockText);
          if (match == null) continue;

          // Try extracting value from SAME block (after label)
          var value = blockText
              .substring(match.end)
              .replaceFirst(RegExp(r'^\s*[:=\-]+\s*'), '')
              .trim();

          if (value.isNotEmpty && value.length > 1 && !_isLabelText(value)) {
            fields[def.fieldName] = value;
            print('  [block-same] ${def.fieldName}: "$value"');
            found = true;
            break;
          }

          // Try NEXT block as value
          if (i + 1 < blocks.length) {
            var nextValue = blocks[i + 1]
                .text
                .trim()
                .replaceFirst(RegExp(r'^\s*[:=\-]+\s*'), '')
                .trim();
            if (nextValue.isNotEmpty &&
                nextValue.length > 1 &&
                !_isLabelText(nextValue)) {
              fields[def.fieldName] = nextValue;
              print('  [block-next] ${def.fieldName}: "$nextValue"');
              found = true;
              break;
            }
          }

          break; // Pattern matched, stop trying other patterns
        }

        if (found) break; // Found value for this field, move to next field
      }
    }
  }

  /// Check if text looks like a known label rather than a value.
  static bool _isLabelText(String text) {
    final lower = text.toLowerCase().trim();
    // Check against all field label patterns
    return _fieldDefs.any(
        (def) => def.patterns.any((p) => p.hasMatch(lower)));
  }

  // ================================================================
  // VALUE CLEANING
  // ================================================================

  /// Clean extracted values based on expected format for each field.
  ///
  /// Each field type has specific cleaning rules:
  /// - namaKepalaKeluarga: uppercase name, remove trailing label fragments
  /// - rtRw: extract ###/### pattern
  /// - kodePos: extract 5 digits
  /// - Others: trim trailing garbage (table headers, numbers)
  static void _cleanExtractedValues(Map<String, String> fields) {
    // ── Nama Kepala Keluarga ──────────────────────────────────
    if (fields.containsKey('namaKepalaKeluarga')) {
      var name = fields['namaKepalaKeluarga']!;

      // Remove trailing text that starts with a known label keyword
      name = name.replaceAll(
          RegExp(
              r'\s*(Desa|Kelurahan|Kecamatan|Kabupaten|Provinsi|Kode|Alamat|RT/?\s*RW)\b.*$',
              caseSensitive: false),
          '');

      // Remove trailing colon fragments (from merged label text)
      name = name.replaceAll(RegExp(r'\s*[:;].*$'), '');

      // Extract uppercase name characters (letters, spaces, dots, apostrophes)
      final nameMatch =
          RegExp(r"^([A-Z][A-Z\s\.'\-,]+)", caseSensitive: false)
              .firstMatch(name.trim());
      if (nameMatch != null) {
        name = nameMatch.group(1)!.trim();
      }

      // Remove leading/trailing garbage characters
      name = name.replaceAll(RegExp(r'^[^A-Za-z]+|[^A-Za-z]+$'), '').trim();

      if (name.isNotEmpty && name.length > 2) {
        fields['namaKepalaKeluarga'] = name.toUpperCase();
      } else {
        fields.remove('namaKepalaKeluarga');
      }
    }

    // ── Alamat ────────────────────────────────────────────────
    _trimTrailingLabels(fields, 'alamat');

    // ── RT/RW: extract ###/### pattern ────────────────────────
    if (fields.containsKey('rtRw')) {
      final match =
          RegExp(r'(\d{1,3})\s*/\s*(\d{1,3})').firstMatch(fields['rtRw']!);
      if (match != null) {
        fields['rtRw'] = '${match.group(1)}/${match.group(2)}';
      } else {
        fields.remove('rtRw');
      }
    }

    // ── Kode Pos: extract 5 digits ────────────────────────────
    if (fields.containsKey('kodePos')) {
      final match = RegExp(r'(\d{5})').firstMatch(fields['kodePos']!);
      if (match != null) {
        fields['kodePos'] = match.group(1)!;
      } else {
        fields.remove('kodePos');
      }
    }

    // ── Text fields: uppercase cleanup ────────────────────────
    for (final key in ['kelDesa', 'kecamatan', 'kota']) {
      if (fields.containsKey(key)) {
        var val = fields[key]!;

        // Remove trailing label fragments
        val = val.replaceAll(
            RegExp(
                r'\s*(Desa|Kelurahan|Kecamatan|Kabupaten|Provinsi|Kode|Alamat|RT|No\b|NIK|Jenis|Nama|Tempat|Tanggal|Agama).*$',
                caseSensitive: false),
            '');

        // Remove trailing digits (table column numbers bleeding in)
        val = val.replaceAll(RegExp(r'\s*\d+\s*$'), '');

        // Remove leading/trailing garbage
        val = val
            .replaceAll(RegExp(r'^[^A-Za-z]+|[^A-Za-z\s]+$'), '')
            .trim();

        if (val.isNotEmpty && val.length > 1) {
          fields[key] = val.toUpperCase();
        } else {
          fields.remove(key);
        }
      }
    }

    // ── Fuzzy match kota against city dictionary ──────────────
    if (fields.containsKey('kota')) {
      final matched = OcrPostProcessor.fuzzyMatchKota(fields['kota']!);
      if (matched != null) fields['kota'] = matched;
    }

    // Remove provinsi (not in KkParseResult, only used for confidence)
    fields.remove('provinsi');
  }

  /// Remove trailing known label keywords from a field value.
  static void _trimTrailingLabels(Map<String, String> fields, String key) {
    if (!fields.containsKey(key)) return;
    var val = fields[key]!;
    val = val.replaceAll(
        RegExp(
            r'\s*(Desa|Kelurahan|Kecamatan|Kabupaten|Provinsi|Kode\s*Pos|RT|No\b|NIK)\b.*$',
            caseSensitive: false),
        '');
    val = val.trim();
    if (val.isNotEmpty && val.length > 1) {
      fields[key] = val;
    } else {
      fields.remove(key);
    }
  }

  // ================================================================
  // No KK EXTRACTION (multi-strategy)
  // ================================================================

  /// Extract No KK with fuzzy label matching + spatial-aware extraction.
  ///
  /// Strategy priority (highest → lowest confidence):
  /// 1. Fuzzy "No." label match (label present near digits)
  /// 2. Block-based: find "No" block, check next blocks for 16 digits
  /// 3. "Kartu Keluarga" title → search nearby 16 digits
  /// 4. 16 digits near "No" text (within 200 chars)
  /// 5. First valid 16-digit sequence in full text (lowest confidence)
  static String? _extractNoKk(String text, List<OcrBlock> blocks) {
    var corrected = _applyDigitCorrections(text);

    // Strategy 1: Fuzzy "No." label match
    for (final pattern in _noLabelPatterns) {
      final match = pattern.firstMatch(corrected);
      if (match != null) {
        final digits = match.group(1)!.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length >= 16) {
          final noKK = digits.substring(0, 16);
          if (isValidNoKK(noKK)) {
            print('  Found No KK (strategy 1: label match): $noKK');
            return noKK;
          }
        }
      }
    }

    // Strategy 2: Block-based
    if (blocks.isNotEmpty) {
      final noKK = _findNoKkFromBlocks(blocks);
      if (noKK != null) return noKK;
    }

    // Strategy 3: Near "Kartu Keluarga" title
    for (final titlePattern in _kkTitlePatterns) {
      final titleMatch = titlePattern.firstMatch(corrected);
      if (titleMatch != null) {
        final searchEnd =
            (titleMatch.end + 500).clamp(0, corrected.length);
        final searchRegion =
            corrected.substring(titleMatch.start, searchEnd);
        final digitsOnly =
            searchRegion.replaceAll(RegExp(r'[^0-9]'), '');
        final match = RegExp(r'\d{16}').firstMatch(digitsOnly);
        if (match != null && isValidNoKK(match.group(0)!)) {
          print(
              '  Found No KK (strategy 3: near title): ${match.group(0)}');
          return match.group(0);
        }
      }
    }

    // Strategy 4: 16 digits near "No" text (within 200 chars)
    final noRegion = RegExp(r'[Nn][Oo0].{0,200}', caseSensitive: false)
        .firstMatch(corrected);
    if (noRegion != null) {
      final regionDigits =
          noRegion.group(0)!.replaceAll(RegExp(r'[^0-9]'), '');
      final match = RegExp(r'\d{16}').firstMatch(regionDigits);
      if (match != null && isValidNoKK(match.group(0)!)) {
        print(
            '  Found No KK (strategy 4: near "No"): ${match.group(0)}');
        return match.group(0);
      }
    }

    // Strategy 5: Any valid 16-digit sequence (prefer earlier ones)
    final allDigits = corrected.replaceAll(RegExp(r'[^0-9]'), '');
    final matches = RegExp(r'\d{16}').allMatches(allDigits).toList();
    for (final m in matches) {
      final noKK = m.group(0)!;
      if (isValidNoKK(noKK)) {
        print('  Found No KK (strategy 5: global scan): $noKK');
        return noKK;
      }
    }

    print('  No valid No KK found');
    return null;
  }

  /// Search blocks for No KK using spatial proximity to "No" label block.
  static String? _findNoKkFromBlocks(List<OcrBlock> blocks) {
    for (int i = 0; i < blocks.length; i++) {
      final blockText = blocks[i].text.trim();
      // Check if this block contains a "No" label
      if (RegExp(r'^[Nn][Oo0]\.?\s*[:\-=]?\s*$').hasMatch(blockText) ||
          RegExp(r'^[Nn][Oo0]\.?\s*[Kk][Kk]?\s*[:\-=]?\s*$')
              .hasMatch(blockText)) {
        // Check this block and next 3 blocks for 16 digits
        for (int j = i; j < blocks.length && j <= i + 3; j++) {
          final corrected = _applyDigitCorrections(blocks[j].text);
          final digits = corrected.replaceAll(RegExp(r'[^0-9]'), '');
          if (digits.length >= 16) {
            final noKK = digits.substring(0, 16);
            if (isValidNoKK(noKK)) {
              print(
                  '  Found No KK (strategy 2: block "${blocks[i].text}"): $noKK');
              return noKK;
            }
          }
        }
      }
    }
    return null;
  }

  // ================================================================
  // OCR DIGIT CORRECTIONS
  // ================================================================

  /// Apply common OCR digit corrections.
  ///
  /// Fixes character confusion in digit sequences:
  /// - O/o → 0, I/l/|/L → 1, S/s → 5, B → 8, ? → 7
  /// Also fixes at sequence boundaries (e.g., "O3217..." → "03217...")
  static String _applyDigitCorrections(String text) {
    var out = text;

    // Between digits
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d)[Oo](?=\d)'), (m) => '0');
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d)[Il|](?=\d)'), (m) => '1');
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d)[Zz](?=\d)'), (m) => '2');
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d)[Ss](?=\d)'), (m) => '5');
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d)[bgGL](?=\d)'), (m) => '6');
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d)[B](?=\d)'), (m) => '8');
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d)[\?](?=\d)'), (m) => '7');

    // At sequence start: "O3217..." → "03217..."
    out = out.replaceAllMapped(
        RegExp(r'\b[Oo](?=\d{15})'), (m) => '0');
    out = out.replaceAllMapped(
        RegExp(r'\b[Il|](?=\d{15})'), (m) => '1');
    out = out.replaceAllMapped(
        RegExp(r'\b[Zz](?=\d{15})'), (m) => '2');
    out = out.replaceAllMapped(
        RegExp(r'\b[bgGL](?=\d{15})'), (m) => '6');
    out = out.replaceAllMapped(
        RegExp(r'\b[B](?=\d{15})'), (m) => '8');

    // At sequence end: "...3217O" → "...32170"
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d{15})[Oo]\b'), (m) => '0');
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d{15})[Il|]\b'), (m) => '1');
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d{15})[Zz]\b'), (m) => '2');
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d{15})[bgGL]\b'), (m) => '6');
    out = out.replaceAllMapped(
        RegExp(r'(?<=\d{15})[B]\b'), (m) => '8');

    return out;
  }

  // ================================================================
  // CONFIDENCE SCORING
  // ================================================================

  /// Multi-factor confidence scoring.
  ///
  /// Factors:
  /// - No KK found + valid (30%)
  /// - Text quality — clean char ratio (15%)
  /// - KK labels detected (15%)
  /// - No KK validation (20%)
  /// - Fields extracted count (20%)
  static double _calculateConfidence(
      OcrResult ocrResult, String? noKK, Map<String, String> fields) {
    if (ocrResult.fullText.isEmpty) return 0.0;

    double score = 0;

    // Factor 1: No KK found (30%)
    if (noKK != null) score += 0.3;

    // Factor 2: Text quality (15%)
    final allText = ocrResult.fullText;
    final cleanChars =
        RegExp(r'[a-zA-Z0-9.,\s:/\-]').allMatches(allText).length;
    final cleanRatio =
        allText.isNotEmpty ? cleanChars / allText.length : 0.0;
    score += cleanRatio * 0.15;

    // Factor 3: KK labels detected (15%)
    final labelChecks = [
      RegExp(r'Kartu\s*Keluarga', caseSensitive: false),
      RegExp(r'[Nn][Oo]\.', caseSensitive: false),
      RegExp(r'Kepala\s*Keluarga', caseSensitive: false),
    ];
    int labelsFound = 0;
    for (final label in labelChecks) {
      if (label.hasMatch(allText)) labelsFound++;
    }
    score += (labelsFound / labelChecks.length) * 0.15;

    // Factor 4: No KK validation (20%)
    if (noKK != null && isValidNoKK(noKK)) score += 0.2;

    // Factor 5: Fields extracted (20%)
    final fieldCount =
        fields.entries.where((e) => e.value.isNotEmpty).length;
    const maxFields = 7; // nama, alamat, rtRw, kelDesa, kecamatan, kota, kodePos
    score += (fieldCount / maxFields).clamp(0.0, 1.0) * 0.2;

    return score.clamp(0.0, 1.0);
  }

  // ================================================================
  // VALIDATION
  // ================================================================

  /// Validate No KK structure (lenient).
  ///
  /// Checks:
  /// - Exactly 16 digits
  /// - Province code 11-99 (first 2 digits)
  /// - Not all zeros / not all same digit
  static bool isValidNoKK(String noKK) {
    if (noKK.length != 16) return false;
    if (!RegExp(r'^\d{16}$').hasMatch(noKK)) return false;

    final pp = int.tryParse(noKK.substring(0, 2)) ?? 0;
    if (pp < 11 || pp > 99) return false;

    // All zeros = invalid
    if (noKK == '0000000000000000') return false;

    // All same digit = invalid
    if (RegExp(r'^(\d)\1{15}$').hasMatch(noKK)) return false;

    return true;
  }
}
