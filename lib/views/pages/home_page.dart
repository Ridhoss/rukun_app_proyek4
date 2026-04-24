import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rukun_app_proyek4/routes/app_routes.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart'; // Tambahkan ini jika ingin menggunakan warna dari utils

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: ColorsUtils.b300,
        foregroundColor: ColorsUtils.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Test Page"),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.test);
              },
            ),
            const SizedBox(height: 20),

            // Tombol baru untuk menu Kependudukan
            ElevatedButton.icon(
              icon: const Icon(Icons.group_add_outlined),
              label: const Text("Menu Kependudukan (Tambah KK)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsUtils.b300,
                foregroundColor: ColorsUtils.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addKK);
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.dashboard_outlined),
              label: const Text("Dashboard Kependudukan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsUtils.b300,
                foregroundColor: ColorsUtils.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Arahkan ke halaman Dashboard yang baru dibuat
                Navigator.pushNamed(context, AppRoutes.dashboardKependudukan);
              },
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.swap_horiz),
                label: const Text("Debug: Switch RT Context"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.debugSwitchRT);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
