import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/ocr/ktp_parser_helper.dart';
import '../../services/ocr/mlkit_ocr_service.dart';
import '../../services/ocr/ocr_service.dart';

/// State management for KTP scanning feature
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

  /// Open ML Kit Document Scanner
  Future<void> scanDocument() async {
    try {
      _isScanning = true;
      _errorMessage = null;
      _parseResult = null;
      notifyListeners();

      final options = DocumentScannerOptions(
        documentFormats: {DocumentFormat.jpeg},
        mode: ScannerMode.filter,
        pageLimit: 1,
        isGalleryImport: true,
      );

      final scanner = DocumentScanner(options: options);
      final result = await scanner.scanDocument();
      scanner.close();

      final images = result.images;
      if (images == null || images.isEmpty) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      _scannedImage = File(images.first);
      notifyListeners();

      await _performOcr();
    } catch (e) {
      _errorMessage =
          'Gagal memindai: ${e.toString().replaceAll("Exception: ", "")}';
      _parseResult = null;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    try {
      _isScanning = true;
      _errorMessage = null;
      _parseResult = null;
      notifyListeners();

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (picked == null) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      _scannedImage = File(picked.path);
      notifyListeners();

      await _performOcr();
    } catch (e) {
      _errorMessage =
          'Gagal memindai: ${e.toString().replaceAll("Exception: ", "")}';
      _parseResult = null;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// Perform OCR
  Future<void> _performOcr() async {
    final ocrResult = await _ocrService
        .recognizeText(_scannedImage!, documentType: DocumentType.ktp)
        .timeout(const Duration(seconds: 30), onTimeout: () {
      throw Exception('OCR timeout - coba foto lebih kecil');
    });

    _parseResult = KtpParserHelper.parse(ocrResult);

    if (!_parseResult!.hasAnyData) {
      _errorMessage =
          'Tidak dapat membaca data KTP. Coba scan lebih jelas.';
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
