import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/services/local/sync_coordinator.dart';

mixin SyncRefreshMixin<T extends StatefulWidget> on State<T> {
  void onSyncComplete(bool success);

  @override
  void initState() {
    super.initState();
    SyncCoordinator.syncVersion.addListener(_handleChange);
  }

  void _handleChange() {
    if (mounted) {
      onSyncComplete(SyncCoordinator.lastSyncSuccess);
    }
  }

  @override
  void dispose() {
    SyncCoordinator.syncVersion.removeListener(_handleChange);
    super.dispose();
  }
}
