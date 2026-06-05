import 'dart:io';

/// Document type for OCR preprocessing
///
/// Each type has different ROI cropping behavior:
/// - kk:   crop top 35% (header only: No KK, Alamat, Kode Pos)
/// - ktp:  no crop (full card: NIK, Nama, TTL, Alamat, etc.)
/// - general: no crop (default)
enum DocumentType { ktp, kk, general }

/// Result of OCR text recognition
class OcrResult {
  final String fullText;
  final List<OcrBlock> blocks;

  OcrResult({required this.fullText, required this.blocks});
}

/// A block of recognized text (paragraph/section)
class OcrBlock {
  final String text;

  OcrBlock({required this.text});
}

/// Abstract interface for OCR services
abstract class OcrService {
  /// Recognize text from an image file (whole image OCR)
  ///
  /// [documentType] controls preprocessing behavior:
  /// - DocumentType.kk: crops top 35% to focus on header
  /// - DocumentType.ktp / DocumentType.general: no cropping
  Future<OcrResult> recognizeText(File imageFile,
      {DocumentType documentType = DocumentType.general});

  /// Dispose resources
  void dispose();
}
