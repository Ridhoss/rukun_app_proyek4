import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/keluarga.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kk_service.dart';
import 'package:rukun_app_proyek4/services/local/local_kk_service.dart';
import 'package:rukun_app_proyek4/services/warga_service.dart';
import 'package:rukun_app_proyek4/viewmodels/keluarga_vm.dart';
import 'package:rukun_app_proyek4/views/pages/debug/switch_rt_debug_page.dart';
import 'package:rukun_app_proyek4/views/pages/kependudukan/add_kk_page.dart';
import 'package:rukun_app_proyek4/views/pages/kependudukan/add_warga_page.dart';
import 'package:rukun_app_proyek4/views/pages/kependudukan/dashboard_kependudukan_page.dart';
import 'package:rukun_app_proyek4/views/pages/test_page.dart';

class AppRoutes {
  static const String test = '/test';

  // ── Kependudukan ─────────────────────────────────────────────
  static const String dashboardKependudukan = '/kependudukan/dashboard';
  static const String addKK = '/kependudukan/add-kk';
  static const String addWarga = '/kependudukan/add-warga';
  static const String debugSwitchRT = '/debug/switch-rt';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case test:
        return MaterialPageRoute(builder: (_) => const TestPage());

      case dashboardKependudukan:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => KeluargaVM(
              repository: KKRepository(
                cloud: CloudKKService(),
                local: LocalKkService(),
              ),
            )..loadKK(1),
            child: const DashboardKependudukanPage(),
          ),
        );

      case addKK:
        // Opsional: terima editData dari arguments untuk mode edit
        final editData = settings.arguments as Keluarga?;
        return MaterialPageRoute(builder: (_) => AddKKPage(editData: editData));

      case addWarga:
        // Opsional: terima keluargaId & editData dari arguments
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddWargaPage(
            keluargaId: args?['keluargaId'] as int?,
            editData: args?['editData'] as WargaModel?,
          ),
        );

      case debugSwitchRT:
        if (!kDebugMode) {
          // Mengembalikan halaman default jika bukan mode debug
          return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Page not found'))),
          );
        }
        return MaterialPageRoute(builder: (_) => const SwitchRTDebugPage());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
