import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/status_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/rw/surat/surat_rw_viewmodel.dart';
import 'package:rukun_app_proyek4/widgets/rw/surat/disetujui/tindak_lanjut_modal.dart';

class RwSuratPage extends StatefulWidget {
  const RwSuratPage({super.key});

  @override
  State<RwSuratPage> createState() => _RwSuratPageState();
}

class _RwSuratPageState extends State<RwSuratPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SuratRwViewModel>().fetchSurat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nama = context.watch<AuthViewModel>().currentUser?.warga?.nama ?? "-";

    return Scaffold(
      backgroundColor: ColorsUtils.lightgray,

      appBar: AppBarUtils.buildAppBar(
        context: context,
        title: "Approved Surat",
        subtitle: "Surat dari RT untuk ditindaklanjuti RW",
        name: nama,
        showAvatar: false,
        showGreeting: false,
        showName: false,
      ),

      body: Consumer<SuratRwViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: vm.refresh,

            child: Column(
              children: [
                _buildSummary(vm),

                _buildFilter(vm),

                _buildSearch(vm),

                const SizedBox(height: 8),

                Expanded(child: _buildList(vm)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(SuratRwViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              total: vm.totalDisetujui,
              title: "Ditindaklajuti",
              color: ColorsUtils.b300,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _summaryCard(
              total: vm.totalSelesai,
              title: "Selesai",
              color: ColorsUtils.g100,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _summaryCard(
              total: vm.totalSemua,
              title: "Total",
              color: ColorsUtils.o100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required int total,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        color: ColorsUtils.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: ColorsUtils.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Text(
            "$total",

            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,

            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(SuratRwViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,

        child: Row(
          children: [
            _filterChip(vm, "Semua", SuratRwFilterStatus.semua),

            _filterChip(vm, "Disetujui", SuratRwFilterStatus.disetujui),

            _filterChip(vm, "Selesai", SuratRwFilterStatus.selesai),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
    SuratRwViewModel vm,
    String label,
    SuratRwFilterStatus status,
  ) {
    final selected = vm.selectedStatus == status;

    return GestureDetector(
      onTap: () => vm.setStatus(status),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        decoration: BoxDecoration(
          color: selected ? ColorsUtils.b300 : ColorsUtils.white,

          borderRadius: BorderRadius.circular(30),

          border: Border.all(
            color: selected ? ColorsUtils.b300 : ColorsUtils.lightgray,
          ),
        ),

        child: Text(
          label,

          style: TextStyle(
            color: selected ? ColorsUtils.white : ColorsUtils.black,

            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearch(SuratRwViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: TextField(
        onChanged: vm.setSearch,

        decoration: InputDecoration(
          hintText: "Cari surat atau warga...",

          prefixIcon: const Icon(Icons.search),

          filled: true,
          fillColor: ColorsUtils.white,

          contentPadding: const EdgeInsets.symmetric(vertical: 0),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildList(SuratRwViewModel vm) {
    if (vm.data.isEmpty) {
      return const Center(child: Text("Tidak ada surat"));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
      itemCount: vm.data.length,
      itemBuilder: (context, index) {
        final surat = vm.data[index];
        return _suratCard(vm, surat);
      },
    );
  }

  Widget _suratCard(SuratRwViewModel vm, PengajuanSurat surat) {
    final status = surat.status.ui;
    final namaWarga = vm.getNamaWarga(surat.wargaId ?? 0);
    final avatar = vm.getAvatarInitial(surat.wargaId ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: ColorsUtils.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: ColorsUtils.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: ColorsUtils.b300,

                child: Text(
                  avatar,

                  style: const TextStyle(
                    color: ColorsUtils.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      namaWarga,

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      surat.waktuDibuat != null
                          ? _formatDate(surat.waktuDibuat!)
                          : "-",

                      style: TextStyle(fontSize: 12, color: ColorsUtils.gray),
                    ),
                  ],
                ),
              ),

              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 22),
          _detailRow("Keperluan", surat.keperluan),

          const SizedBox(height: 14),
          _detailRow("Keterangan", surat.keterangan),

          if (surat.status == SuratStatus.disetujui) ...[
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,

                    builder: (_) {
                      return TindakLanjutModal();
                    },
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsUtils.b300,
                  foregroundColor: ColorsUtils.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),

                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                child: const Text("Tindak Lanjut"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(dynamic status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        status.label,

        style: TextStyle(
          color: status.color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        SizedBox(
          width: 110,

          child: Text(
            title,

            style: TextStyle(fontSize: 13, color: ColorsUtils.gray),
          ),
        ),

        Expanded(
          child: Text(
            value,

            textAlign: TextAlign.right,

            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
