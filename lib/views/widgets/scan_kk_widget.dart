import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors_utils.dart';
import '../../viewmodels/scan_kk_viewmodel.dart';

/// Callback when scan result is confirmed
typedef OnScanConfirmed = void Function({
  String? noKK,
  String? alamat,
  String? kodePos,
  File? fotoKK,
});

/// Widget for scanning KK with camera or gallery
class ScanKKWidget extends StatelessWidget {
  final OnScanConfirmed onConfirmed;

  const ScanKKWidget({super.key, required this.onConfirmed});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanKKViewModel(),
      child: _ScanKKView(onConfirmed: onConfirmed),
    );
  }
}

class _ScanKKView extends StatelessWidget {
  final OnScanConfirmed onConfirmed;

  const _ScanKKView({required this.onConfirmed});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScanKKViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scan buttons
        _buildScanButtons(context, vm),

        // Loading indicator
        if (vm.isScanning) ...[
          const SizedBox(height: 16),
          _buildLoadingIndicator(),
        ],

        // Error message
        if (vm.errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorMessage(vm.errorMessage!),
        ],

        // Scan results
        if (vm.parseResult != null && vm.parseResult!.hasAnyData) ...[
          const SizedBox(height: 16),
          _buildScanResults(context, vm),
        ],
      ],
    );
  }

  Widget _buildScanButtons(BuildContext context, ScanKKViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: vm.isScanning ? null : () => vm.scanWithCamera(),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Foto KK'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: ColorsUtils.b500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: vm.isScanning ? null : () => vm.scanFromGallery(),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Dari Galeri'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: ColorsUtils.b500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsUtils.b50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorsUtils.b500),
          ),
          SizedBox(height: 12),
          Text(
            'Memindai Kartu Keluarga...',
            style: TextStyle(
              color: ColorsUtils.b500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanResults(BuildContext context, ScanKKViewModel vm) {
    final result = vm.parseResult!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Data KK Terdeteksi',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(result.confidence * 100).round()}% akurasi',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Results
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.hasNoKK) ...[
                  _buildResultField(
                    label: 'No KK',
                    value: result.noKK!,
                    icon: Icons.credit_card,
                    isValid: true,
                  ),
                  const SizedBox(height: 8),
                ],
                if (result.hasAlamat) ...[
                  _buildResultField(
                    label: 'Alamat',
                    value: result.alamat!,
                    icon: Icons.location_on,
                    isValid: true,
                  ),
                  const SizedBox(height: 8),
                ],
                if (result.hasKodePos) ...[
                  _buildResultField(
                    label: 'Kode Pos',
                    value: result.kodePos!,
                    icon: Icons.markunread_mailbox,
                    isValid: true,
                  ),
                ],
              ],
            ),
          ),

          // Preview image
          if (vm.scannedImage != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  vm.scannedImage!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      vm.clearResults();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Scan Ulang'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirmed(
                        noKK: result.noKK,
                        alamat: result.alamat,
                        kodePos: result.kodePos,
                        fotoKK: vm.scannedImage,
                      );
                      vm.clearResults();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsUtils.b500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Gunakan Data'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultField({
    required String label,
    required String value,
    required IconData icon,
    required bool isValid,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isValid ? Colors.green.shade600 : Colors.orange.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isValid ? Colors.green.shade800 : Colors.orange.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
