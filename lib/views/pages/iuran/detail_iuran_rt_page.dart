import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/iuran/iuran_rt_detail_viewmodel.dart';

class IuranRTDetailPage extends StatefulWidget {
  final int iuranId;
  final int rtId;

  const IuranRTDetailPage({
    super.key,
    required this.iuranId,
    required this.rtId,
  });

  @override
  State<IuranRTDetailPage> createState() => _IuranRTDetailPageState();
}

class _IuranRTDetailPageState extends State<IuranRTDetailPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<IuranRTDetailViewModel>().fetchDetail(
        widget.iuranId,
        widget.rtId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: "",
        title: "Detail Iuran RT",
        subtitle: "Status iuran & periode bulan",
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),

      body: Consumer<IuranRTDetailViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(child: Text(vm.errorMessage!));
          }

          final iuran = vm.iuran;
          final transaksi = vm.transaksi;

          if (iuran == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final rt = vm.rtDetail;

          final startDate = iuran.waktuDibuat ?? DateTime.now();
          final months = generateMonths(startDate);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryCard(iuran: iuran, terkumpul: vm.totalTerkumpul),

                const SizedBox(height: 16),

                _buildInfoGrid(iuran),

                const SizedBox(height: 16),

                if (rt != null) _buildRtInfo(rt),

                const SizedBox(height: 16),

                _buildMonthlyList(months, transaksi),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({required Iuran iuran, required int terkumpul}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            iuran.nama,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildBadge(iuran.level.name.toUpperCase(), Colors.grey),

              const SizedBox(width: 8),

              _buildBadge(iuran.tipe.name.toUpperCase(), Colors.green),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(title: "Total Terkumpul", value: "Rp.$terkumpul"),

              _MiniStat(title: "Biaya Iuran", value: "Rp.${iuran.jumlah}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(Iuran iuran) {
    String waktuDibuatText() {
      if (iuran.waktuDibuat == null) return "-";

      return DateFormat('dd MMMM yyyy', 'id_ID').format(iuran.waktuDibuat!);
    }

    String tipeText() {
      if (iuran.tipe == IuranType.insidentil) {
        return "Iuran bersifat insidentil, sekali bayar dan seikhlasnya";
      }

      return "Iuran bersifat reguler dan dibayarkan secara berkala";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informasi Iuran",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _InfoRow(icon: Icons.event, text: "Dibuat: ${waktuDibuatText()}"),

          _InfoRow(icon: Icons.info, text: tipeText()),
        ],
      ),
    );
  }

  Widget _buildRtInfo(dynamic rt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informasi RT",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.home_work_outlined,
            text: "RT ${rt.noRt ?? '-'}",
          ),

          _InfoRow(icon: Icons.person, text: "Ketua: ${rt.ketua ?? '-'}"),

          _InfoRow(
            icon: Icons.account_balance_wallet_outlined,
            text: "Bendahara: ${rt.bendahara ?? '-'}",
          ),

          _InfoRow(
            icon: Icons.groups_outlined,
            text: "Total Keluarga: ${rt.totalKeluarga ?? 0}",
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyList(List<DateTime> months, List transaksi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Periode Iuran",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ...months.map((month) {
          final label = DateFormat('MMMM yyyy', 'id_ID').format(month);

          final sudahBayar = transaksi.any((t) {
            final tDate = t.waktuBayar;

            if (tDate == null) return false;

            return tDate.year == month.year && tDate.month == month.month;
          });

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label),

                Chip(
                  label: Text(sudahBayar ? "Lunas" : "Belum"),
                  backgroundColor: sudahBayar ? Colors.green : Colors.red,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

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

  List<DateTime> generateMonths(DateTime start) {
    final now = DateTime.now();
    final months = <DateTime>[];

    var current = DateTime(start.year, start.month);

    while (current.isBefore(DateTime(now.year, now.month + 1))) {
      months.add(current);

      current = DateTime(current.year, current.month + 1);
    }

    return months;
  }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.blue),

          const SizedBox(width: 8),

          Expanded(
            child: Text(text, softWrap: true, overflow: TextOverflow.visible),
          ),
        ],
      ),
    );
  }
}
