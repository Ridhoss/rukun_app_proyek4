import 'package:rukun_app_proyek4/routes/app_routes.dart';
// import 'package:rukun_app_proyek4/views/layouts/';
import 'package:rukun_app_proyek4/views/pages/welcome_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'RukunApp',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.generateRoute,
      home: const WelcomePage(),
    );
  }
}