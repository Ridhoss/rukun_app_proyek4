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

                _headerKegiatan(context, vm),

                Expanded(
                  child: vm.data.isEmpty
                      ? const Center(child: Text("Belum ada kegiatan"))
                      : ListView.builder(
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

  Widget _headerKegiatan(BuildContext context, KegiatanRwViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),

      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Daftar Kegiatan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          if (vm.selectedLevel == KegiatanLevel.rw)
            ElevatedButton(
              onPressed: () {
                _openCreate(context);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsUtils.lightgray,
                foregroundColor: Colors.black,

                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),

              child: const Text(
                "+ Tambah",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
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

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        padding: const EdgeInsets.symmetric(vertical: 14),

        decoration: BoxDecoration(
          color: selected ? ColorsUtils.b300 : Colors.white,
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

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        margin: const EdgeInsets.only(right: 10),

        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

        decoration: BoxDecoration(
          color: selected ? ColorsUtils.b300 : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
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

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Colors.grey.shade600,
              ),

              const SizedBox(width: 8),

              Text(
                vm.formatTanggalRange(kegiatan),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(kegiatan.deskripsi ?? "-", style: const TextStyle(height: 1.5)),

          const SizedBox(height: 20),

          if (vm.isReadonly(kegiatan)) ...[
            _fullButton(
              label: "Lihat Kegiatan",
              onTap: () {
                _openDetail(context, kegiatan, true);
              },
            ),
          ] else if (vm.canUploadBukti(kegiatan)) ...[
            _fullButton(
              label: "Upload Bukti Kegiatan",
              onTap: () {
                vm.uploadDummyBukti(kegiatan.id!);
              },
            ),
          ] else if (vm.isOngoing(kegiatan)) ...[
            Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(vertical: 14),

              decoration: BoxDecoration(
                color: ColorsUtils.o100.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),

              child: const Center(
                child: Text(
                  "Kegiatan Sedang Berlangsung",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ColorsUtils.o100,
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                if (vm.canCancel(kegiatan))
                  Expanded(
                    child: _outlineButton(
                      label: "Batalkan",
                      color: Colors.red,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const Text("Batalkan Kegiatan"),
                              content: const Text(
                                "Apakah anda yakin ingin membatalkan kegiatan ini?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Tidak"),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Dummy pembatalan kegiatan berhasil",
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text("Ya"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                if (vm.canCancel(kegiatan)) const SizedBox(width: 12),

                Expanded(
                  child: _fullButton(
                    label: vm.canEdit(kegiatan)
                        ? "Edit Kegiatan"
                        : "Lihat Kegiatan",

                    onTap: () {
                      if (vm.canEdit(kegiatan)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Halaman edit kegiatan belum tersedia",
                            ),
                          ),
                        );
                      } else {
                        _openDetail(context, kegiatan, true);
                      }
                    },
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
    Color color = ColorsUtils.b300;
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

  Widget _outlineButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,

      style: OutlinedButton.styleFrom(
        foregroundColor: color,

        side: BorderSide(color: color),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        padding: const EdgeInsets.symmetric(vertical: 14),
      ),

      child: Text(label),
    );
  }

  Widget _fullButton({required String label, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,

      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsUtils.b300,
        foregroundColor: Colors.white,

        elevation: 0,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

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

  void _openCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (_) {
        return const FractionallySizedBox(
          heightFactor: 0.92,

          child: Center(child: Text("Form Tambah Kegiatan")),
        );
      },
    );
  }
}
