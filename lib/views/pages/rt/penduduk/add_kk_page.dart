import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/views/pages/rt/penduduk/add_warga_page.dart';

class AddKKPage extends StatelessWidget {
  const AddKKPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kk = Keluarga(
      id: 1,
      noKK: "3201010000000001",
      rtId: 1,
      alamat: "Jl. Contoh No. 123, Bandung",
      kodePos: "40535",
    );

    final anggotaList = [
      {
        "nama": "Budi Santoso",
        "nik": "3201010101010001",
        "status": "Kepala Keluarga",
      },
      {"nama": "Siti Aminah", "nik": "3201010101010002", "status": "Istri"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: ColorsUtils.b500,
        foregroundColor: ColorsUtils.white,
        elevation: 0,
        title: const Text(
          'Tambah Kartu Keluarga',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                _buildKKSection(kk),
                const SizedBox(height: 20),
                _buildAnggotaSection(context, anggotaList),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomBar(anggotaList.length),
    );
  }

  Widget _buildKKSection(Keluarga kk) {
    return _buildCard(
      header: _buildSectionHeader('Data Kartu Keluarga', Icons.home_outlined),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('No. Kartu Keluarga', true),
          const SizedBox(height: 6),
          _buildReadOnlyField(kk.noKK),

          const SizedBox(height: 14),
          _buildLabel('RT', true),
          const SizedBox(height: 6),
          _buildReadOnlyField("RT ${kk.rtId}"),

          const SizedBox(height: 14),
          _buildLabel('Alamat Lengkap', true),
          const SizedBox(height: 6),
          _buildReadOnlyField(kk.alamat ?? "-"),
          const SizedBox(height: 14),
          _buildLabel('Kode Pos', true),
          const SizedBox(height: 6),
          _buildReadOnlyField(kk.kodePos ?? "-"),
          const SizedBox(height: 16),

          _buildLabel('Foto Kartu Keluarga', true),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDDE3ED)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                const SizedBox(height: 10),

                const Text(
                  'Upload Foto KK',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),

                const SizedBox(height: 4),

                Text(
                  'Belum ada gambar dipilih',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),

                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () {
                    // dummy dulu (belum pakai image_picker)
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Pilih Gambar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsUtils.b500,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnggotaSection(BuildContext context, List anggotaList) {
    return _buildCard(
      header: _buildSectionHeader(
        'Anggota Keluarga',
        Icons.people_outline,
        trailing: _buildBadge('${anggotaList.length} orang', ColorsUtils.b500),
      ),
      child: Column(
        children: [
          ...anggotaList.map((warga) {
            final isKK = warga["status"] == "Kepala Keluarga";

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isKK ? ColorsUtils.b50 : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isKK ? ColorsUtils.b75 : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 28),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            warga["nama"],
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${warga["nik"]} · ${warga["status"]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWargaPage()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ColorsUtils.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ColorsUtils.b500),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, size: 18, color: ColorsUtils.b500),
                  SizedBox(width: 6),
                  Text(
                    'Tambah Anggota',
                    style: TextStyle(
                      color: ColorsUtils.b500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(int count) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: count > 0 ? Colors.green : ColorsUtils.b500,
            foregroundColor: ColorsUtils.white,
          ),
          child: Text(
            count > 0 ? 'Selesai ($count anggota)' : 'Selesai Tanpa Anggota',
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget header, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          header,
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    );
  }

  Widget _buildLabel(String label, bool required) {
    return Text(label);
  }

  Widget _buildReadOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDE3ED)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(value),
    );
  }
}
