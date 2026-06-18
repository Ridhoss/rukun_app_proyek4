import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'image_preprocessor.dart';
import 'ocr_service.dart';
import 'ocr_post_processor.dart';

/// ML Kit implementation of OcrService with full PCD preprocessing pipeline.
///
/// Preprocessing (runs in background Isolate):
/// - EXIF orientation fix
/// - Force portrait for KTP/KK
/// - Resize if > 2000px
/// - Grayscale (ITU-R BT.601)
/// - Otsu's binary thresholding
///
/// The ML Kit Document Scanner handles perspective correction and edge detection
/// when using the "Scan" button. This preprocessor handles the rest.
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

    // Preprocess in background Isolate (EXIF + portrait + resize + grayscale + Otsu)
    final processedPath = await ImagePreprocessor.preprocess(
      inputPath: imageFile.path,
      documentType: documentType,
      enableBinarization: documentType != DocumentType.general,
    );
    final processedFile = File(processedPath);

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

  @override
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
