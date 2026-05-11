import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/rt/penduduk/kartukeluarga/detail_kk_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/rt/penduduk/warga/add_warga_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/rt/penduduk/add_warga_page.dart';
import 'package:rukun_app_proyek4/views/pages/rt/penduduk/crudkk/edit_kk_page.dart';
import 'package:rukun_app_proyek4/views/pages/rt/penduduk/detail_warga.dart';

class DetailKKPage extends StatelessWidget {
  final int kkId;

  const DetailKKPage({super.key, required this.kkId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailKKViewModel(
        repo: context.read(),
        wargaRepo: context.read(),
        kkId: kkId,
      )..fetchDetail(),
      child: _DetailKKView(),
    );
  }
}

class _DetailKKView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: ColorsUtils.b500,
        foregroundColor: ColorsUtils.white,
        elevation: 0,
        title: const Text(
          'Detail Kartu Keluarga',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),

      body: Consumer<DetailKKViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.kk == null) {
            return const Center(child: Text("Data KK tidak ditemukan"));
          }

          final kk = vm.kk!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeaderCard(kk),
              const SizedBox(height: 16),
              _buildInfoCard(context, kk, vm),
              const SizedBox(height: 16),
              _buildAnggotaCard(context, vm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(Keluarga kk) {
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
                  // kk.noKK ?? "-",
                  kk.noKK,
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

  Widget _buildInfoCard(BuildContext context, Keluarga kk, DetailKKViewModel vm) {
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

          if ((kk.imgRef ?? '').isNotEmpty)
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

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditKKPage(idKK: kk.id!),
                      ),
                    );

                    if (result == true && context.mounted) {
                      try {
                        await context.read<DetailKKViewModel>().fetchDetail();

                        NotificationUtils.showSuccess(
                          context,
                          "Data KK berhasil diperbarui",
                        );
                      } catch (e) {
                        NotificationUtils.showError(
                          context,
                          "Gagal memuat ulang data KK",
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text("Edit KK"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsUtils.b500,
                    side: const BorderSide(color: ColorsUtils.b500),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: vm.isDeleting
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Hapus KK"),
                              content: const Text(
                                "Apakah Anda yakin ingin menghapus kartu keluarga ini?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text("Batal"),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Hapus"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final success = await vm.deleteKK();

                            if (!context.mounted) return;

                            if (success) {
                              NotificationUtils.showSuccess(
                                context,
                                "Kartu Keluarga berhasil dihapus",
                              );

                              Navigator.pop(context, true);
                            } else {
                              NotificationUtils.showError(
                                context,
                                vm.error ?? "Gagal menghapus KK",
                              );
                            }
                          }
                        },
                  icon: vm.isDeleting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(vm.isDeleting ? "Menghapus..." : "Hapus"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
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

  Widget _buildAnggotaCard(BuildContext context, DetailKKViewModel vm) {
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

          if (vm.isLoadingAnggota)
            const Center(child: CircularProgressIndicator())
          else if (vm.anggotaError != null)
            Text(vm.anggotaError!)
          else if (vm.anggota.isEmpty)
            _buildEmptyState(context, vm)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.anggota.length,
              itemBuilder: (context, i) {
                final warga = vm.anggota[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailWargaPage(warga: warga),
                        ),
                      );
                    },
                    leading: const CircleAvatar(
                      backgroundColor: ColorsUtils.b50,
                      child: Icon(Icons.person, color: ColorsUtils.b500),
                    ),
                    title: Text(warga.nama),
                    subtitle: Text(
                      warga.nik,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => AddWargaViewModel(
                        repo: context.read<WargaRepository>(),
                        kkId: vm.kkId,
                      ),
                      child: const AddWargaPage(),
                    ),
                  ),
                );

                if (result == true) {
                  vm.fetchAnggota();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Tambah Anggota"),
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

  Widget _buildEmptyState(BuildContext context, DetailKKViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsUtils.b50),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: ColorsUtils.b50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group_outlined,
              size: 32,
              color: ColorsUtils.b500,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Belum Ada Anggota",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),

          const SizedBox(height: 4),

          const Text(
            "Tambahkan anggota keluarga untuk mulai mengelola data penduduk.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: ColorsUtils.gray),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider(
                      create: (_) => AddWargaViewModel(
                        repo: context.read<WargaRepository>(),
                        kkId: vm.kkId,
                      ),
                      child: const AddWargaPage(),
                    ),
                  ),
                );

                vm.fetchAnggota();
              },
              icon: const Icon(Icons.add),
              label: const Text("Tambah Anggota"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsUtils.b500,
                foregroundColor: Colors.white,
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
}
