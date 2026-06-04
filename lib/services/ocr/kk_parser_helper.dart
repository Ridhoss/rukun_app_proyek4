import 'ocr_service.dart';

/// Candidate for No KK with confidence score
class _NoKKCandidate {
  final String number;
  final int position; // Position in original text
  final int confidence; // Higher = more likely to be No KK

  _NoKKCandidate(this.number, this.position, this.confidence);
}

/// Candidate for Kode Pos with confidence score
class _KodePosCandidate {
  final String number;
  final int position;
  final int confidence;

  _KodePosCandidate(this.number, this.position, this.confidence);
}

/// Result of parsing KK (Kartu Keluarga) text
class KkParseResult {
  final String? noKK;
  final String? alamat;
  final String? kodePos;
  final String rawText;
  final double confidence;

  KkParseResult({
    this.noKK,
    this.alamat,
    this.kodePos,
    required this.rawText,
    this.confidence = 0.0,
  });

  bool get hasNoKK => noKK != null && noKK!.isNotEmpty;
  bool get hasAlamat => alamat != null && alamat!.isNotEmpty;
  bool get hasKodePos => kodePos != null && kodePos!.isNotEmpty;
  bool get hasAnyData => hasNoKK || hasAlamat || hasKodePos;

  @override
  String toString() {
    return 'KkParseResult(noKK: $noKK, alamat: $alamat, kodePos: $kodePos, confidence: $confidence)';
  }
}

/// Parse Indonesian Kartu Keluarga (KK)
/// 
/// IMPORTANT: OCR reads images in arbitrary order!
/// "KARTU KELUARGA" and "No." might appear in the middle or end of text.
/// We must search the ENTIRE text, not just the beginning.
class KkParserHelper {
  /// Parse KK text from OCR result
  static KkParseResult parse(OcrResult ocrResult) {
    final rawText = ocrResult.fullText;
    
    print('\n=== KK PARSER ===');
    print('Input: ${rawText.length} chars, ${rawText.split('\n').length} lines');

    // Fix OCR mistakes for numbers
    final corrected = _fixCommonOcrMistakes(rawText);
    
    double confidence = 0.0;

    // Search ENTIRE text for No KK
    String? noKK = _extractNoKk(corrected, rawText);
    print('No KK: ${noKK ?? "NOT FOUND"}');
    if (noKK != null) confidence += 0.4;

    // Search ENTIRE text for Alamat
    String? alamat = _extractAlamat(rawText);
    print('Alamat: ${alamat ?? "NOT FOUND"}');
    if (alamat != null) confidence += 0.3;

    // Search ENTIRE text for Kode Pos
    String? kodePos = _extractKodePos(corrected);
    print('Kode Pos: ${kodePos ?? "NOT FOUND"}');
    if (kodePos != null) confidence += 0.3;

    print('Confidence: ${(confidence * 100).round()}%');
    print('=== END ===\n');

    return KkParseResult(
      noKK: noKK,
      alamat: alamat,
      kodePos: kodePos,
      rawText: rawText,
      confidence: confidence,
    );
  }

  /// Fix common OCR mistakes for numbers
  static String _fixCommonOcrMistakes(String s) {
    var out = s;
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[Oo](?=\d)'), (m) => '0');
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[Il|](?=\d)'), (m) => '1');
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[Ss](?=\d)'), (m) => '5');
    out = out.replaceAllMapped(RegExp(r'(?<=\d)[B](?=\d)'), (m) => '8');
    return out;
  }

  /// Extract No KK - search ENTIRE text with validation
  static String? _extractNoKk(String corrected, String original) {
    final candidates = <_NoKKCandidate>[];

    // Strategy 1: Find "No." followed by 16 digits (most reliable - near header)
    final noPattern = RegExp(
      r'No\.?\s*[:\-=]?\s*(\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4})',
      caseSensitive: false,
    );
    
    for (final match in noPattern.allMatches(original)) {
      final digits = match.group(1)?.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits != null && digits.length >= 16) {
        candidates.add(_NoKKCandidate(
          digits.substring(0, 16),
          match.start,
          100, // High confidence - found with "No." label
        ));
      }
    }

    // Strategy 2: Find "No KK" or "Nomor KK" label
    final labelMatch = RegExp(
      r'(?:no\.?\s*kk|nomor\s*kk)[\s:\-]*(\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4}[\s\.\-]?\d{4})',
      caseSensitive: false,
    ).firstMatch(original);

    if (labelMatch != null) {
      final digits = labelMatch.group(1)?.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits != null && digits.length >= 16) {
        candidates.add(_NoKKCandidate(
          digits.substring(0, 16),
          labelMatch.start,
          150, // Highest confidence - found with "No KK" label
        ));
      }
    }

    // Strategy 3: Find 16-digit numbers near "KARTU KELUARGA" title
    final kkTitleMatch = RegExp(
      r'kartu\s*keluarga',
      caseSensitive: false,
    ).firstMatch(original);

    if (kkTitleMatch != null) {
      // Search within 500 chars after the title
      final searchEnd = (kkTitleMatch.end + 500).clamp(0, original.length);
      final searchText = original.substring(kkTitleMatch.start, searchEnd);
      final allDigits = searchText.replaceAll(RegExp(r'[^0-9]'), '');
      
      for (final match in RegExp(r'\d{16}').allMatches(allDigits)) {
        candidates.add(_NoKKCandidate(
          match.group(0)!,
          kkTitleMatch.start + match.start,
          80, // Good confidence - near KK title
        ));
      }
    }

    // Strategy 4: Find any 16 consecutive digits (lowest priority)
    final allDigits = original.replaceAll(RegExp(r'[^0-9]'), '');
    for (final match in RegExp(r'\d{16}').allMatches(allDigits)) {
      candidates.add(_NoKKCandidate(
        match.group(0)!,
        original.indexOf(match.group(0)!),
        20, // Low confidence - just a random 16-digit number
      ));
    }

    if (candidates.isEmpty) {
      print('No 16-digit number found');
      return null;
    }

    // Sort by confidence (highest first)
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Log all candidates
    print('No KK candidates:');
    for (final c in candidates) {
      print('  ${c.number} (confidence: ${c.confidence}, position: ${c.position})');
    }

    // Return the highest confidence candidate
    final best = candidates.first;
    print('Selected: ${best.number} (confidence: ${best.confidence})');
    return best.number;
  }

  /// Extract Alamat - search ENTIRE text
  static String? _extractAlamat(String rawText) {
    final lines = rawText.split(RegExp(r'[\r\n]+'));

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final lower = line.toLowerCase();

      // Found "Alamat" label
      if (lower.contains('alamat') && !lower.contains('dikeluarkan')) {
        // Check if value is on the same line (after colon)
        if (line.contains(':')) {
          final afterColon = line.split(':').skip(1).join(':').trim();
          if (afterColon.isNotEmpty && afterColon.length > 5) {
            print('Alamat from same line: "$afterColon"');
            return _cleanAddress(afterColon);
          }
        }

        // Collect next lines
        final buffer = <String>[];
        for (var j = i + 1; j < lines.length && buffer.length < 3; j++) {
          final nextLine = lines[j].trim();
          final nextLower = nextLine.toLowerCase();

          // Stop at these labels
          if (nextLower.startsWith('rt') ||
              nextLower.startsWith('rw') ||
              nextLower.startsWith('desa') ||
              nextLower.startsWith('kelurahan') ||
              nextLower.startsWith('kecamatan') ||
              nextLower.startsWith('kabupaten') ||
              nextLower.startsWith('kode pos') ||
              nextLower.startsWith('provinsi') ||
              nextLower.startsWith('no ') ||
              nextLower.startsWith('no.') ||
              nextLower.contains('dikeluarkan')) {
            break;
          }

          // Skip empty lines or very short
          if (nextLine.length < 3) continue;

          buffer.add(nextLine);
        }

        if (buffer.isNotEmpty) {
          final result = _cleanAddress(buffer.join(' '));
          print('Alamat from next lines: "$result"');
          return result;
        }
      }
    }

    // Fallback: look for address patterns (Jl, Gang, etc.)
    for (final line in lines) {
      final lower = line.trim().toLowerCase();
      if ((lower.startsWith('jl') || lower.startsWith('jalan') || 
           lower.startsWith('gang') || lower.startsWith('gg')) &&
          line.trim().length > 10) {
        print('Alamat from pattern: "${line.trim()}"');
        return _cleanAddress(line.trim());
      }
    }

    return null;
  }

  /// Extract Kode Pos - search ENTIRE text with validation
  static String? _extractKodePos(String corrected) {
    final candidates = <_KodePosCandidate>[];

    // Strategy 1: Find "Kode Pos" label (highest confidence)
    final labelMatch = RegExp(
      r'kode\s*pos[\s:\-]*(\d{5})',
      caseSensitive: false,
    ).firstMatch(corrected);

    if (labelMatch != null) {
      candidates.add(_KodePosCandidate(
        labelMatch.group(1)!,
        labelMatch.start,
        100, // Highest confidence
      ));
    }

    // Strategy 2: Find 5-digit number after "Kabupaten" or "Kota"
    final kabMatch = RegExp(
      r'(?:kabupaten|kota)[\s:\-]*.*?(\d{5})',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(corrected);

    if (kabMatch != null) {
      candidates.add(_KodePosCandidate(
        kabMatch.group(1)!,
        kabMatch.start,
        80,
      ));
    }

    // Strategy 3: Find 5-digit number before "Provinsi"
    final provMatch = RegExp(
      r'(\d{5})[\s:\-]*(?:provinsi)',
      caseSensitive: false,
    ).firstMatch(corrected);

    if (provMatch != null) {
      candidates.add(_KodePosCandidate(
        provMatch.group(1)!,
        provMatch.start,
        70,
      ));
    }

    // Strategy 4: Find 5-digit number near "Kecamatan" or "Kelurahan"
    final kecMatch = RegExp(
      r'(?:kecamatan|kelurahan|desa)[\s:\-]*.*?(\d{5})',
      caseSensitive: false,
      dotAll: true,
    ).allMatches(corrected);

    for (final match in kecMatch) {
      candidates.add(_KodePosCandidate(
        match.group(1)!,
        match.start,
        50,
      ));
    }

    // Strategy 5: Any standalone 5-digit number (lowest confidence)
    for (final match in RegExp(r'(?<!\d)\d{5}(?!\d)').allMatches(corrected)) {
      candidates.add(_KodePosCandidate(
        match.group(0)!,
        match.start,
        10,
      ));
    }

    if (candidates.isEmpty) {
      print('Kode Pos: not found');
      return null;
    }

    // Sort by confidence (highest first)
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Log all candidates
    print('Kode Pos candidates:');
    for (final c in candidates.take(5)) { // Show top 5
      print('  ${c.number} (confidence: ${c.confidence})');
    }

    // Return the highest confidence candidate
    final best = candidates.first;
    print('Selected: ${best.number} (confidence: ${best.confidence})');
    return best.number;
  }

  /// Clean address string
  static String _cleanAddress(String address) {
    String cleaned = address.trim();

    // Remove "Alamat" prefix
    cleaned = cleaned.replaceFirst(
      RegExp(r'^Alamat\s*[:\-=]?\s*', caseSensitive: false),
      '',
    );

    // Remove trailing RT/RW
    cleaned = cleaned.replaceFirst(
      RegExp(r'\s*[,;]?\s*(RT|RW)\s*[:/]?\s*\d+.*$', caseSensitive: false),
      '',
    );

    // Remove trailing kode pos
    cleaned = cleaned.replaceFirst(RegExp(r'\s+\d{5}\s*$'), '');

    // Remove trailing punctuation
    cleaned = cleaned.replaceFirst(RegExp(r'[,;]\s*$'), '');

    return cleaned.trim();
  }

  /// Validate No KK format (must be 16 digits)
  static bool isValidNoKK(String noKK) {
    final cleaned = noKK.replaceAll(RegExp(r'[\s\-]'), '');
    return cleaned.length == 16 && RegExp(r'^\d{16}$').hasMatch(cleaned);
  }

  /// Validate Kode Pos format (must be 5 digits)
  static bool isValidKodePos(String kodePos) {
    return RegExp(r'^\d{5}$').hasMatch(kodePos);
  }

  /// Format No KK for display (XXXX XXXX XXXX XXXX)
  static String formatNoKK(String noKK) {
    final cleaned = noKK.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.length != 16) return noKK;

    return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8, 12)} ${cleaned.substring(12, 16)}';
  }
}
