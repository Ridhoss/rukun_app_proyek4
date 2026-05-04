import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rukun_app_proyek4/core/network/dio_client.dart';
import 'package:rukun_app_proyek4/middleware/auth_gate.dart';
import 'package:rukun_app_proyek4/repositories/auth_repository.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/services/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_auth_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kk_service.dart';
import 'package:rukun_app_proyek4/services/hive_service.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/kk_viewmodel.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => DioClient().dio),

        Provider(create: (context) => CloudAuthService(context.read())),

        Provider(create: (_) => HiveService()),

        Provider(create: (context) => AuthLocalService(context.read())),

        Provider(
          create: (context) => AuthRepository(context.read(), context.read()),
        ),

        Provider(create: (_) => CloudKKService()),

        Provider<CloudinaryService>(create: (_) => CloudinaryService()),

        Provider(
          create: (context) => KKRepository(
            context.read<CloudKKService>(),
            context.read<AuthLocalService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => AuthViewModel(context.read()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              KeluargaVM(kkRepository: context.read<KKRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'RukunApp',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
