import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';

class KontakPengurusPage extends StatelessWidget {
  const KontakPengurusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nama = context.watch<AuthViewModel>().currentUser?.warga?.nama ?? "-";

    return Scaffold(
      backgroundColor: ColorsUtils.lightgray,

      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: nama,
        title: "Kontak pengurus",
        subtitle: "Informasi Kontak Pengurus",
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),
      body: const Center(child: Text("Halaman Kontak Pengurus")),
    );
  }
}
