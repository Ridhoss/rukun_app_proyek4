import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/avatar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/auth/login_page.dart';
import 'package:rukun_app_proyek4/views/pages/warga/kontak_pengurus_page.dart';
import 'package:rukun_app_proyek4/views/pages/warga/data_kk_page.dart';

class WargaProfilePage extends StatelessWidget {
  const WargaProfilePage({super.key});

  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    final warga = authVM.currentUser;

    final nama = warga?.warga?.nama ?? "-";
    final nik = warga?.warga?.nik ?? "-";

    return Scaffold(
      backgroundColor: ColorsUtils.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              color: ColorsUtils.b400,
              borderRadius: BorderRadius.vertical(),
            ),
            child: Column(
              children: [
                buildAvatar(nama),

                const SizedBox(height: 12),
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorsUtils.white,
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  "NIK. $nik",
                  style: const TextStyle(color: ColorsUtils.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 70),
          buildMenuCard(
            icon: Icons.group,
            title: "Data Kartu Keluarga",
            subtitle: "Informasi Kartu Keluarga",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DataWargaPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),
          buildMenuCard(
            icon: Icons.file_download,
            title: "Info Akun Anda",
            subtitle: "Iuran Kependudukan, Surat",
          ),

          const SizedBox(height: 12),
          buildMenuCard(
            icon: Icons.person,
            title: "Kontak Pengurus",
            subtitle: "Informasi kontak pengurus RT/RW",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KontakPengurusPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),
          buildMenuCard(
            icon: Icons.logout,
            title: "Keluar",
            subtitle: "Logout dari aplikasi",
            iconColor: Colors.red,
            iconBg: Colors.red.shade50,
            onTap: () async {
              final confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Konfirmasi"),
                  content: Text("Apakah kamu yakin ingin keluar?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        "Keluar",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authVM.logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = Colors.blue,
    Color? iconBg,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg ?? Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }
}
