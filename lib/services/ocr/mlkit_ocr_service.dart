import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

import 'image_preprocessor.dart';
import 'ocr_service.dart';
import 'ocr_post_processor.dart';

/// ML Kit implementation of OcrService with full PCD preprocessing pipeline.
///
/// Preprocessing (runs in background Isolate):
/// - EXIF orientation fix
/// - Force portrait for KTP/KK
/// - Resize if > 2000px
/// - **ROI crop** (KTP: top 40%, KK: top 35%)
/// - Grayscale (ITU-R BT.601)
/// - Otsu's binary thresholding
///
/// Spatial data: each OCR block includes normalized bounding box coordinates
/// for position-aware extraction (e.g., prefer NIK in top region of KTP).
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

    // Preprocess in background Isolate (EXIF + portrait + resize + ROI crop + grayscale + Otsu)
    final processedPath = await ImagePreprocessor.preprocess(
      inputPath: imageFile.path,
      documentType: documentType,
      enableBinarization: documentType != DocumentType.general,
    );
    final processedFile = File(processedPath);

    final recognizedText = await _recognizeWithBlocks(processedFile);

    // Correct common OCR mistakes
    final correctedFullText = OcrPostProcessor.correctOcrText(recognizedText.text);

    // Get image dimensions for coordinate normalization
    final imageBytes = processedFile.readAsBytesSync();
    final decoded = img.decodeImage(imageBytes);
    final imgW = decoded?.width.toDouble() ?? 1.0;
    final imgH = decoded?.height.toDouble() ?? 1.0;

    // Build OcrBlock list with spatial data + corrected text
    final blocks = <OcrBlock>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final correctedLine = OcrPostProcessor.correctOcrText(line.text);
        final bb = line.boundingBox;
        if (bb != null) {
          blocks.add(OcrBlock(
            text: correctedLine,
            left: bb.left / imgW,
            top: bb.top / imgH,
            right: bb.right / imgW,
            bottom: bb.bottom / imgH,
            confidence: line.confidence,
          ));
        } else {
          blocks.add(OcrBlock(text: correctedLine));
        }
      }
    }

    print('Text length: ${correctedFullText.length}, blocks: ${blocks.length}');
    print('=== OCR END ===\n');

    return OcrResult(fullText: correctedFullText, blocks: blocks);
  }

  Future<RecognizedText> _recognizeWithBlocks(File file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    return await recognizer.processImage(inputImage);
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}
