import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/utils/avatar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

class AppBarUtils {
  static PreferredSizeWidget buildAppBar({
    required String name,
    Widget? leading,
    Widget? trailing,
  }) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: ColorsUtils.b500,
      elevation: 0,
      toolbarHeight: 80,
      leading: leading,

      title: Row(
        children: [
          CircleAvatar(radius: 23, child: buildAvatar(name)),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.bold,
                    color: ColorsUtils.white,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  name,
                  style: const TextStyle(fontSize: 15, color: ColorsUtils.white),
                ),
              ],
            ),
          ),

          // ignore: use_null_aware_elements
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  static String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Selamat Pagi';
    } else if (hour >= 12 && hour < 16) {
      return 'Selamat Siang';
    } else if (hour >= 16 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
}
