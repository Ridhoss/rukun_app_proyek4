import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/kartukeluarga/add_kk_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/kk_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/rt/penduduk/add_kk_page.dart';

class RtPendudukPage extends StatefulWidget {
  final User user;

  const RtPendudukPage({super.key, required this.user});

  @override
  State<RtPendudukPage> createState() => _RtPendudukPageState();
}

class _RtPendudukPageState extends State<RtPendudukPage> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) return;
    _isInitialized = true;

    final rtId = widget.user.rt?.id;
    if (rtId == null) return;

    context.read<KeluargaVM>().init(rtId);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    final rt = user.rt?.noRt ?? '-';
    final rw = user.rw?.noRw ?? '-';

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
            // HEADER DUMMY
            Container(
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
                    child: const Icon(
                      Icons.location_city,
                      color: ColorsUtils.b500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wilayah Aktif',
                        style: TextStyle(fontSize: 12, color: ColorsUtils.gray),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'RT $rt / RW $rw',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorsUtils.b400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
              child: Consumer<KeluargaVM>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.errorMessage != null) {
                    return Center(child: Text(vm.errorMessage!));
                  }

                  if (vm.kkList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Belum ada data KK"),
                          SizedBox(height: 8),
                          Text("Tekan + untuk menambah"),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: vm.kkList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final kk = vm.kkList[index];
                      return _buildKKCard(kk);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorsUtils.b500,
        child: const Icon(Icons.add, color: ColorsUtils.white),
        onPressed: () {
          if (user.rt == null) {
            NotificationUtils.showError(context, 'RT tidak ditemukan');
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (_) => AddKKViewModel(
                  kkRepository: context.read<KKRepository>(),
                  cloudinaryService: context.read<CloudinaryService>(),
                  rtId: user.rt!.id,
                ),
                child: const AddKKPage(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKKCard(Keluarga kk) {
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
                  kk.alamat ?? '-',
                  style: const TextStyle(fontSize: 12, color: ColorsUtils.gray),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit_outlined, color: ColorsUtils.b500),
            onPressed: () {},
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Hapus KK"),
                  content: const Text("Yakin ingin menghapus data ini?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Hapus"),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              final id = kk.id;
              if (id == null) return;

              final vm = context.read<KeluargaVM>();
              await vm.deleteKK(id);

              if (vm.errorMessage != null) {
                NotificationUtils.showError(context, vm.errorMessage!);
              } else {
                NotificationUtils.showSuccess(context, "KK berhasil dihapus");
              }
            },
          ),
        ],
      ),
    );
  }
}
