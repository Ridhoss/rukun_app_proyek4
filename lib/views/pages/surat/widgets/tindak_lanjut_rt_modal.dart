import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/status_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/surat/surat_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart' as fp;

class TindakLanjutRtModal extends StatefulWidget {
  final PengajuanSurat surat;
  final String namaWarga;
  final bool readOnly;

  const TindakLanjutRtModal({
    super.key,
    required this.surat,
    required this.namaWarga,
    this.readOnly = false,
  });

  @override
  State<TindakLanjutRtModal> createState() => _TindakLanjutRtModalState();
}

class _TindakLanjutRtModalState extends State<TindakLanjutRtModal> {
  File? selectedFile;

  Future<void> pickFile() async {
    final result = await fp.FilePicker.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    setState(() {
      selectedFile = File(result.files.single.path!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SuratViewModel>();

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
            _header(),

            const SizedBox(height: 24),

            _userHeader(),

            const SizedBox(height: 24),

            _detail("Keperluan", widget.surat.keperluan),

            _detail("Keterangan", widget.surat.keterangan ?? '-'),

            const SizedBox(height: 20),

            const Text(
              "Informasi Pengajuan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,

              children: [
                _infoChip("Dibuat", vm.formatDate(widget.surat.waktuDibuat)),

                _infoChip("Status", widget.surat.status.ui.label),
              ],
            ),

            const SizedBox(height: 28),

            if (!widget.readOnly) ...[
              const Text(
                "Upload Draft Surat",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                "Upload draft surat yang sudah dibuat sesuai keperluan warga.",
                style: TextStyle(fontSize: 12, color: ColorsUtils.gray),
              ),

              const SizedBox(height: 14),

              _uploadBox(context, vm),

              const SizedBox(height: 28),
            ],

            if (widget.surat.docRef != null) ...[
              const SizedBox(height: 24),

              const Text(
                "Dokumen Surat",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              InkWell(
                onTap: () async {
                  final uri = Uri.parse(widget.surat.docRef!);

                  final success = await launchUrl(
                    uri,
                    mode: LaunchMode.inAppBrowserView,
                  );

                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gagal membuka dokumen")),
                    );
                  }
                },

                borderRadius: BorderRadius.circular(14),

                child: Container(
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),

                  child: Row(
                    children: [
                      const Icon(Icons.description),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          widget.surat.docRef!.split('/').last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const Icon(Icons.open_in_new, size: 18),
                    ],
                  ),
                ),
              ),
            ],

            if (!widget.readOnly) _actionButtons(context, vm),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final status = widget.surat.status.ui;

    return Row(
      children: [
        const Expanded(
          child: Text(
            "Tindak Lanjut Surat",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

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
  }

  Widget _userHeader() {
    return Row(
      children: [
        const CircleAvatar(radius: 22, child: Icon(Icons.person)),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                widget.namaWarga,

                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const Text(
                "Warga Pengaju",
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
      padding: const EdgeInsets.only(bottom: 8),

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

  Widget _uploadBox(BuildContext context, SuratViewModel vm) {
    return GestureDetector(
      onTap: pickFile,

      child: Container(
        width: double.infinity,
        height: 130,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: Colors.grey.shade300),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.upload_file, size: 38),

            const SizedBox(height: 10),

            Text(
              selectedFile == null
                  ? "Pilih File Draft Surat"
                  : selectedFile!.path.split("/").last,

              textAlign: TextAlign.center,

              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 6),

            Text(
              "PDF / DOC / DOCX",

              style: TextStyle(fontSize: 11, color: ColorsUtils.gray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons(BuildContext context, SuratViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },

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
                    if (selectedFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Pilih file terlebih dahulu"),
                        ),
                      );
                      return;
                    }

                    final success = await vm.uploadDraftByRt(
                      id: widget.surat.id!,
                      file: selectedFile!,
                    );

                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },

            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsUtils.b300,
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
                    "Kirim ke RW",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}
