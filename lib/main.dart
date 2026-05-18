import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rukun_app_proyek4/core/route_observer.dart';
import 'package:rukun_app_proyek4/middleware/auth_gate.dart';
import 'package:rukun_app_proyek4/repositories/auth_repository.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repostiory.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/repositories/rtrw_repository.dart';
import 'package:rukun_app_proyek4/repositories/surat_repository.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';
import 'package:rukun_app_proyek4/services/api/dio_client.dart';
import 'package:rukun_app_proyek4/services/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_auth_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_iuran_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kk_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_rtrw_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_surat_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_warga_service.dart';
import 'package:rukun_app_proyek4/services/hive_service.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/iuran/add_iuran_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/iuran/iuran_bulanan_detail_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/iuran/iuran_rt_detail_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/penduduk/detail_rt_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/rw/iuran/detail_iuran_rw_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/rw/iuran/iuran_page_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/rw/penduduk/penduduk_rw_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/warga/surat/pengajuan_surat_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/rw/surat/surat_rw_viewmodel.dart';
// import 'package:rukun_app_proyek4/viewmodels/warga/profile/data_kk_viewmodel.dart';
// import 'package:rukun_app_proyek4/viewmodels/warga/profile/kelola_profile_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await initializeDateFormatting('id_ID');

  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => DioClient().dio),

        Provider(create: (context) => CloudAuthService()),

        Provider(create: (_) => HiveService()),

        Provider(create: (context) => AuthLocalService(context.read())),

        Provider(
          create: (context) => AuthRepository(context.read(), context.read()),
        ),

        Provider(create: (_) => CloudKKService()),

        Provider<CloudinaryService>(create: (_) => CloudinaryService()),

        Provider(create: (_) => CloudWargaService()),

        Provider(create: (_) => CloudIuranService()),

        Provider(create: (_) => CloudSuratService()),

        Provider(create: (_) => CloudRtRwService()),

        Provider(
          create: (context) => IuranRepository(
            context.read<CloudIuranService>(),
            context.read<AuthLocalService>(),
          ),
        ),

        Provider(
          create: (context) => KKRepository(
            context.read<CloudKKService>(),
            context.read<AuthLocalService>(),
          ),
        ),

        Provider(
          create: (context) => WargaRepository(
            context.read<CloudWargaService>(),
            context.read<AuthLocalService>(),
          ),
        ),

        Provider(
          create: (context) => SuratRepository(
            context.read<CloudSuratService>(),
            context.read<AuthLocalService>(),
          ),
        ),

        Provider(
          create: (context) => RTRWRepository(
            context.read<CloudRtRwService>(),
            context.read<AuthLocalService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => AuthViewModel(context.read()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              DetailRTViewmodel(kkRepository: context.read<KKRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              PengajuanSuratViewModel(context.read<SuratRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              RWPendudukViewmodel(repository: context.read<RTRWRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              RwIuranViewModel(repository: context.read<IuranRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              AddIuranViewModel(context.read<IuranRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              IuranRWDetailViewModel(context.read<IuranRepository>()),
        ),

        ChangeNotifierProvider(
          create: (context) => IuranRTDetailViewModel(
            iuranRepo: context.read<IuranRepository>(),
            rtrwRepo: context.read<RTRWRepository>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => IuranBulananDetailViewModel(
            iuranRepo: context.read<IuranRepository>(),
            rtrwRepo: context.read<RTRWRepository>(),
            kkRepository: context.read<KKRepository>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              SuratRwViewModel(context.read<WargaRepository>()),
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
      navigatorObservers: [routeObserver],
      home: const AuthGate(),
    );
  }
}
