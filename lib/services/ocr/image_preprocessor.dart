import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'ocr_service.dart';

/// Image preprocessing pipeline adapted from PCD-B4.
///
/// Runs in a background Isolate via compute() to avoid UI jank.
/// Pipeline: decode → EXIF fix → portrait → resize → grayscale → Otsu binarize → save
class ImagePreprocessor {
  /// Preprocess image for OCR in a background Isolate.
  ///
  /// Returns the path to the processed JPEG file.
  static Future<String> preprocess({
    required String inputPath,
    required DocumentType documentType,
    bool enableBinarization = true,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}${Platform.pathSeparator}${documentType.name}_ocr.jpg';

    final result = await compute(_runPipeline, {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'documentType': documentType.name,
      'enableBinarization': enableBinarization.toString(),
    });

    return result;
  }
}

/// Top-level function for compute() — runs in a separate Isolate.
String _runPipeline(Map<String, String> params) {
  final sw = Stopwatch()..start();

  final inputPath = params['inputPath']!;
  final outputPath = params['outputPath']!;
  final documentType = params['documentType']!;
  final enableBinarization = params['enableBinarization'] == 'true';

  final bytes = File(inputPath).readAsBytesSync();
  var decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Gagal decode gambar');

  // Step 1: Fix EXIF orientation
  decoded = img.bakeOrientation(decoded);

  // Step 2: Force portrait for KTP/KK
  if (decoded.width > decoded.height) {
    decoded = img.copyRotate(decoded, angle: 90);
  }

  // Step 3: Resize if too large (keep quality for ML Kit)
  if (decoded.width > 2000) {
    decoded = img.copyResize(decoded, width: 2000);
  }

  // Step 4: Grayscale + Otsu binarization (from PCD-B4)
  if (enableBinarization && documentType != 'general') {
    decoded = _applyBinarization(decoded);
  }

  // Step 5: Save as high quality JPEG
  File(outputPath)
      .writeAsBytesSync(img.encodeJpg(decoded, quality: 95));

  sw.stop();
  debugPrint(
      'Preprocessed [$documentType]: ${decoded.width}x${decoded.height} '
      'in ${sw.elapsedMilliseconds}ms');

  return outputPath;
}

/// Apply Grayscale (ITU-R BT.601) + Otsu's binary thresholding.
///
/// Converts image to grayscale, then finds optimal threshold via Otsu's method,
/// and converts each pixel to pure black or white.
/// This dramatically improves OCR on documents with uneven lighting or colored backgrounds.
img.Image _applyBinarization(img.Image original) {
  // Step A: Grayscale (ITU-R BT.601)
  final gray = img.Image(width: original.width, height: original.height);
  for (int y = 0; y < original.height; y++) {
    for (int x = 0; x < original.width; x++) {
      final px = original.getPixel(x, y);
      final g = (0.299 * px.r.toInt() +
              0.587 * px.g.toInt() +
              0.114 * px.b.toInt())
          .round()
          .clamp(0, 255);
      gray.setPixelRgb(x, y, g, g, g);
    }
  }

  // Step B: Otsu's threshold — find optimal cutoff
  final threshold = _computeOtsu(gray);

  // Step C: Binary threshold — each pixel becomes 0 or 255
  final binary = gray.clone();
  for (int y = 0; y < binary.height; y++) {
    for (int x = 0; x < binary.width; x++) {
      final v = binary.getPixel(x, y).r.toInt();
      final c = v > threshold ? 255 : 0;
      binary.setPixelRgb(x, y, c, c, c);
    }
  }

  return binary;
}

/// Otsu's Method — finds optimal threshold that maximizes inter-class variance.
///
/// Algorithm:
/// 1. Build 256-bin histogram of grayscale values
/// 2. For each candidate threshold t (0-255):
///    - Split pixels into background (<=t) and foreground (>t)
///    - Calculate inter-class variance: wBg * wFg * (meanBg - meanFg)^2
/// 3. Return t that maximizes the variance
int _computeOtsu(img.Image grayscale) {
  // Build histogram
  final hist = List<int>.filled(256, 0);
  for (int y = 0; y < grayscale.height; y++) {
    for (int x = 0; x < grayscale.width; x++) {
      hist[grayscale.getPixel(x, y).r.toInt()]++;
    }
  }

  final total = grayscale.width * grayscale.height;
  double sumAll = 0;
  for (int i = 0; i < 256; i++) {
    sumAll += i * hist[i];
  }

  double sumBg = 0;
  int wBg = 0;
  double maxVariance = 0;
  int bestT = 0;

  for (int t = 0; t < 256; t++) {
    wBg += hist[t];
    if (wBg == 0) continue;
    final wFg = total - wBg;
    if (wFg == 0) break;

    sumBg += t * hist[t];
    final meanBg = sumBg / wBg;
    final meanFg = (sumAll - sumBg) / wFg;
    final diff = meanBg - meanFg;
    final variance = wBg.toDouble() * wFg.toDouble() * diff * diff;

    if (variance > maxVariance) {
      maxVariance = variance;
      bestT = t;
    }
  }

  return bestT;
}
