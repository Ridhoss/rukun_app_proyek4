import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/utils/avatar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

class AppBarUtils {
  static PreferredSizeWidget buildAppBar({
    required BuildContext context,
    required String name,
    required String title,
    String? subtitle,
    bool showName = true,
    bool showAvatar = true,
    bool showGreeting = true,
    Widget? leading,
    Widget? trailing,
  }) {
    final canPop = Navigator.canPop(context);

    final Widget? finalLeading =
        leading ??
        (canPop
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: ColorsUtils.white,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null);

    return AppBar(
      backgroundColor: ColorsUtils.b500,
      elevation: 0,
      toolbarHeight: 90,
      // automaticallyImplyLeading: false,

      leading: finalLeading,

      leadingWidth: finalLeading != null ? 60 : 0,

      titleSpacing: finalLeading != null ? 0 : 16,

      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showAvatar) ...[
                CircleAvatar(
                  radius: 23,
                  child: buildAvatar(name),
                ),

                const SizedBox(width: 12),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showGreeting)
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ColorsUtils.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    if (showName)
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          color: ColorsUtils.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),

          if (title.isNotEmpty) ...[
            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ColorsUtils.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (subtitle != null) ...[
            const SizedBox(height: 2),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: ColorsUtils.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
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