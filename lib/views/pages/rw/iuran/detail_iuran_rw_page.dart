import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';

class IuranRWDetailPage extends StatelessWidget {
  const IuranRWDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: "",
        title: "Detail Iuran",
        subtitle: "Informasi iuran & status RT",
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildInfoGrid(),
            const SizedBox(height: 16),
            _buildRtSection(),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Iuran Kebersihan RW",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              _buildBadge("RUTIN", Colors.blue),
              const SizedBox(width: 8),
              _buildBadge("RW", Colors.grey),
              const SizedBox(width: 8),
              _buildBadge("AKTIF", Colors.green),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _MiniStat(title: "Total", value: "Rp 500.000"),
              _MiniStat(title: "Terkumpul", value: "Rp 250.000"),
            ],
          ),
        ],
      ),
    );
  }

  // ================= INFO GRID =================
  Widget _buildInfoGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Informasi Iuran",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          _InfoRow(
            icon: Icons.calendar_today,
            text: "Dibuat Tanggal: 10 Mei 2026",
          ),
          _InfoRow(icon: Icons.repeat, text: "Jenis: Iuran rutin bulanan"),
        ],
      ),
    );
  }

  // ================= RT LIST =================
  Widget _buildRtSection() {
    final dummyRt = [
      {
        "nama": "RT 01",
        "ketua": "Budi",
        "bendahara": "Siapa",
        "bayar": 100000,
        "total": 100000,
      },
      {
        "nama": "RT 02",
        "ketua": "Siti",
        "bendahara": "Siapa",
        "bayar": 50000,
        "total": 100000,
      },
      {
        "nama": "RT 03",
        "ketua": "Andi",
        "bendahara": "Siapa",
        "bayar": 0,
        "total": 100000,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Status RT",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...dummyRt.map((rt) {
          final total = rt["total"] as int;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rt["nama"].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text("Ketua: ${rt["ketua"]}, Bendahara: ${rt["bendahara"]}"),

                const SizedBox(height: 8),

                Text(
                  "Total: Rp $total",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ================= COMPONENT =================
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget _buildStatusBadge(double progress) {
  //   String text;
  //   Color color;

  //   if (progress >= 1) {
  //     text = "LUNAS";
  //     color = Colors.green;
  //   } else if (progress > 0) {
  //     text = "PARTIAL";
  //     color = Colors.orange;
  //   } else {
  //     text = "BELUM";
  //     color = Colors.red;
  //   }

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(20),
  //     ),
  //     child: Text(
  //       text,
  //       style: TextStyle(
  //         color: color,
  //         fontSize: 11,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
