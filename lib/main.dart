import 'package:rukun_app_proyek4/repositories/dashboard_repository.dart';
import 'package:rukun_app_proyek4/repositories/kegiatan_repository.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_dashboard_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kegiatan_service.dart';
import 'package:rukun_app_proyek4/viewmodels/kegiatan/kegiatan_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/rt/kegiatan/kegiatan_rt_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/rt/rt_upload_setoran_rw_viewmodel.dart';

import 'package:rukun_app_proyek4/viewmodels/roles/rw/dashboard/rw_dashboard_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/rt/rt_dashboard_viewmodel.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rukun_app_proyek4/core/route_observer.dart';
import 'package:rukun_app_proyek4/repositories/auth_repository.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repository.dart';
import 'package:rukun_app_proyek4/repositories/kk_repository.dart';
import 'package:rukun_app_proyek4/repositories/rtrw_repository.dart';
import 'package:rukun_app_proyek4/repositories/surat_repository.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';
import 'package:rukun_app_proyek4/services/api/dio_client.dart';
import 'package:rukun_app_proyek4/services/auth/auth_local_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_auth_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_iuran_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_kk_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_rtrw_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_surat_service.dart';
import 'package:rukun_app_proyek4/services/cloud/cloud_warga_service.dart';
import 'package:rukun_app_proyek4/services/utils/hive_service.dart';
import 'package:rukun_app_proyek4/services/utils/cloudinary_service.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/export_data_viewmodel.dart';
import 'package:rukun_app_proyek4/services/utils/excel_export_service.dart';
import 'package:rukun_app_proyek4/viewmodels/iuran/add_iuran_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/iuran/iuran_bulanan_detail_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/iuran/iuran_rt_detail_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/penduduk/detail_rt_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/rw/iuran/detail_iuran_rw_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/rw/iuran/iuran_page_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/rw/penduduk/penduduk_rw_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/warga/surat/pengajuan_surat_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/warga/profile/data_kk_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/surat/surat_list_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/surat/surat_action_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/splash_page.dart';

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

        Provider(create: (_) => CloudKegiatanService()),

        Provider(create: (_) => CloudDashboardService()),

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

        Provider(
          create: (context) => KegiatanRepository(
            context.read<CloudKegiatanService>(),
            context.read<AuthLocalService>(),
          ),
        ),

        Provider(
          create: (context) => DashboardRepository(
            context.read<CloudDashboardService>(),
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
          create: (ctx) => ExportDataViewModel(
            kkRepo: ctx.read<KKRepository>(),
            wargaRepo: ctx.read<WargaRepository>(),
            exportService: ExcelExportService(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => RtDashboardViewModel(
            context.read<DashboardRepository>(),
          ),
        ),

        ChangeNotifierProvider(create: (_) => KegiatanRtViewModel()),

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
          create: (context) => DataKKViewModel(
            kkRepository: context.read<KKRepository>(),
            wargaRepository: context.read<WargaRepository>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => KegiatanViewModel(
            context.read<KegiatanRepository>(),
            context.read<CloudinaryService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => SuratListViewModel(
            context.read<WargaRepository>(),
            context.read<SuratRepository>(),
            context.read<AuthViewModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SuratActionViewModel(
            context.read<SuratRepository>(),
            context.read<CloudinaryService>(),
            context.read<AuthViewModel>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) => RTUploadSetoranRWViewModel(
            repository: context.read<IuranRepository>(),
            cloudinaryService: context.read<CloudinaryService>(),
          ),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              DashboardRwViewModel(context.read<DashboardRepository>())
                ..fetchDashboard(),
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
      home: const SplashPage(),
    );
  }
}
