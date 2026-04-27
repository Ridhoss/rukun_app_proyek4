import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';

// pages Pengurus
import 'package:rukun_app_proyek4/views/pages/pengurus/home_page.dart';
import 'package:rukun_app_proyek4/views/pages/pengurus/penduduk_page.dart';
import 'package:rukun_app_proyek4/views/pages/pengurus/iuran_page.dart';
import 'package:rukun_app_proyek4/views/pages/pengurus/surat_page.dart';
import 'package:rukun_app_proyek4/views/pages/pengurus/profile_page.dart';

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
    final isPengurus = user.role == Role.pengurus;

    if (isPengurus) {
      return [
        NavItem(
          icon: Icons.home, 
          label: "Home", 
          page: PengurusHomePage()),
        NavItem(icon: Icons.groups, label: "Penduduk", page: PendudukPage()),
        NavItem(
          icon: Icons.payments,
          label: "Iuran",
          page: PengurusIuranPage(),
        ),
        NavItem(
          icon: Icons.description,
          label: "Surat",
          page: PengurusSuratPage(),
        ),
        NavItem(
          icon: Icons.person,
          label: "Profile",
          page: PengurusProfilePage(),
        ),
      ];
    }

    return [
      NavItem(
        icon: Icons.home, 
        label: "Home", 
        page: WargaHomePage()),
      NavItem(
        icon: Icons.upload_file,
        label: "Upload",
        page: WargaIuranPage(), // ini bagian upload iuran warga
      ),
      NavItem(
        icon: Icons.history, 
        label: "Riwayat", 
        page: RiwayatIuranPage()),
      NavItem(
        icon: Icons.description, 
        label: "Surat", 
        page: WargaSuratPage()),
      NavItem(
        icon: Icons.person, 
        label: "Profile", 
        page: WargaProfilePage()),
    ];
  }
}
