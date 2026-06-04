import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../services/ocr/ktp_parser_helper.dart';
import '../../services/ocr/mlkit_ocr_service.dart';
import '../../services/ocr/ocr_service.dart';

/// State management for KTP scanning feature - LIGHTWEIGHT VERSION
class ScanKTPViewModel extends ChangeNotifier {
  final OcrService _ocrService;

  ScanKTPViewModel({OcrService? ocrService})
      : _ocrService = ocrService ?? MlkitOcrService();

  bool _isScanning = false;
  String? _errorMessage;
  File? _scannedImage;
  KtpParseResult? _parseResult;

  bool get isScanning => _isScanning;
  String? get errorMessage => _errorMessage;
  File? get scannedImage => _scannedImage;
  KtpParseResult? get parseResult => _parseResult;

  /// Scan with camera
  Future<void> scanWithCamera() async {
    await _scan(ImageSource.camera);
  }

  /// Pick from gallery
  Future<void> scanFromGallery() async {
    await _scan(ImageSource.gallery);
  }

  Future<void> _scan(ImageSource source) async {
    try {
      _isScanning = true;
      _errorMessage = null;
      _parseResult = null;
      notifyListeners();

      // Pick image with lower quality
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (picked == null) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      _scannedImage = File(picked.path);
      
      // Compress image
      final compressedFile = await _compressImage(_scannedImage!);
      if (compressedFile != null) {
        _scannedImage = compressedFile;
      }
      
      notifyListeners();

      // Perform OCR with timeout
      final ocrResult = await _ocrService.recognizeText(_scannedImage!)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('OCR timeout - coba foto lebih kecil');
      });

      // Parse KTP data
      _parseResult = KtpParserHelper.parse(ocrResult);

      if (!_parseResult!.hasAnyData) {
        _errorMessage = 'Tidak dapat membaca data KTP. Coba foto lebih jelas.';
      }
    } catch (e) {
      _errorMessage = 'Gagal memindai: ${e.toString().replaceAll("Exception: ", "")}';
      _parseResult = null;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Compress image to reduce memory usage
  Future<File?> _compressImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      
      if (decoded == null) return null;

      // Resize if too large
      var resized = decoded;
      if (decoded.width > 1200 || decoded.height > 1200) {
        resized = img.copyResize(decoded, width: 1200, height: 1200);
      }

      // Convert to grayscale
      final grayscale = img.grayscale(resized);

      // Save compressed
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File('${tempDir.path}/ktp_compressed.jpg');
      await compressedFile.writeAsBytes(img.encodeJpg(grayscale, quality: 80));
      
      return compressedFile;
    } catch (e) {
      print('Compression failed: $e');
      return null;
    }
  }

  void clearResults() {
    _scannedImage = null;
    _parseResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
