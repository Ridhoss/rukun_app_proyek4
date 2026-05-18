import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/rw/kegiatan/kegiatan_rw_viewmodel.dart';
import 'package:rukun_app_proyek4/widgets/rw/kegiatan/detail_kegiatan_modal.dart';

class RwKegiatanPage extends StatelessWidget {
  const RwKegiatanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nama = context.watch<AuthViewModel>().currentUser?.warga?.nama ?? "-";

    return Scaffold(
      backgroundColor: ColorsUtils.lightgray,

      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: nama,
        title: "Detail Kegiatan",
        subtitle: "Buat Kegiatan anda Sekarang",
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),

      body: Consumer<KegiatanRwViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            onRefresh: vm.refresh,

            child: Column(
              children: [
                _summary(vm),

                _levelSwitcher(vm),

                _statusFilter(vm),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.data.length,
                    itemBuilder: (_, i) {
                      final kegiatan = vm.data[i];
                      return _card(context, vm, kegiatan);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summary(KegiatanRwViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Row(
        children: [
          Expanded(child: _summaryCard(vm.totalDibuat, "Dibuat", Colors.blue)),

          const SizedBox(width: 12),

          Expanded(
            child: _summaryCard(vm.totalDibatalkan, "Dibatalkan", Colors.red),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _summaryCard(vm.totalSelesai, "Selesai", Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(int total, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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

          Text(title),
        ],
      ),
    );
  }

  Widget _levelSwitcher(KegiatanRwViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Row(
        children: [
          Expanded(
            child: _levelButton(
              selected: vm.selectedLevel == KegiatanLevel.rw,
              label: "RW",
              onTap: () => vm.setLevel(KegiatanLevel.rw),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: _levelButton(
              selected: vm.selectedLevel == KegiatanLevel.rt,
              label: "RT",
              onTap: () => vm.setLevel(KegiatanLevel.rt),
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelButton({
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),

        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusFilter(KegiatanRwViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,

        child: Row(
          children: [
            _chip(vm, "Semua", KegiatanFilterStatus.semua),
            _chip(vm, "Dibuat", KegiatanFilterStatus.dibuat),
            _chip(vm, "Dibatalkan", KegiatanFilterStatus.dibatalkan),
            _chip(vm, "Selesai", KegiatanFilterStatus.selesai),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    KegiatanRwViewModel vm,
    String label,
    KegiatanFilterStatus status,
  ) {
    final selected = vm.selectedStatus == status;

    return GestureDetector(
      onTap: () => vm.setStatus(status),

      child: Container(
        margin: const EdgeInsets.only(right: 10),

        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    KegiatanRwViewModel vm,
    Kegiatan kegiatan,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  kegiatan.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              _badge(kegiatan.status),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            "${kegiatan.tanggalMulai.day}/${kegiatan.tanggalMulai.month}/${kegiatan.tanggalMulai.year}",
          ),

          const SizedBox(height: 16),

          Text(kegiatan.deskripsi ?? "-", style: const TextStyle(height: 1.5)),

          const SizedBox(height: 20),

          if (vm.isReadonly(kegiatan)) ...[
            _fullButton(
              label: "Lihat Kegiatan",
              onTap: () => _openDetail(context, kegiatan, true),
            ),
          ] else ...[
            Row(
              children: [
                if (vm.canCancel(kegiatan))
                  Expanded(
                    child: _outlineButton(label: "Batalkan", color: Colors.red),
                  ),

                const SizedBox(width: 12),

                Expanded(
                  child: _fullButton(
                    label: vm.canEdit(kegiatan)
                        ? "Edit Kegiatan"
                        : "Lihat Kegiatan",
                    onTap: () =>
                        _openDetail(context, kegiatan, !vm.canEdit(kegiatan)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(KegiatanStatus status) {
    Color color = Colors.blue;
    String label = "Dibuat";

    switch (status) {
      case KegiatanStatus.dibatalkan:
        color = Colors.red;
        label = "Dibatalkan";
        break;

      case KegiatanStatus.selesai:
        color = Colors.green;
        label = "Selesai";
        break;

      default:
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _outlineButton({required String label, required Color color}) {
    return OutlinedButton(
      onPressed: () {},

      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),

      child: Text(label),
    );
  }

  Widget _fullButton({required String label, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,

      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),

      child: Text(label),
    );
  }

  void _openDetail(BuildContext context, Kegiatan kegiatan, bool readonly) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: DetailKegiatanModal(kegiatan: kegiatan, readonly: readonly),
        );
      },
    );
  }
}
