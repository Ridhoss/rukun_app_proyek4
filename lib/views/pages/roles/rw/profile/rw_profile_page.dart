import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/repositories/auth_repository.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/warga/profile/kelola_profile_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/roles/warga/profile/warga_profile_page.dart';

class RwProfilePage extends StatelessWidget {
  const RwProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          KelolaProfileViewModel(context.read<AuthRepository>()),

      child: const KelolaProfilePage(),
    );
  }
}