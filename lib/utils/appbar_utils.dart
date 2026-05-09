import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/utils/avatar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

class AppBarUtils {
  static PreferredSizeWidget buildAppBar({
    required String name,
    required String title,
    String? subtitle,
    bool showName = true,
    bool showAvatar = true,
    bool showGreeting = true,
    Widget? leading,
    Widget? trailing,
  }) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: ColorsUtils.b500,
      elevation: 0,
      toolbarHeight: 90,
      leadingWidth: 60,
      leading: leading,

      title: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (showAvatar)
                  CircleAvatar(radius: 23, child: buildAvatar(name)),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showGreeting)
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                      if (showName)
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            color: ColorsUtils.white,
                          ),
                        ),
                    ],
                  ),
                ),

                if (trailing != null) trailing,
              ],
            ),

            const SizedBox(height: 6),

            if (title.isNotEmpty)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }

  static String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Selamat Pagi";
    if (hour < 16) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }
}
