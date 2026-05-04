import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/views/pages/rt/penduduk/add_warga_page.dart';

class DetailKKPage extends StatelessWidget {
  final Keluarga kk;

  const DetailKKPage({super.key, required this.kk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: ColorsUtils.b500,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Detail Kartu Keluarga",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(),

          const SizedBox(height: 16),

          _buildInfoCard(context),

          const SizedBox(height: 16),

          _buildAnggotaCard(context),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: ColorsUtils.b50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.credit_card, color: ColorsUtils.b500),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kartu Keluarga",
                  style: TextStyle(fontSize: 12, color: ColorsUtils.gray),
                ),
                const SizedBox(height: 4),
                Text(
                  kk.noKK ?? "-",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorsUtils.b400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informasi KK",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: ColorsUtils.black800,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoItem(Icons.home_outlined, "Alamat", kk.alamat ?? "-"),
          _buildInfoItem(
            Icons.markunread_mailbox_outlined,
            "Kode Pos",
            kk.kodePos ?? "-",
          ),

          const SizedBox(height: 16),

          if (kk.imgRef != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showImagePreview(context, kk.imgRef!);
                },
                icon: const Icon(Icons.image_outlined),
                label: const Text("Lihat Foto KK"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorsUtils.b500,
                  side: BorderSide(color: ColorsUtils.b500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ColorsUtils.gray),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: ColorsUtils.gray),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnggotaCard(BuildContext context) {
    final anggota = ["Budi", "Siti", "Andi"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Anggota Keluarga",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),

          const SizedBox(height: 12),

          if (anggota.isEmpty)
            const Text("Belum ada anggota")
          else
            Column(
              children: anggota.map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: ColorsUtils.b50,
                      child: Icon(Icons.person, color: ColorsUtils.b500),
                    ),
                    title: Text(e),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddWargaPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Tambah Anggota"),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorsUtils.b500,
                side: BorderSide(color: ColorsUtils.b500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: InteractiveViewer(
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
