import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';


class KelolaProfilePage extends StatelessWidget {
  const KelolaProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final nama = context.watch<AuthViewModel>().currentUser?.warga?.nama ?? "-";

    return Scaffold(
      backgroundColor: ColorsUtils.lightgray,

      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: nama,
        title: "Kelola Profile",
        subtitle: "Informasi Data akun dan Password anda",
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),
      body: const Center(child: Text("Halaman Kelola profile")),
    );
  }
}
