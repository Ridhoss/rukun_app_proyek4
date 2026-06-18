import 'dart:io';

/// Document type for OCR preprocessing
///
/// Each type has different ROI cropping behavior:
/// - kk:   crop top 35% (header only: No KK, Alamat, Kode Pos)
/// - ktp:  crop top 40% (NIK region: below header, NIK, Nama, TTL)
/// - general: no crop (default)
enum DocumentType { ktp, kk, general }

/// Result of OCR text recognition
class OcrResult {
  final String fullText;
  final List<OcrBlock> blocks;

  OcrResult({required this.fullText, required this.blocks});

  /// Get all blocks whose center-Y falls within [topRatio] of image height.
  /// E.g. topRatio=0.4 returns blocks in the top 40% of the image.
  List<OcrBlock> blocksInTopRegion(double topRatio) {
    return blocks.where((b) {
      if (b.centerY == null) return false;
      return b.centerY! <= topRatio;
    }).toList();
  }

  /// Get text from blocks in the top [topRatio] region.
  String textInTopRegion(double topRatio) {
    return blocksInTopRegion(topRatio).map((b) => b.text).join('\n');
  }
}

/// A block of recognized text with spatial bounding box.
///
/// Coordinates are normalized to [0.0, 1.0] relative to image dimensions:
/// - left/top/right/bottom are fractions of image width/height
/// - centerY is the vertical center of the block (0.0 = top, 1.0 = bottom)
class OcrBlock {
  final String text;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? confidence;

  OcrBlock({
    required this.text,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.confidence,
  });

  /// Vertical center of the block (0.0 = top, 1.0 = bottom)
  double? get centerY =>
      top != null && bottom != null ? (top! + bottom!) / 2 : null;

  /// Horizontal center of the block (0.0 = left, 1.0 = right)
  double? get centerX =>
      left != null && right != null ? (left! + right!) / 2 : null;

  /// Height of the block as fraction of image height
  double? get height => top != null && bottom != null ? bottom! - top! : null;

  /// Width of the block as fraction of image width
  double? get width => left != null && right != null ? right! - left! : null;
}

/// Abstract interface for OCR services
abstract class OcrService {
  /// Recognize text from an image file (whole image OCR)
  ///
  /// [documentType] controls preprocessing behavior:
  /// - DocumentType.kk: crops top 35% to focus on header
  /// - DocumentType.ktp: crops top 40% to focus on NIK area
  /// - DocumentType.general: no cropping
  Future<OcrResult> recognizeText(File imageFile,
      {DocumentType documentType = DocumentType.general});

  /// Dispose resources
  void dispose();
}
