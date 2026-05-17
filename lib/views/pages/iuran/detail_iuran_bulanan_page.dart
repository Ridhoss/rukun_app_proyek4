import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/models/iuran/keluarga_status_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/iuran/iuran_bulanan_detail_viewmodel.dart';

class DetailIuranBulananPage extends StatefulWidget {
  final int iuranId;
  final int rtId;
  final DateTime month;

  const DetailIuranBulananPage({
    super.key,
    required this.iuranId,
    required this.rtId,
    required this.month,
  });

  @override
  State<DetailIuranBulananPage> createState() => _DetailIuranBulananPageState();
}

class _DetailIuranBulananPageState extends State<DetailIuranBulananPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<IuranBulananDetailViewModel>().fetchDetail(
        widget.iuranId,
        widget.rtId,
        widget.month,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(widget.month);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: "",
        title: "Detail Bulan",
        subtitle: monthLabel,
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),

      body: Consumer<IuranBulananDetailViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(child: Text(vm.errorMessage!));
          }

          final iuran = vm.iuran;
          final rt = vm.rtDetail;

          if (iuran == null || rt == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final list = vm.getKeluargaStatus(widget.month, widget.iuranId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryCard(iuran, vm.totalTerkumpul),

                const SizedBox(height: 16),

                _buildInfoGrid(iuran),

                const SizedBox(height: 16),

                _buildRtInfo(rt),

                const SizedBox(height: 16),

                _buildMonthCard(widget.month),

                const SizedBox(height: 16),

                _buildKKList(list),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(Iuran iuran, int terkumpul) {
    return _card(
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
              _badge(iuran.level.name.toUpperCase(), Colors.grey),
              const SizedBox(width: 8),
              _badge(iuran.tipe.name.toUpperCase(), Colors.green),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniStat(title: "Terkumpul", value: "Rp $terkumpul"),
              _MiniStat(title: "Iuran", value: "Rp ${iuran.jumlah}"),
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

  Widget _buildMonthCard(DateTime month) {
    final label = DateFormat('MMMM yyyy', 'id_ID').format(month);

    return _card(
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            "Periode: $label",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildKKList(List<KeluargaStatus> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Daftar Keluarga RT",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        ...list.map((k) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k.keluarga.noKK,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  k.sudahBayar ? "LUNAS" : "BELUM",
                  style: TextStyle(
                    color: k.sudahBayar ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                if (k.sudahBayar) ...[
                  Text("Rp ${k.nominal}"),
                  Text(
                    "Tanggal Bayar: ${k.waktuBayar == null ? '-' : DateFormat('dd MMMM yyyy', 'id_ID').format(k.waktuBayar!)}",
                  ),

                  Text("Disetujui oleh: ${k.disetujuiOleh ?? '-'}"),

                  const SizedBox(height: 10),

                  if (k.imgBukti != null && k.imgBukti!.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: Image.network(
                                k.imgBukti!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text("Gagal memuat gambar"),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("Lihat Bukti"),
                    ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _badge(String text, Color color) {
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
        Text(title, style: const TextStyle(fontSize: 12)),
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
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
