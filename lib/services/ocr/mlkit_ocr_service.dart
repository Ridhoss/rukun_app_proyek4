import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'ocr_service.dart';
import 'ocr_post_processor.dart';

/// ML Kit implementation of OcrService — minimal preprocessing
///
/// The ML Kit Document Scanner already handles:
/// - Perspective correction
/// - Edge detection
/// - Filter/enhance
/// - Orientation
///
/// So we only do: resize (if too large) → send to ML Kit OCR.
/// No grayscale, no Otsu, no orientation check — let ML Kit handle it.
class MlkitOcrService implements OcrService {
  TextRecognizer? _textRecognizer;

  TextRecognizer get recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  @override
  Future<OcrResult> recognizeText(File imageFile,
      {DocumentType documentType = DocumentType.general}) async {
    print('=== OCR START (${documentType.name}) ===');

    final processedFile =
        await _preprocessImage(imageFile, documentType: documentType);

    final text = await _recognizeText(processedFile);

    // Correct common OCR mistakes
    final corrected = OcrPostProcessor.correctOcrText(text);

    print('Text length: ${corrected.length}');
    print('=== OCR END ===\n');

    return OcrResult(fullText: corrected, blocks: []);
  }

  Future<String> _recognizeText(File file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    final recognizedText = await recognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Minimal preprocessing — just resize if too large
  ///
  /// For scanner output: already clean, just send to OCR.
  /// For gallery output: resize to reasonable size.
  Future<File> _preprocessImage(File inputFile,
      {DocumentType documentType = DocumentType.general}) async {
    try {
      final bytes = await inputFile.readAsBytes();
      var decoded = img.decodeImage(bytes);
      if (decoded == null) return inputFile;

      // Fix EXIF orientation
      decoded = img.bakeOrientation(decoded);

      // Force portrait for KTP/KK
      if (decoded.width > decoded.height) {
        decoded = img.copyRotate(decoded, angle: 90);
      }

      // Resize only if very large (keep quality for ML Kit)
      if (decoded.width > 2000) {
        decoded = img.copyResize(decoded, width: 2000);
      }

      // Save as high quality JPEG
      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}${Platform.pathSeparator}${documentType.name}_ocr.jpg';
      final file = File(path);
      await file.writeAsBytes(img.encodeJpg(decoded, quality: 95), flush: true);

      print('Preprocessed: ${decoded.width}x${decoded.height}');
      return file;
    } catch (e) {
      print('Preprocessing failed: $e');
      return inputFile;
    }
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
