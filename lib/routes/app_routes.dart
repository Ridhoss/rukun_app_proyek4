import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/views/pages/test_page.dart';
import 'package:rukun_app_proyek4/views/pages/auth/login_page.dart';
import 'package:rukun_app_proyek4/views/pages/auth/register_page.dart';

class AppRoutes {
  static const String test = '/test';
  static const String login = '/login';
  static const String register = '/register';
  // static const String ajukanSurat = '/ajukan-surat';
  // static const String riwayatSurat = '/riwayat-surat';
  // static const String iuran = '/iuran';
  // static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case test:
        return MaterialPageRoute(builder: (_) => TestPage());
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      // case ajukanSurat:
      //   return MaterialPageRoute(
      //     builder: (_) => const WargaSuratPage(), 
      //   );

      // case riwayatSurat:
      //   return MaterialPageRoute(
      //     builder: (_) => const WargaSuratPage(), 
      //   );

      // case iuran:
      //   return MaterialPageRoute(builder: (_) => const WargaIuranPage());

      // case profile:
      //   return MaterialPageRoute(builder: (_) => const WargaProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
