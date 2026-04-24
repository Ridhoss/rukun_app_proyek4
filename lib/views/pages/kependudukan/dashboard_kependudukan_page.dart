import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/keluarga.dart';
import 'package:rukun_app_proyek4/routes/app_routes.dart';
import 'package:rukun_app_proyek4/services/warga_service.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/keluarga_vm.dart';
import 'package:provider/provider.dart';

class DashboardKependudukanPage extends StatefulWidget {
  const DashboardKependudukanPage({super.key});

  @override
  State<DashboardKependudukanPage> createState() =>
      _DashboardKependudukanPageState();
}

class _DashboardKependudukanPageState extends State<DashboardKependudukanPage> {

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KeluargaVM>();

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
            // HEADER
            _buildHeaderInfo(vm),

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

            // LIST STATE
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.kkList.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada data KK.',
                        style: TextStyle(color: ColorsUtils.gray),
                      ),
                    )
                  : ListView.separated(
                      itemCount: vm.kkList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final kk = vm.kkList[index];
                        return _buildKKCard(context, kk);
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorsUtils.b500,
        child: const Icon(Icons.add, color: ColorsUtils.white),
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addKK);

          // reload data setelah kembali
          vm.loadKK(vm.currentRtId);
        },
      ),
    );
  }

  Widget _buildHeaderInfo(KeluargaVM vm) {
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
                const SizedBox(height: 4),
                Text(
                  '${vm.currentRtLabel} / RW 005',
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

  Widget _buildKKCard(BuildContext context, Keluarga kk) {
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
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: ColorsUtils.b500),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addKK, arguments: kk);
            },
          ),
        ],
      ),
    );
  }
}
