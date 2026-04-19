import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Test"),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.test);
          },
        ),
      ),
    );
  }
}
