import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors_utils.dart';
import '../../viewmodels/scan_kk_viewmodel.dart';

/// Callback when scan result is confirmed — all extracted KK fields.
typedef OnScanConfirmed = void Function({
  String? noKK,
  String? namaKepalaKeluarga,
  String? alamat,
  String? rtRw,
  String? kelDesa,
  String? kecamatan,
  String? kota,
  String? kodePos,
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
        // Guideline tip
        _buildGuidelineTip(),

        const SizedBox(height: 12),

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

  Widget _buildGuidelineTip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Arahkan kamera ke seluruh halaman KK. Scanner akan otomatis mendeteksi tepi dokumen dan memperbaiki perspektif.',
              style: TextStyle(
                color: Colors.amber.shade800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButtons(BuildContext context, ScanKKViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: vm.isScanning ? null : () => vm.scanDocument(),
            icon: const Icon(Icons.document_scanner_outlined),
            label: const Text('Scan KK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsUtils.b500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: vm.isScanning ? null : () => vm.pickFromGallery(),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Galeri'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
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
                  'KK Terdeteksi',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Extracted fields
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _fieldRow(Icons.credit_card, 'No KK', result.noKK),
                if (result.hasNamaKepala) ...[
                  const SizedBox(height: 8),
                  _fieldRow(Icons.person, 'Kepala Keluarga', result.namaKepalaKeluarga),
                ],
                if (result.alamat != null) ...[
                  const SizedBox(height: 8),
                  _fieldRow(Icons.home, 'Alamat', result.alamat),
                ],
                if (result.kodePos != null) ...[
                  const SizedBox(height: 8),
                  _fieldRow(Icons.location_on, 'Kode Pos', result.kodePos),
                ],
              ],
            ),
          ),

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
                        namaKepalaKeluarga: result.namaKepalaKeluarga,
                        alamat: result.alamat,
                        rtRw: result.rtRw,
                        kelDesa: result.kelDesa,
                        kecamatan: result.kecamatan,
                        kota: result.kota,
                        kodePos: result.kodePos,
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

  Widget _fieldRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.green.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text(
                value ?? '-',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
