import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/status_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/kegiatan/kegiatan_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/kegiatan/widgets/detail_kegiatan_modal.dart';
import 'package:rukun_app_proyek4/views/pages/kegiatan/widgets/tambah_kegiatan_modal.dart';

class KegiatanPage extends StatelessWidget {
  const KegiatanPage({super.key});

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

      body: Consumer<KegiatanViewModel>(
        builder: (context, vm, _) {
          return RefreshIndicator(
            onRefresh: vm.refresh,

            child: Column(
              children: [
                _summary(vm),

                _levelSwitcher(vm),

                _statusFilter(vm),

                _buildSearch(vm),

                const SizedBox(height: 16),
                _headerKegiatan(context, vm),

                Expanded(
                  child: vm.data.isEmpty
                      ? const Center(child: Text("Belum ada kegiatan"))
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),

                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),

                          itemCount: vm.data.length,

                          itemBuilder: (_, i) {
                            final kegiatan = vm.data[i];

                            return Column(
                              children: [
                                _card(context, vm, kegiatan),

                                if (i == vm.data.length - 1)
                                  const SizedBox(height: 40),
                              ],
                            );
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

  Widget _buildSearch(KegiatanViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: TextField(
        onChanged: vm.setSearch,

        decoration: InputDecoration(
          hintText: "Cari kegiatan...",

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

  Widget _headerKegiatan(BuildContext context, KegiatanViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),

      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Daftar Kegiatan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          if (vm.selectedLevel == KegiatanLevel.rw)
            ElevatedButton(
              onPressed: () {
                _openCreate(context);
              },

              style:
                  ElevatedButton.styleFrom(
                    backgroundColor: ColorsUtils.lightgray,
                    foregroundColor: ColorsUtils.black,

                    elevation: 0,

                    shadowColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ).copyWith(
                    overlayColor: WidgetStatePropertyAll(Colors.transparent),
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

  Widget _summary(KegiatanViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              total: vm.totalDibuat,
              title: "Dibuat",
              color: ColorsUtils.skyblue,
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
              total: vm.totalDibatalkan,
              title: "Dibatalkan",
              color: ColorsUtils.red,
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
      padding: const EdgeInsets.symmetric(vertical: 10),

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

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,

            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _levelSwitcher(KegiatanViewModel vm) {
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
          color: selected ? ColorsUtils.b300 : ColorsUtils.white,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? ColorsUtils.white : ColorsUtils.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusFilter(KegiatanViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

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
    KegiatanViewModel vm,
    String label,
    KegiatanFilterStatus status,
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

          boxShadow: [
            BoxShadow(
              color: ColorsUtils.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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

  Widget _card(
    BuildContext context,
    KegiatanViewModel vm,
    Kegiatan kegiatan,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: ColorsUtils.black.withOpacity(0.03),
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
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(width: 12),
              _badge(kegiatan.status),
            ],
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: ColorsUtils.slateGray,
              ),

              const SizedBox(width: 8),
              Text(
                vm.formatTanggalRange(kegiatan),
                style: TextStyle(
                  color: ColorsUtils.slateGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(kegiatan.deskripsi ?? "-", style: const TextStyle(height: 1.5)),

          const SizedBox(height: 20),

          if (vm.isReadonly(kegiatan)) ...[
            Row(
              children: [
                Expanded(
                  child: _fullButton(
                    label: "Lihat Kegiatan",
                    onTap: () {
                      _openDetail(context, kegiatan, true);
                    },
                  ),
                ),
              ],
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
                      _openDetail(context, kegiatan, !vm.canEdit(kegiatan));
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
    final ui = status.ui;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      decoration: BoxDecoration(
        color: ui.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        ui.label,
        style: TextStyle(color: ui.color, fontWeight: FontWeight.bold),
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
          child: TambahKegiatanModal(),
        );
      },
    );
  }
}
