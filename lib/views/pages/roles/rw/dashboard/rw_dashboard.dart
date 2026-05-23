import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/logout_dialog_utils.dart';
import 'package:rukun_app_proyek4/utils/rw_settings_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/rw/dashboard/rw_dashboard_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/roles/rw/dashboard/widgets/rw_bar_chart.dart';
import 'package:rukun_app_proyek4/views/pages/roles/rw/dashboard/widgets/rw_kas_card.dart';
import 'package:rukun_app_proyek4/views/pages/roles/rw/dashboard/widgets/rw_kegiatan_card.dart';
import 'package:rukun_app_proyek4/views/pages/roles/rw/dashboard/widgets/rw_pie_chart.dart';
import 'package:rukun_app_proyek4/views/pages/roles/rw/dashboard/widgets/rw_summary_card.dart';

import 'package:rukun_app_proyek4/views/pages/roles/rw/profile/export_data_page.dart';
import 'package:rukun_app_proyek4/views/pages/roles/rw/profile/rw_profile_page.dart';
import 'package:rukun_app_proyek4/views/pages/roles/rw/profile/struktur_kepengurusan_page.dart';
import 'package:rukun_app_proyek4/views/pages/welcome_page.dart';

class RwDashboard extends StatelessWidget {
  const RwDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final warga = authVM.currentUser;

    final nama = warga?.warga?.nama ?? "-";

    return Scaffold(
      backgroundColor: ColorsUtils.lightgray,
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

      body: Consumer<DashboardRwViewModel>(
        builder: (context, vm, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RwKasCard(
                saldo: vm.saldoKas,
                masuk: vm.kasMasuk,
                keluar: vm.kasKeluar,
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: RwSummaryCard(
                      title: "Total Penduduk",
                      value: "${vm.totalPenduduk}",
                      subtitle: "↑ 12 Bulan ini",
                      icon: Icons.people_alt_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RwSummaryCard(
                      title: "Jumlah KK",
                      value: "${vm.totalKK}",
                      subtitle: "↑ dari bulan lalu",
                      icon: Icons.home_work_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: RwSummaryCard(
                      title: "Jumlah RT",
                      value: "${vm.totalRT}",
                      subtitle: "✓ Semua Aktif",
                      icon: Icons.account_tree_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RwSummaryCard(
                      title: "Status Surat",
                      value: "${vm.totalSurat}",
                      subtitle: "5 Pending | 5 Diproses",
                      icon: Icons.mail_outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Data Penduduk",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SizedBox(height: 220, child: RwBarChart()),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: SizedBox(height: 200, child: RwPieChart()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Kegiatan Berlangsung",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              const SizedBox(height: 14),

              const RwKegiatanCard(),

              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}
