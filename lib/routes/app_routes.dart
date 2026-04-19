import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/views/pages/test_page.dart';

class AppRoutes {
  static const String test = '/test';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case test:
        return MaterialPageRoute(builder: (_) => TestPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
