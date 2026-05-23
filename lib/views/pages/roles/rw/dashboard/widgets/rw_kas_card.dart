import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

class RwKasCard extends StatelessWidget {
  final double saldo;
  final double masuk;
  final double keluar;

  const RwKasCard({
    super.key,
    required this.saldo,
    required this.masuk,
    required this.keluar,
  });

  String rupiah(double value) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),

        gradient: const LinearGradient(
          colors: [
            Color(0xFF2F80ED),
            Color(0xFF3F6EF6),
          ],
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Saldo Kas RW 002",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            rupiah(saldo),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              _item("Kas Masuk", rupiah(masuk), Colors.greenAccent),

              _item("Kas Keluar", "- ${rupiah(keluar)}", Colors.redAccent),

              _item("Diperbarui", "20 Apr 2026", Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}