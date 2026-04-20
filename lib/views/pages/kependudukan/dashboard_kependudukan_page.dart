import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/routes/app_routes.dart';
import 'package:rukun_app_proyek4/services/warga_service.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

class DashboardKependudukanPage extends StatelessWidget {
  const DashboardKependudukanPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data murni untuk kebutuhan FE
    final List<KKModel> dummyKKList = [
      KKModel(id: 'kk-001', noKK: '3273012345670001', rtId: 1, address: 'Jl. Merdeka No. 10, RT 001/RW 005'),
      KKModel(id: 'kk-002', noKK: '3273012345670002', rtId: 1, address: 'Jl. Merdeka No. 12, RT 001/RW 005'),
      KKModel(id: 'kk-003', noKK: '3273012345670003', rtId: 1, address: 'Jl. Merdeka No. 15A, RT 001/RW 005'),
    ];

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 20),
            const Text(
              'Daftar Kartu Keluarga',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColorsUtils.black800),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: dummyKKList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final kk = dummyKKList[index];
                  return _buildKKCard(context, kk);
                },
              ),
            ),
          ],
        ),
      ),
      // Tombol untuk menambah KK Baru
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorsUtils.b500,
        child: const Icon(Icons.add, color: ColorsUtils.white),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addKK);
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wilayah Aktif', style: TextStyle(fontSize: 12, color: ColorsUtils.gray)),
                SizedBox(height: 4),
                Text('RT 001 / RW 005', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColorsUtils.b400)),
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
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: ColorsUtils.black800),
                ),
                const SizedBox(height: 4),
                Text(
                  kk.address,
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