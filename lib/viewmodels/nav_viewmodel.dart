import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';

// pages RW
import 'package:rukun_app_proyek4/views/pages/rw/home_page.dart';
import 'package:rukun_app_proyek4/views/pages/rw/penduduk_page.dart';
import 'package:rukun_app_proyek4/views/pages/rw/iuran_page.dart';
import 'package:rukun_app_proyek4/views/pages/rw/surat_page.dart';
import 'package:rukun_app_proyek4/views/pages/rw/profile_page.dart';

// pages RT
import 'package:rukun_app_proyek4/views/pages/rt/home_page.dart';
import 'package:rukun_app_proyek4/views/pages/rt/penduduk_page.dart';
import 'package:rukun_app_proyek4/views/pages/rt/iuran_page.dart';
import 'package:rukun_app_proyek4/views/pages/rt/surat_page.dart';
import 'package:rukun_app_proyek4/views/pages/rt/profile_page.dart';

// pages Warga
import 'package:rukun_app_proyek4/views/pages/warga/home_page.dart';
import 'package:rukun_app_proyek4/views/pages/warga/iuran_page.dart';
import 'package:rukun_app_proyek4/views/pages/warga/riwayat_iuran_page.dart';
import 'package:rukun_app_proyek4/views/pages/warga/surat_page.dart';
import 'package:rukun_app_proyek4/views/pages/warga/profile_page.dart';

class NavItem {
  final IconData icon;
  final String label;
  final Widget page;

  NavItem({required this.icon, required this.label, required this.page});
}

class NavViewModel {
  List<NavItem> getNavItems(User user) {
    final role = user.appRole;

// RW
if (role == AppRole.rw) {
  return [
    NavItem(icon: Icons.home, label: "Home", page: const RwHomePage()),
    NavItem(icon: Icons.groups, label: "Penduduk", page: const RwPendudukPage()),
    NavItem(icon: Icons.payments, label: "Iuran", page: const RwIuranPage()),
    NavItem(icon: Icons.description, label: "Surat", page: const RwSuratPage()),
    NavItem(icon: Icons.person, label: "Profile", page: const RwProfilePage()),
  ];
}

// RT
if (role == AppRole.rt) {
  return [
    NavItem(icon: Icons.home, label: "Home", page: const RtHomePage()),
    NavItem(icon: Icons.groups, label: "Penduduk", page: const RtPendudukPage()),
    NavItem(icon: Icons.payments, label: "Iuran", page: const RtIuranPage()),
    NavItem(icon: Icons.description, label: "Surat", page: const RtSuratPage()),
    NavItem(icon: Icons.person, label: "Profile", page: const RtProfilePage()),
  ];
}

    // Warga
    return [
      NavItem(icon: Icons.home, label: "Home", page: WargaHomePage()),
      NavItem(
        icon: Icons.upload_file,
        label: "Upload",
        page: WargaIuranPage(), // ini bagian upload iuran warga
      ),
      NavItem(icon: Icons.history, label: "Riwayat", page: RiwayatIuranPage()),
      NavItem(icon: Icons.description, label: "Surat", page: WargaSuratPage()),
      NavItem(icon: Icons.person, label: "Profile", page: WargaProfilePage()),
    ];
  }
}
