import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/services/local/connectivity_service.dart';
import 'package:rukun_app_proyek4/views/widgets/stale_data_indicator.dart';

class OfflineBanner extends StatelessWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();

    return Column(
      children: [
        if (connectivity.isOffline)
          MaterialBanner(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            content: const Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Mode Offline — Menampilkan data tersimpan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            leading: const SizedBox.shrink(),
            actions: const [SizedBox.shrink()],
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: StaleDataIndicator(),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
