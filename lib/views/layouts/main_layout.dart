import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/viewmodels/nav_viewmodel.dart';
import 'package:rukun_app_proyek4/utils/bottom_nav.dart';

class MainLayout extends StatelessWidget {
  final User user;

  const MainLayout({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final navItems = NavViewModel().getNavItems(user);

    return BottomNav(items: navItems);
  }
}