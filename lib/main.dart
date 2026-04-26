import 'package:rukun_app_proyek4/core/network/dio_client.dart';
import 'package:rukun_app_proyek4/middleware/auth_gate.dart';
import 'package:rukun_app_proyek4/repositories/auth_repository.dart';
import 'package:rukun_app_proyek4/routes/app_routes.dart';
import 'package:rukun_app_proyek4/services/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_auth_service.dart';
import 'package:rukun_app_proyek4/services/hive_service.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
// ignore: unnecessary_import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(context.read()),
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
      onGenerateRoute: AppRoutes.generateRoute,
      home: const AuthGate(),
    );
  }
}
