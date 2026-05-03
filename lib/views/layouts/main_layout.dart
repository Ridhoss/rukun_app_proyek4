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

// class MainLayout extends StatefulWidget {
//   const MainLayout({super.key});

//   @override
//   State<MainLayout> createState() => _MainLayoutState();
// }

// class _MainLayoutState extends State<MainLayout> {
//   int _currentIndex = 0;

//   final _pages = [
//     HomePage(),
//     TestPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() => _currentIndex = index);
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Test'),
//         ],
//       ),
//     );
//   }
// }
