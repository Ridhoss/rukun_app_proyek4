import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

class RwKegiatanCard extends StatelessWidget {
  const RwKegiatanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

            decoration: BoxDecoration(
              color: const Color(0xFFCDEFE5),
              borderRadius: BorderRadius.circular(30),
            ),

            child: const Text(
              "Berlangsung",
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height:15),

          const Text(
            "Kerja Bakti Bersih RW 02",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),

          const SizedBox(height: 10),

          const Text(
            "Kegiatan membersih lingkungan RW 002 yang mencakup RT 1, RT 2, RT 3, RT 4, RT 5",
            style: TextStyle(color: ColorsUtils.gray, height: 1.5),
          ),

          const SizedBox(height: 18),

          const Text(
            "11 - 15 Mei 2026",
            style: TextStyle(color: ColorsUtils.gray),
          ),
        ],
      ),
    );
  }
}
