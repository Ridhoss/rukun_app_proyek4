import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/menucard_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/warga/home/aktivitas_warga_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/roles/warga/iuran/iuran_page.dart';
import 'package:rukun_app_proyek4/views/pages/roles/warga/kegiatan/kegiatan_page.dart';
import 'package:rukun_app_proyek4/views/pages/roles/warga/surat/pengajuan_surat_page.dart';

class WargaHomePage extends StatefulWidget {
  final User user;

  const WargaHomePage({super.key, required this.user});

  @override
  State<WargaHomePage> createState() => _WargaHomePageState();
}

class _WargaHomePageState extends State<WargaHomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AktivitasWargaViewModel>().loadAktivitas(
        rwId: widget.user.rw?.id ?? 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    final nama = authVM.currentUser?.warga?.nama ?? "-";

    final menus = [
      {
        "title": "Ajukan Surat",
        "subtitle": "Buat pengajuan surat",
        "image": "assets/images/add_surat.png",
        "builder": (BuildContext context) =>
            PengajuanSuratPage(user: widget.user),
      },
      {
        "title": "Iuran Saya",
        "subtitle": "Status & bukti pembayaran",
        "image": "assets/images/fee.png",
        "builder": (BuildContext context) => WargaIuranPage(user: widget.user),
      },
      {
        "title": "Daftar Kegiatan",
        "subtitle": "Lihat daftar kegiatan yang sedang dilaksanakan",
        "image": "assets/images/history_surat.png",
        "builder": (BuildContext context) => const KegiatanPage(),
      },
    ];

    return Scaffold(
      backgroundColor: ColorsUtils.lightgray,
      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: nama,
        title: "",
        showName: true,
        showAvatar: true,
        showGreeting: true,
        trailing: IconButton(
          icon: const Icon(Icons.notifications_none, color: ColorsUtils.white),
          onPressed: () {},
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          const Text(
            "Menu Utama",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          ...menus.map((menu) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MenuCard(
                title: menu["title"] as String,
                subtitle: menu["subtitle"] as String,
                imagePath: menu["image"] as String,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          (menu["builder"] as Widget Function(BuildContext))(
                            context,
                          ),
                    ),
                  );
                },
              ),
            );
          }),

          const SizedBox(height: 24),

          const Text(
            "Aktivitas Terbaru",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Consumer<AktivitasWargaViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (vm.aktivitas.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(child: Text("Belum ada aktivitas")),
                );
              }

              return Column(
                children: vm.aktivitas
                    .map((item) => _aktivitasCard(item))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _aktivitasCard(Map<String, dynamic> item) {
    final color = item["color"] as Color? ?? ColorsUtils.b400;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 70,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["title"] ?? "-",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        _formatWaktu(item["date"]),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatWaktu(DateTime? date) {
    if (date == null) return "-";

    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) {
      return "Baru saja";
    }

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} menit lalu";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} jam lalu";
    }

    if (diff.inDays < 30) {
      return "${diff.inDays} hari lalu";
    }

    return "${date.day}/${date.month}/${date.year}";
  }
}
