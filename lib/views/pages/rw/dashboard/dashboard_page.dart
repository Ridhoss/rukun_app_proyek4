import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/logout_dialog_utils.dart';
import 'package:rukun_app_proyek4/utils/rw_settings_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/auth/login_page.dart';
import 'package:rukun_app_proyek4/views/pages/rw/profile/export_data_page.dart';
import 'package:rukun_app_proyek4/views/pages/rw/profile/rw_profile_page.dart';
import 'package:rukun_app_proyek4/views/pages/rw/profile/struktur_kepengurusan_page.dart';
import 'package:rukun_app_proyek4/views/pages/welcome_page.dart';

class RwDashboard extends StatelessWidget {
  const RwDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final warga = authVM.currentUser;

    final nama = warga?.warga?.nama ?? "-";

    return Scaffold(
      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: nama,
        title: "",
        subtitle: "",

        showAvatar: true,
        showName: true,
        showGreeting: true,

        settingsWidget: RwSettingsUtils(
          onStructure: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StructurePage()),
            );
          },

          onExport: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExportPage()),
            );
          },

          onProfile: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RwProfilePage()),
            );
          },
          onLogout: () async {
            final confirm = await LogoutDialogUtils.showLogoutDialog(context);

            if (confirm == true) {
              await authVM.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomePage()),
                (route) => false,
              );
            }
          },
        ),
      ),

      body: const Center(child: Text("Dashboard RW")),
    );
  }
}
