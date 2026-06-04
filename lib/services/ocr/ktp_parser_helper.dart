import 'ocr_service.dart';

/// Result of parsing KTP text
class KtpParseResult {
  final String? nik;
  final String? nama;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? alamat;
  final String? agama;
  final String? statusPerkawinan;
  final String? pekerjaan;
  final String? kewarganegaraan;
  final String rawText;
  final double confidence;

  KtpParseResult({
    this.nik,
    this.nama,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.alamat,
    this.agama,
    this.statusPerkawinan,
    this.pekerjaan,
    this.kewarganegaraan,
    required this.rawText,
    this.confidence = 0.0,
  });

  bool get hasNik => nik != null && nik!.isNotEmpty;
  bool get hasNama => nama != null && nama!.isNotEmpty;
  bool get hasTempatLahir => tempatLahir != null && tempatLahir!.isNotEmpty;
  bool get hasTanggalLahir => tanggalLahir != null && tanggalLahir!.isNotEmpty;
  bool get hasJenisKelamin => jenisKelamin != null && jenisKelamin!.isNotEmpty;
  bool get hasAlamat => alamat != null && alamat!.isNotEmpty;
  bool get hasAnyData => hasNik || hasNama;
}

/// Parse Indonesian KTP - ROBUST VERSION
/// Handle messy OCR output by searching for patterns, not just labels
class KtpParserHelper {
  static KtpParseResult parse(OcrResult ocrResult) {
    final rawText = ocrResult.fullText;
    
    print('\n=== KTP PARSER ===');
    print('Raw text:\n$rawText');

    double confidence = 0.0;

    // 1. NIK - always 16 digits, easiest to find
    String? nik = _findNik(rawText);
    if (nik != null) confidence += 0.4;

    // 2. Nama - look for ALL CAPS text (Indonesian names are usually uppercase)
    String? nama = _findNama(rawText, nik);
    if (nama != null) confidence += 0.2;

    // 3. TTL - look for date pattern DD-MM-YYYY
    final ttl = _findTTL(rawText);
    if (ttl != null) confidence += 0.15;

    // 4. JK - look for LAKI-LAKI or PEREMPUAN
    String? jk = _findJK(rawText);
    if (jk != null) confidence += 0.1;

    // 5. Alamat - look for JL/GG/GANG patterns
    String? alamat = _findAlamat(rawText);
    if (alamat != null) confidence += 0.1;

    // 6. Agama - look for religion keywords
    String? agama = _findAgama(rawText);

    // 7. Status - look for KAWIN/BELOM KAWIN
    String? status = _findStatus(rawText);

    // 8. Pekerjaan - look for job keywords
    String? pekerjaan = _findPekerjaan(rawText);

    // 9. KWN - look for WNI/WNA
    String? kwn = _findKWN(rawText);

    print('\nFinal:');
    print('  NIK: ${nik ?? "-"}');
    print('  Nama: ${nama ?? "-"}');
    print('  TTL: ${ttl ?? "-"}');
    print('  JK: ${jk ?? "-"}');
    print('  Alamat: ${alamat ?? "-"}');
    print('  Agama: ${agama ?? "-"}');
    print('  Status: ${status ?? "-"}');
    print('  Pekerjaan: ${pekerjaan ?? "-"}');
    print('  KWN: ${kwn ?? "-"}');
    print('  Confidence: ${(confidence * 100).round()}%');
    print('=== END ===\n');

    return KtpParseResult(
      nik: nik,
      nama: nama,
      tempatLahir: ttl?.$1,
      tanggalLahir: ttl?.$2,
      jenisKelamin: jk,
      alamat: alamat,
      agama: agama,
      statusPerkawinan: status,
      pekerjaan: pekerjaan,
      kewarganegaraan: kwn,
      rawText: rawText,
      confidence: confidence,
    );
  }

  /// Find NIK - 16 consecutive digits
  static String? _findNik(String text) {
    // Remove spaces and find 16 digits
    final allDigits = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Find first 16-digit sequence
    final match = RegExp(r'\d{16}').firstMatch(allDigits);
    if (match != null) {
      final nik = match.group(0)!;
      print('Found NIK: $nik');
      return nik;
    }
    
    // Try with spaces/dashes
    final match2 = RegExp(r'\d{4}[\s\-]?\d{4}[\s\-]?\d{4}[\s\-]?\d{4}').firstMatch(text);
    if (match2 != null) {
      final nik = match2.group(0)!.replaceAll(RegExp(r'[\s\-]'), '');
      print('Found NIK (with spaces): $nik');
      return nik;
    }
    
    return null;
  }

  /// Find Nama - usually the longest ALL CAPS word
  static String? _findNama(String text, String? nik) {
    final lines = text.split(RegExp(r'[\r\n]+'));
    
    // Strategy 1: Look for line that's mostly uppercase letters (3+ chars)
    for (final line in lines) {
      final cleaned = line.trim();
      // Check if line is mostly uppercase and looks like a name
      if (cleaned.length >= 4 && 
          RegExp(r'^[A-Z\s\.]+$').hasMatch(cleaned) &&
          !cleaned.contains('KOTA') &&
          !cleaned.contains('PROVINSI') &&
          !cleaned.contains('KABUPATEN') &&
          !cleaned.contains('LAKI') &&
          !cleaned.contains('PEREMPUAN') &&
          !cleaned.contains('ISLAM') &&
          !cleaned.contains('KRISTEN') &&
          !cleaned.contains('WNI') &&
          !cleaned.contains('WNA')) {
        print('Found Nama (uppercase): $cleaned');
        return cleaned;
      }
    }

    // Strategy 2: Look for text after "Nama" label
    for (final line in lines) {
      if (line.toLowerCase().contains('nama') && !line.toLowerCase().contains('ayah') && !line.toLowerCase().contains('ibu')) {
        // Get text after the label
        final afterNama = line.substring(line.toLowerCase().indexOf('nama') + 4).trim();
        if (afterNama.startsWith(':') || afterNama.startsWith(' ')) {
          final value = afterNama.replaceFirst(RegExp(r'^[:\s]+'), '').trim();
          if (value.length >= 3 && RegExp(r'^[A-Z\s]+$').hasMatch(value)) {
            print('Found Nama (after label): $value');
            return value;
          }
        }
      }
    }

    return null;
  }

  /// Find Tempat/Tanggal Lahir
  static (String, String)? _findTTL(String text) {
    // Find date pattern DD-MM-YYYY or DD/MM/YYYY
    final dateMatch = RegExp(r'(\d{1,2})[\-/](\d{1,2})[\-/](\d{4})').firstMatch(text);
    
    if (dateMatch != null) {
      final day = dateMatch.group(1)!.padLeft(2, '0');
      final month = dateMatch.group(2)!.padLeft(2, '0');
      final year = dateMatch.group(3);
      final tanggal = '$day-$month-$year';
      
      // Find tempat (city name) before the date
      final beforeDate = text.substring(0, dateMatch.start);
      final words = beforeDate.split(RegExp(r'[\s,]+'));
      
      // Look for city name (uppercase, 3+ chars)
      String? tempat;
      for (final word in words.reversed) {
        if (word.length >= 3 && RegExp(r'^[A-Z]+$').hasMatch(word)) {
          tempat = word;
          break;
        }
      }
      
      print('Found TTL: $tempat, $tanggal');
      return (tempat ?? '', tanggal);
    }
    
    return null;
  }

  /// Find Jenis Kelamin - handle OCR errors
  static String? _findJK(String text) {
    final upper = text.toUpperCase();
    
    // Handle OCR errors: "LAKI-LAKE", "LAKI-LAK1", "LAKI LAKI"
    if (upper.contains('LAKI') || upper.contains('LAK-LAK')) {
      return 'Laki-Laki';
    }
    if (upper.contains('PEREMPUAN') || upper.contains('WANITA')) {
      return 'Perempuan';
    }
    
    // Look for "Gol. Darah" pattern - JK is usually before it
    if (upper.contains('GOL') && upper.contains('DARAH')) {
      // Check if L or P appears before "Gol. Darah"
      final golIndex = upper.indexOf('GOL');
      final beforeGol = upper.substring(0, golIndex);
      if (beforeGol.endsWith('L') || beforeGol.contains('LAKI')) {
        return 'Laki-Laki';
      }
      if (beforeGol.endsWith('P') || beforeGol.contains('PEREMPUAN')) {
        return 'Perempuan';
      }
    }
    
    return null;
  }

  /// Find Alamat - look for JL/GG/GANG patterns or address-like text
  static String? _findAlamat(String text) {
    final lines = text.split(RegExp(r'[\r\n]+'));
    
    // Words that are NOT addresses
    final excludeWords = [
      'BERLAKU', 'HINGGA', 'SEUMUR', 'HIDUP', 'KOTA', 'PROVINSI',
      'KABUPATEN', 'TANDA', 'TANGAN', 'CAP', 'NIK', 'NAMA',
    ];
    
    for (final line in lines) {
      final upper = line.toUpperCase().trim();
      
      // Skip lines with excluded words
      if (excludeWords.any((w) => upper.contains(w))) continue;
      
      // Look for street patterns
      if (upper.contains('JL') || upper.contains('JALAN') || 
          upper.contains('GG') || upper.contains('GANG') ||
          upper.contains('BLOK') || upper.contains('KAV') ||
          upper.contains('NO ') || upper.contains('NO.')) {
        // Clean up
        var alamat = line.trim();
        // Remove "Alamat" prefix if exists
        alamat = alamat.replaceFirst(RegExp(r'^Alamat\s*[:\-=]?\s*', caseSensitive: false), '');
        // Remove leading ": "
        alamat = alamat.replaceFirst(RegExp(r'^[:\s]+'), '');
        
        if (alamat.length >= 5) {
          print('Found Alamat (street pattern): $alamat');
          return alamat;
        }
      }
    }
    
    // Look for address pattern: text after ":" that looks like address
    for (final line in lines) {
      if (line.contains(':')) {
        final afterColon = line.split(':').skip(1).join(':').trim();
        // Check if it looks like an address (has numbers and letters, 10+ chars)
        if (afterColon.length >= 10 && 
            RegExp(r'[A-Za-z]').hasMatch(afterColon) &&
            RegExp(r'\d').hasMatch(afterColon) &&
            !excludeWords.any((w) => afterColon.toUpperCase().contains(w))) {
          print('Found Alamat (after colon): $afterColon');
          return afterColon;
        }
      }
    }
    
    return null;
  }

  /// Find Agama - handle OCR errors
  static String? _findAgama(String text) {
    final upper = text.toUpperCase();
    
    // Handle OCR errors
    if (upper.contains('ISLAM') || upper.contains('SLAM') || upper.contains('ISLM')) {
      return 'Islam';
    }
    if (upper.contains('KRISTEN') || upper.contains('KRRISTEN')) {
      return 'Kristen';
    }
    if (upper.contains('KATOLIK') || upper.contains('KATOLLK')) {
      return 'Katolik';
    }
    if (upper.contains('HINDU')) {
      return 'Hindu';
    }
    if (upper.contains('BUDDHA') || upper.contains('BUDHA')) {
      return 'Buddha';
    }
    if (upper.contains('KONGHUCU') || upper.contains('KONG HUCU')) {
      return 'Konghucu';
    }
    
    return null;
  }

  /// Find Status Perkawinan
  static String? _findStatus(String text) {
    final upper = text.toUpperCase();
    
    if (upper.contains('BELUM KAWIN') || upper.contains('BELUM KANINE')) {
      return 'Belum Kawin';
    }
    if (upper.contains('KAWIN') && !upper.contains('BELUM')) {
      return 'Kawin';
    }
    if (upper.contains('CERAI HIDUP')) {
      return 'Cerai Hidup';
    }
    if (upper.contains('CERAI MATI')) {
      return 'Cerai Mati';
    }
    
    return null;
  }

  /// Find Pekerjaan
  static String? _findPekerjaan(String text) {
    final jobs = [
      'PELAJAR', 'MAHASISWA', 'PEGAWAI', 'KARYAWAN', 'WIRASWASTA',
      'GURU', 'DOSEN', 'DOKTER', 'PNS', 'TNI', 'POLRI', 'BURUH',
      'PETANI', 'NELAYAN', 'PENSIUNAN', 'IBU RUMAH TANGGA', 'BELUM BEKERJA',
    ];
    
    final upper = text.toUpperCase();
    
    for (final job in jobs) {
      if (upper.contains(job)) {
        print('Found Pekerjaan: $job');
        return job[0] + job.substring(1).toLowerCase();
      }
    }
    
    return null;
  }

  /// Find Kewarganegaraan
  static String? _findKWN(String text) {
    final upper = text.toUpperCase();
    
    if (upper.contains('WNI') || upper.contains('WARGA NEGARA INDONESIA')) {
      return 'WNI';
    }
    if (upper.contains('WNA') || upper.contains('WARGA NEGARA ASING')) {
      return 'WNA';
    }
    
    return null;
  }
}
