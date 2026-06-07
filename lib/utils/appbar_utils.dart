import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/avatar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/services/local/connectivity_service.dart';
import 'package:rukun_app_proyek4/services/local/offline_sync_status_service.dart';
import 'package:rukun_app_proyek4/services/local/sync_coordinator.dart';

class AppBarUtils {
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required String name,
    required String title,
    String? subtitle,
    bool showName = true,
    bool showAvatar = true,
    bool showGreeting = true,
    Widget? leading,
    Widget? trailing,
    Widget? settingsWidget,
    bool showSyncBadge = true,
  }) {
    final canPop = Navigator.canPop(context);

    final Widget? finalLeading =
        leading ??
        (canPop
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: ColorsUtils.white,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null);

    return AppBar(
      backgroundColor: ColorsUtils.b500,
      elevation: 0,
      toolbarHeight: 90,

      leading: finalLeading,

      leadingWidth: finalLeading != null ? 60 : 0,

      titleSpacing: finalLeading != null ? 0 : 16,

      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showAvatar) ...[
                CircleAvatar(radius: 23, child: buildAvatar(name)),

                const SizedBox(width: 12),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showGreeting)
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ColorsUtils.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    if (showName)
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          color: ColorsUtils.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              if (settingsWidget != null) ...[
                const SizedBox(width: 8),
                settingsWidget,
              ] else if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ] else if (showSyncBadge) ...[
                const SizedBox(width: 8),
                const _AppBarSyncIndicator(),
              ],
            ],
          ),

          if (title.isNotEmpty) ...[
            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorsUtils.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (subtitle != null) ...[
            const SizedBox(height: 2),

            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: ColorsUtils.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  static String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Selamat Pagi";
    if (hour < 16) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";

    return "Selamat Malam";
  }
}

class _AppBarSyncIndicator extends StatefulWidget {
  const _AppBarSyncIndicator();

  @override
  State<_AppBarSyncIndicator> createState() => _AppBarSyncIndicatorState();
}

class _AppBarSyncIndicatorState extends State<_AppBarSyncIndicator> {
  bool _isSyncing = false;

  Future<void> _sync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    try {
      await context.read<SyncCoordinator>().syncNow();
    } catch (_) {}

    if (mounted) setState(() => _isSyncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = context.watch<ConnectivityService>();

    return ValueListenableBuilder<int>(
      valueListenable: OfflineSyncStatusService.instance.pendingCount,
      builder: (context, count, _) {
        final hasPending = count > 0;
        final isOffline = connectivity.isOffline;

        return GestureDetector(
          onTap: hasPending && !isOffline ? _sync : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isOffline
                  ? Colors.orange.withValues(alpha: 0.3)
                  : hasPending
                      ? Colors.amber.withValues(alpha: 0.3)
                      : ColorsUtils.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isOffline
                    ? Colors.orange.withValues(alpha: 0.5)
                    : hasPending
                        ? Colors.amber.withValues(alpha: 0.5)
                        : ColorsUtils.white.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSyncing)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorsUtils.white,
                    ),
                  )
                else
                  Icon(
                    isOffline
                        ? Icons.cloud_off
                        : hasPending
                            ? Icons.sync_problem
                            : Icons.cloud_done_outlined,
                    size: 16,
                    color: ColorsUtils.white,
                  ),
                if (isOffline) ...[
                  const SizedBox(width: 6),
                  const Text(
                    'Offline',
                    style: TextStyle(
                      color: ColorsUtils.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else if (hasPending) ...[
                  const SizedBox(width: 6),
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: ColorsUtils.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
