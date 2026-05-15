import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

class RwSettingsUtils extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onProfile;
  final VoidCallback onExport;
  final VoidCallback onStructure;

  const RwSettingsUtils({
    super.key,
    required this.onLogout,
    required this.onProfile,
    required this.onExport,
    required this.onStructure,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings, color: ColorsUtils.white),
      onSelected: (value) {
        switch (value) {
          case "structure":
            onStructure();
            break;
          case "export":
            onExport();
            break;
          case "profile":
            onProfile();
            break;
          case "logout":
            onLogout();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: "structure", child: Text("Struktur")),
        const PopupMenuItem(value: "export", child: Text("Export Laporan")),
        const PopupMenuItem(value: "profile", child: Text("Info Akun")),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: "logout",
          child: Text("Keluar", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
