import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

class RwSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const RwSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ColorsUtils.gray,
                  fontSize: 12,
                ),
              ),

              Container(
                padding: const EdgeInsets.all(6),

                decoration: BoxDecoration(
                  color: ColorsUtils.b50,
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Icon(
                  icon,
                  size: 16,
                  color: ColorsUtils.b200,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: const TextStyle(
              color: ColorsUtils.gray,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}