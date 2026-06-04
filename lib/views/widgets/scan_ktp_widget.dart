import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors_utils.dart';
import '../../viewmodels/scan_ktp_viewmodel.dart';

/// Callback when KTP scan result is confirmed
typedef OnKtpScanConfirmed = void Function({
  String? nik,
  String? nama,
  String? tempatLahir,
  String? tanggalLahir,
  String? jenisKelamin,
  String? alamat,
  String? agama,
  String? statusPerkawinan,
  String? pekerjaan,
  String? kewarganegaraan,
});

/// Widget for scanning KTP with camera or gallery
class ScanKTPWidget extends StatelessWidget {
  final OnKtpScanConfirmed onConfirmed;

  const ScanKTPWidget({super.key, required this.onConfirmed});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanKTPViewModel(),
      child: _ScanKTPView(onConfirmed: onConfirmed),
    );
  }
}

class _ScanKTPView extends StatelessWidget {
  final OnKtpScanConfirmed onConfirmed;

  const _ScanKTPView({required this.onConfirmed});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScanKTPViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildScanButtons(context, vm),
        if (vm.isScanning) ...[
          const SizedBox(height: 16),
          _buildLoadingIndicator(),
        ],
        if (vm.errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorMessage(vm.errorMessage!),
        ],
        if (vm.parseResult != null && vm.parseResult!.hasAnyData) ...[
          const SizedBox(height: 16),
          _buildScanResults(context, vm),
        ],
      ],
    );
  }

  Widget _buildScanButtons(BuildContext context, ScanKTPViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: vm.isScanning ? null : () => vm.scanWithCamera(),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Foto KTP'),
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
            'Memindai KTP...',
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

  Widget _buildScanResults(BuildContext context, ScanKTPViewModel vm) {
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
                  'Data KTP Terdeteksi',
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

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.hasNik) _buildResultField('NIK', result.nik!, Icons.credit_card),
                if (result.hasNama) _buildResultField('Nama', result.nama!, Icons.person),
                if (result.hasTempatLahir || result.hasTanggalLahir)
                  _buildResultField(
                    'TTL',
                    '${result.tempatLahir ?? ""}, ${result.tanggalLahir ?? ""}',
                    Icons.cake,
                  ),
                if (result.hasJenisKelamin) _buildResultField('JK', result.jenisKelamin!, Icons.wc),
                if (result.hasAlamat) _buildResultField('Alamat', result.alamat!, Icons.location_on),
              ],
            ),
          ),

          if (vm.scannedImage != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  vm.scannedImage!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => vm.clearResults(),
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
                        nik: result.nik,
                        nama: result.nama,
                        tempatLahir: result.tempatLahir,
                        tanggalLahir: result.tanggalLahir,
                        jenisKelamin: result.jenisKelamin,
                        alamat: result.alamat,
                        agama: result.agama,
                        statusPerkawinan: result.statusPerkawinan,
                        pekerjaan: result.pekerjaan,
                        kewarganegaraan: result.kewarganegaraan,
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

  Widget _buildResultField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
