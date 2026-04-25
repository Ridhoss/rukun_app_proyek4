import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/views/pages/test_page.dart';
import 'package:rukun_app_proyek4/views/pages/auth/login_page.dart';
import 'package:rukun_app_proyek4/views/pages/auth/register_page.dart';

class AppRoutes {
  static const String test = '/test';
  static const String login ='/login';
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case test:
        return MaterialPageRoute(builder: (_) => TestPage());
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
