import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/status_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/rw/kegiatan/kegiatan_rw_viewmodel.dart';

class DetailKegiatanModal extends StatefulWidget {
  final Kegiatan kegiatan;
  final bool readonly;

  const DetailKegiatanModal({
    super.key,
    required this.kegiatan,
    required this.readonly,
  });

  @override
  State<DetailKegiatanModal> createState() =>
      _DetailKegiatanModalState();
}

class _DetailKegiatanModalState
    extends State<DetailKegiatanModal> {
  late TextEditingController namaController;
  late TextEditingController deskripsiController;

  late DateTime tanggalMulai;
  DateTime? tanggalSelesai;

  @override
  void initState() {
    super.initState();

    namaController =
        TextEditingController(text: widget.kegiatan.nama);

    deskripsiController = TextEditingController(
      text: widget.kegiatan.deskripsi ?? "",
    );

    tanggalMulai = widget.kegiatan.tanggalMulai;

    tanggalSelesai = widget.kegiatan.tanggalSelesai;
  }

  @override
  void dispose() {
    namaController.dispose();
    deskripsiController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KegiatanRwViewModel>();

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

          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Detail Kegiatan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),

                _statusBadge(),
              ],
            ),

            const SizedBox(height: 24),

            _textField(
              label: "Nama Kegiatan",
              controller: namaController,
              readonly: widget.readonly,
            ),

            const SizedBox(height: 16),

            _textField(
              label: "Deskripsi Kegiatan",
              controller: deskripsiController,
              readonly: widget.readonly,
              maxLines: 5,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _dateField(
                    label: "Tanggal Mulai",
                    value: _formatDate(tanggalMulai),
                    readonly: widget.readonly,

                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tanggalMulai,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );

                      if (picked != null) {
                        setState(() {
                          tanggalMulai = picked;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _dateField(
                    label: "Tanggal Selesai",
                    value: tanggalSelesai != null
                        ? _formatDate(tanggalSelesai!)
                        : "-",

                    readonly: widget.readonly,

                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            tanggalSelesai ?? tanggalMulai,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );

                      if (picked != null) {
                        setState(() {
                          tanggalSelesai = picked;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Dokumen Pendukung Kegiatan",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            _documentBox(
              context,
              vm,
              widget.kegiatan.docReferensi,
            ),

            const SizedBox(height: 24),

            const Text(
              "Foto Pendukung",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            _imageBox(
              context,
              vm,
              widget.kegiatan.imgReferensi,
            ),

            const SizedBox(height: 32),

            if (!widget.readonly)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },

                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorsUtils.red,

                        side: BorderSide(
                          color: ColorsUtils.red.withOpacity(0.4),
                        ),

                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),

                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: vm.isUploading
                          ? null
                          : () async {
                              vm.updateKegiatan(
                                id: widget.kegiatan.id!,
                                nama: namaController.text,
                                deskripsi:
                                    deskripsiController.text,
                                tanggalMulai: tanggalMulai,
                                tanggalSelesai:
                                    tanggalSelesai,
                              );

                              await vm.uploadDummyBukti(
                                widget.kegiatan.id!,
                              );

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            ColorsUtils.green,

                        foregroundColor: Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),

                      child: vm.isUploading
                          ? const SizedBox(
                              height: 18,
                              width: 18,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    ColorsUtils.white,
                              ),
                            )
                          : const Text("Simpan"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required bool readonly,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          readOnly: readonly,
          maxLines: maxLines,

          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required bool readonly,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: readonly ? null : onTap,

          child: AbsorbPointer(
            child: TextFormField(
              controller:
                  TextEditingController(text: value),

              decoration: InputDecoration(
                suffixIcon:
                    const Icon(Icons.calendar_today),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _documentBox(
    BuildContext context,
    KegiatanRwViewModel vm,
    String? fileName,
  ) {
    final currentFile =
        vm.dokumenFile?.path.split("/").last ??
            fileName ??
            "Belum ada dokumen";

    return GestureDetector(
      onTap:
          widget.readonly ? null : vm.pickDokumenFile,

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          border: Border.all(color: ColorsUtils.gray),
          borderRadius: BorderRadius.circular(14),
        ),

        child: Row(
          children: [
            const Icon(Icons.description_outlined),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                currentFile,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            if (!widget.readonly)
              const Icon(Icons.upload_file_rounded),
          ],
        ),
      ),
    );
  }

  Widget _imageBox(
    BuildContext context,
    KegiatanRwViewModel vm,
    String? imageName,
  ) {
    return GestureDetector(
      onTap:
          widget.readonly ? null : vm.pickBuktiImage,

      child: Container(
        width: double.infinity,
        height: 180,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),

          border: Border.all(
            color: ColorsUtils.gray,
          ),
        ),

        child: vm.buktiImage != null
            ? ClipRRect(
                borderRadius:
                    BorderRadius.circular(14),

                child: Image.file(
                  File(vm.buktiImage!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  const Icon(
                    Icons.image_outlined,
                    size: 42,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    imageName ??
                        "Belum ada foto kegiatan",

                    textAlign: TextAlign.center,
                  ),

                  if (!widget.readonly) ...[
                    const SizedBox(height: 10),

                    const Text(
                      "Tap untuk upload foto",
                      style: TextStyle(
                        fontSize: 12,
                        color: ColorsUtils.gray,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _statusBadge() {
    final ui = widget.kegiatan.status.ui;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: ui.color.withOpacity(0.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        ui.label,

        style: TextStyle(
          color: ui.color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}