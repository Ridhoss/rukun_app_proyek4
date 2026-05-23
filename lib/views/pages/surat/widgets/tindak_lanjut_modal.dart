import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/status_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/surat/surat_list_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/surat/surat_action_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart' as fp;

class TindakLanjutModal extends StatefulWidget {
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
  State<TindakLanjutModal> createState() => _TindakLanjutModalState();
}

class _TindakLanjutModalState extends State<TindakLanjutModal> {
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

  void _showRejectDialog(BuildContext context, SuratActionViewModel actionVm, SuratListViewModel listVm) {
    final TextEditingController alasanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Tolak Pengajuan"),
          content: TextField(
            controller: alasanController,
            decoration: const InputDecoration(
              hintText: "Masukkan alasan penolakan",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ColorsUtils.red),
              onPressed: () async {
                if (alasanController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Alasan wajib diisi")),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final success = await actionVm.tolakSurat(
                  id: widget.surat.id!,
                  catatan: alasanController.text.trim(),
                  listVm: listVm,
                );
                if (success && mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Tolak", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listVm = context.watch<SuratListViewModel>();
    final actionVm = context.watch<SuratActionViewModel>();

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
                _infoChip("Dibuat", listVm.formatDate(widget.surat.waktuDibuat)),
                _infoChip("Diubah", listVm.formatDate(widget.surat.waktuDiubah)),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              "Langkah 1. Unduh Surat Draft RT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _downloadCard(context, widget.surat.docRef),
            if (!widget.readOnly) ...[
              const SizedBox(height: 28),
              const Text(
                "Langkah 2. Upload Surat Bertanda Tangan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _uploadBox(context),
            ],
            const SizedBox(height: 24),
            if (!widget.readOnly) _actionButtons(context, actionVm, listVm, widget.surat),
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
            "Detail Pengajuan Surat",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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

  Widget _downloadCard(BuildContext context, String? url) {
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
          Expanded(
            child: Text(
              url != null ? url.split('/').last : "Draft.pdf",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: url == null
                ? null
                : () async {
                    String finalUrl = url;
                    if (finalUrl.contains("res.cloudinary.com") && !finalUrl.contains("fl_attachment")) {
                      finalUrl = finalUrl.replaceFirst("/upload/", "/upload/fl_attachment/");
                    }
                    final uri = Uri.parse(finalUrl);
                    if (!await launchUrl(uri)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Gagal membuka dokumen")),
                        );
                      }
                    }
                  },
            child: const Text("Unduh"),
          ),
        ],
      ),
    );
  }

  Widget _uploadBox(BuildContext context) {
    return GestureDetector(
      onTap: pickFile,
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
              selectedFile == null
                  ? "Upload Surat Signed"
                  : selectedFile!.path.split("/").last,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons(
    BuildContext context,
    SuratActionViewModel actionVm,
    SuratListViewModel listVm,
    PengajuanSurat surat,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showRejectDialog(context, actionVm, listVm),
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorsUtils.red,
              side: BorderSide(color: ColorsUtils.red.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Tolak",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: actionVm.isUploading
                ? null
                : () async {
                    if (selectedFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Pilih file terlebih dahulu")),
                      );
                      return;
                    }
                    final success = await actionVm.uploadSignedByRw(
                        id: surat.id!, file: selectedFile!, listVm: listVm);
                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsUtils.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: actionVm.isUploading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Kirim & Selesai",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }
}
