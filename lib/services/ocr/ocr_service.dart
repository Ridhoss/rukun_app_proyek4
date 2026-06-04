import 'dart:io';

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
  /// Recognize text from an image file
  Future<OcrResult> recognizeText(File imageFile);

  /// Dispose resources
  void dispose();
}
