import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'ocr_service.dart';

/// ML Kit implementation of OcrService - optimized for speed
class MlkitOcrService implements OcrService {
  TextRecognizer? _textRecognizer;

  TextRecognizer get recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  @override
  Future<OcrResult> recognizeText(File imageFile) async {
    print('=== OCR START ===');

    // Resize image for faster processing
    final processedFile = await _preprocessImage(imageFile);
    
    // Single OCR pass on optimized image
    final text = await _recognizeText(processedFile);
    
    print('Text length: ${text.length}');
    print('=== OCR END ===\n');

    return OcrResult(
      fullText: text,
      blocks: [],
    );
  }

  Future<String> _recognizeText(File file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    final recognizedText = await recognizer.processImage(inputImage);
    return recognizedText.text;
  }

  /// Preprocess image - single optimized version for speed
  Future<File> _preprocessImage(File inputFile) async {
    try {
      final bytes = await inputFile.readAsBytes();
      final decoded = img.decodeImage(bytes);

      if (decoded == null) return inputFile;

      // Fix orientation
      final oriented = img.bakeOrientation(decoded);

      // Resize to max 1600px width (balance between quality and speed)
      final targetWidth = oriented.width > 1600 ? 1600 : oriented.width;
      final resized = targetWidth == oriented.width
          ? oriented
          : img.copyResize(oriented, width: targetWidth);

      // Simple grayscale - fast and good for OCR
      final grayscale = img.grayscale(resized);

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}${Platform.pathSeparator}kk_optimized.jpg';
      final file = File(path);
      await file.writeAsBytes(img.encodeJpg(grayscale, quality: 90), flush: true);
      
      print('Optimized: ${oriented.width}x${oriented.height} -> ${resized.width}x${resized.height}');
      return file;
    } catch (e) {
      print('Preprocessing failed, using original: $e');
      return inputFile;
    }
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
