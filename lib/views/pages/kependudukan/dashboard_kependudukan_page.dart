import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/routes/app_routes.dart';
import 'package:rukun_app_proyek4/services/warga_service.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

class DashboardKependudukanPage extends StatefulWidget {
  const DashboardKependudukanPage({super.key});

  @override
  State<DashboardKependudukanPage> createState() =>
      _DashboardKependudukanPageState();
}

class _DashboardKependudukanPageState extends State<DashboardKependudukanPage> {
  final WargaService _service = WargaService();

  Future<List<KKModel>> _loadKK() async {
    return _service.getKKByRT(_service.currentRtId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: ColorsUtils.b500,
        foregroundColor: ColorsUtils.white,
        elevation: 0,
        title: const Text(
          'Dashboard Kependudukan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<KKModel>>(
          future: _loadKK(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final kkList = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(),
                const SizedBox(height: 20),
                const Text(
                  'Daftar Kartu Keluarga',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorsUtils.black800,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: kkList.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada data KK offline di RT aktif.',
                            style: TextStyle(color: ColorsUtils.gray),
                          ),
                        )
                      : ListView.separated(
                          itemCount: kkList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final kk = kkList[index];
                            return _buildKKCard(context, kk);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      // Tombol untuk menambah KK Baru
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorsUtils.b500,
        child: const Icon(Icons.add, color: ColorsUtils.white),
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addKK);
          if (!mounted) return;
          setState(() {});
        },
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: ColorsUtils.b50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_city, color: ColorsUtils.b500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wilayah Aktif',
                  style: TextStyle(fontSize: 12, color: ColorsUtils.gray),
                ),
                SizedBox(height: 4),
                Text(
                  '${_service.currentRtLabel} / RW 005',
                  style: TextStyle(
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

  Widget _buildKKCard(BuildContext context, KKModel kk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, size: 28, color: ColorsUtils.gray),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No. KK: ${kk.noKK}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: ColorsUtils.black800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kk.alamat,
                  style: const TextStyle(fontSize: 12, color: ColorsUtils.gray),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Tombol Edit yang melempar dummy data ke halaman AddKKPage
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: ColorsUtils.b500),
            tooltip: 'Edit Data KK',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addKK, arguments: kk);
            },
          ),
        ],
      ),
    );
  }
}
