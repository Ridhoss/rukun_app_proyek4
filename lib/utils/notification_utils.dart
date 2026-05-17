import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';


class NotificationUtils {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, ColorsUtils.g100, Icons.check_circle_outline);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, ColorsUtils.red, Icons.error_outline);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: _NotificationCard(message: message, color: color, icon: icon),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }
}

class _NotificationCard extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _NotificationCard({
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ColorsUtils.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
