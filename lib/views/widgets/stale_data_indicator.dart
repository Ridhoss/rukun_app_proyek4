import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/services/local/connectivity_service.dart';
import 'package:rukun_app_proyek4/services/local/proactive_cache_service.dart';

class StaleDataIndicator extends StatefulWidget {
  const StaleDataIndicator({super.key});

  @override
  State<StaleDataIndicator> createState() => _StaleDataIndicatorState();
}

class _StaleDataIndicatorState extends State<StaleDataIndicator> {
  String? _lastCacheLabel;

  @override
  void initState() {
    super.initState();
    _loadLastCacheTime();
  }

  Future<void> _loadLastCacheTime() async {
    final lastCache = await ProactiveCacheService.getLastCacheTime();
    if (lastCache != null && mounted) {
      setState(() {
        _lastCacheLabel = _formatRelative(lastCache);
      });
    }
  }

  String _formatRelative(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return DateFormat('dd MMM yyyy, HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();

    if (_lastCacheLabel == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: connectivity.isOnline
            ? Colors.green.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: connectivity.isOnline
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            connectivity.isOnline ? Icons.cloud_done : Icons.cloud_off,
            size: 14,
            color: connectivity.isOnline
                ? Colors.green.shade700
                : Colors.orange.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            connectivity.isOnline
                ? 'Data terbaru · $_lastCacheLabel'
                : 'Data tersimpan · $_lastCacheLabel',
            style: TextStyle(
              fontSize: 11,
              color: connectivity.isOnline
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
