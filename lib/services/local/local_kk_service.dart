// import 'package:rukun_app_proyek4/models/keluarga.dart';
// import 'package:rukun_app_proyek4/services/hive_service.dart';

// class LocalKkService {
//   static final LocalKkService _instance = LocalKkService._internal();
//   factory LocalKkService() => _instance;
//   LocalKkService._internal();
  
//   static const String _kkBox = 'keluarga_offline';

//   Future<List<Keluarga>> getKKByRT(int rtId) async {
//     final kkBox = await HiveService().openBox<dynamic>(_kkBox);

//     final result = kkBox.values
//         .whereType<Map>()
//         .where(
//           (row) =>
//               (row['rt_id'] as num?)?.toInt() == rtId &&
//               (row['is_deleted'] as bool?) != true,
//         )
//         .map(Keluarga.fromMap)
//         .toList();

//     result.sort((a, b) => b.id!.compareTo(a.id!));

//     return result;
//   }

//   Future<void> saveKKLocalOnly(Keluarga kk) async {
//     final kkBox = await HiveService().openBox<dynamic>(_kkBox);

//     final payload = {
//       'id': kk.id,
//       'no_kk': kk.noKK,
//       'rt_id': kk.rtId,
//       'alamat': kk.alamat,
//       'sync_status': 'synced',
//       'created_at': DateTime.now().toIso8601String(),
//       'updated_at': DateTime.now().toIso8601String(),
//       'is_deleted': false,
//     };

//     await kkBox.put(kk.id, payload);
//   }
// }
