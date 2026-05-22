import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/status_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/rw/surat/surat_rw_viewmodel.dart';

class TindakLanjutModal extends StatelessWidget {
  final PengajuanSurat surat;
  final String namaWarga;
  final bool readOnly;

  const TindakLanjutModal({
    super.key,
    required this.surat,
    required this.namaWarga,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SuratRwViewModel>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),

      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (_) {
                final status = surat.status.ui;

                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Detail Pengajuan Surat",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: status.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: status.color,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),
            _userHeader(vm),

            const SizedBox(height: 24),
            _detail("Keperluan", surat.keperluan),
            _detail("Keterangan", surat.keterangan ?? '-'),

            const SizedBox(height: 10),
            const Text(
              "Informasi Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip("Dibuat", vm.formatDate(surat.waktuDibuat)),
                _infoChip("Diubah", vm.formatDate(surat.waktuDiubah)),
              ],
            ),

            const SizedBox(height: 28),
            const Text(
              "Langkah 1. Unduh Surat",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
            _downloadCard(surat.docRef),

            const SizedBox(height: 28),
            const Text(
              "Langkah 2. Upload Surat Bertanda Tangan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
            _uploadBox(context, vm),

            const SizedBox(height: 24),
            _actionButtons(context, vm, surat),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text("$title: $value", style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _userHeader(SuratRwViewModel vm) {
    return Row(
      children: [
        const CircleAvatar(radius: 22, child: Icon(Icons.person)),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                namaWarga,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Text(
                "Pengaju Surat",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadCard(String? url) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.description),
          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              "Surat Draft RT.pdf",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              // TODO
            },
            child: const Text("Unduh"),
          ),
        ],
      ),
    );
  }

  Widget _uploadBox(BuildContext context, SuratRwViewModel vm) {
    return GestureDetector(
      onTap: vm.pickFile,

      child: Container(
        width: double.infinity,
        height: 120,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_file, size: 36),
            const SizedBox(height: 8),

            Text(
              vm.signedFile == null
                  ? "Upload Surat Signed"
                  : vm.signedFile!.path.split("/").last,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons(
    BuildContext context,
    SuratRwViewModel vm,
    PengajuanSurat surat,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),

            style: OutlinedButton.styleFrom(
              foregroundColor: ColorsUtils.red,

              side: BorderSide(color: ColorsUtils.red.withOpacity(0.4)),

              padding: const EdgeInsets.symmetric(vertical: 14),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            child: const Text(
              "Batal",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: vm.isUploading
                ? null
                : () async {
                    await vm.uploadSurat(id: surat.id!);

                    Navigator.pop(context);
                  },

            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsUtils.green,
              foregroundColor: Colors.white,

              padding: const EdgeInsets.symmetric(vertical: 14),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            child: vm.isUploading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Kirim",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}
