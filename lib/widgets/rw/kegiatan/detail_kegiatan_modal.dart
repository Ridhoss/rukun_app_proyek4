import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';

class DetailKegiatanModal extends StatelessWidget {
  final Kegiatan kegiatan;
  final bool readonly;

  const DetailKegiatanModal({
    super.key,
    required this.kegiatan,
    required this.readonly,
  });

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),

                _statusBadge(),
              ],
            ),

            const SizedBox(height: 24),

            _field("Nama Kegiatan", kegiatan.nama),

            const SizedBox(height: 16),

            _field(
              "Deskripsi Kegiatan",
              kegiatan.deskripsi ?? "-",
              maxLines: 5,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _field("Tanggal Mulai", _date(kegiatan.tanggalMulai)),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _field(
                    "Tanggal Selesai",
                    kegiatan.tanggalSelesai != null
                        ? _date(kegiatan.tanggalSelesai!)
                        : "-",
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

            _uploadBox(kegiatan.docReferensi ?? "Belum ada dokumen"),

            const SizedBox(height: 24),

            const Text(
              "Foto Pendukung",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            _uploadBox(kegiatan.imgReferensi ?? "Belum ada foto kegiatan"),

            const SizedBox(height: 32),

            if (!readonly)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("Simpan"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),

        const SizedBox(height: 8),

        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Text(value, maxLines: maxLines),
        ),
      ],
    );
  }

  Widget _uploadBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        children: [
          const Icon(Icons.upload_file_outlined),

          const SizedBox(height: 10),

          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),

      child: const Text(
        "Dibuat",
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _date(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
