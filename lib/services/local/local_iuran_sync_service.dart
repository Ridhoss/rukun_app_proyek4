import 'package:hive/hive.dart';
import 'package:rukun_app_proyek4/services/local/offline_sync_status_service.dart';
import 'package:rukun_app_proyek4/services/utils/hive_service.dart';

class IuranLocalSyncService {
  static const String _queueBoxName = 'offline_sync_iuran';

  Future<void> queueCreateIuran({
    required int tempId,
    required Map<String, dynamic> payload,
  }) async {
    final box = await HiveService().openBox<dynamic>(_queueBoxName);

    await box.put(tempId.toString(), {
      'queue_id': tempId.toString(),
      'operation': 'create',
      'entity': 'iuran',
      'entity_id': tempId,
      'payload': Map<String, dynamic>.from(payload),
      'created_at': DateTime.now().toIso8601String(),
    });

    await OfflineSyncStatusService.instance.refresh();
  }

  Future<void> queueUpdateIuran({
    required int entityId,
    required Map<String, dynamic> payload,
  }) async {
    final box = await HiveService().openBox<dynamic>(_queueBoxName);
    final existingCreate = _findCreateEntry(box, entityId);

    if (existingCreate != null) {
      final mergedPayload = Map<String, dynamic>.from(
        (existingCreate['payload'] as Map?)?.cast<String, dynamic>() ?? {},
      )..addAll(payload);

      existingCreate['payload'] = mergedPayload;
      existingCreate['updated_at'] = DateTime.now().toIso8601String();
      await box.put(existingCreate['queue_id'].toString(), existingCreate);
      await OfflineSyncStatusService.instance.refresh();
      return;
    }

    final queueId = '${entityId}_${DateTime.now().microsecondsSinceEpoch}';

    await box.put(queueId, {
      'queue_id': queueId,
      'operation': 'update',
      'entity': 'iuran',
      'entity_id': entityId,
      'payload': Map<String, dynamic>.from(payload),
      'created_at': DateTime.now().toIso8601String(),
    });

    await OfflineSyncStatusService.instance.refresh();
  }

  Future<void> queueDeleteIuran({required int entityId}) async {
    final box = await HiveService().openBox<dynamic>(_queueBoxName);
    final existingCreate = _findCreateEntry(box, entityId);

    if (existingCreate != null) {
      await box.delete(existingCreate['queue_id'].toString());
      await OfflineSyncStatusService.instance.refresh();
      return;
    }

    final queueId = '${entityId}_${DateTime.now().microsecondsSinceEpoch}';

    await box.put(queueId, {
      'queue_id': queueId,
      'operation': 'delete',
      'entity': 'iuran',
      'entity_id': entityId,
      'payload': const <String, dynamic>{},
      'created_at': DateTime.now().toIso8601String(),
    });

    await OfflineSyncStatusService.instance.refresh();
  }

  Future<List<Map<String, dynamic>>> readPendingActions() async {
    final box = await HiveService().openBox<dynamic>(_queueBoxName);
    final actions = <Map<String, dynamic>>[];

    for (final value in box.values) {
      if (value is Map) {
        actions.add(Map<String, dynamic>.from(value));
      }
    }

    actions.sort((a, b) {
      final left =
          DateTime.tryParse(a['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final right =
          DateTime.tryParse(b['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return left.compareTo(right);
    });

    return actions;
  }

  Future<void> removeAction(String queueId) async {
    final box = await HiveService().openBox<dynamic>(_queueBoxName);
    await box.delete(queueId);

    await OfflineSyncStatusService.instance.refresh();
  }

  Future<void> clear() async {
    final box = await HiveService().openBox<dynamic>(_queueBoxName);
    await box.clear();

    await OfflineSyncStatusService.instance.refresh();
  }

  Map<String, dynamic>? _findCreateEntry(Box<dynamic> box, int entityId) {
    for (final value in box.values) {
      if (value is Map) {
        final mapped = Map<String, dynamic>.from(value);
        if (mapped['entity'] == 'iuran' &&
            mapped['operation'] == 'create' &&
            (mapped['entity_id'] as num?)?.toInt() == entityId) {
          return mapped;
        }
      }
    }

    return null;
  }
}
