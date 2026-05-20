import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/rt/rt_dashboard_viewmodel.dart';

class RtHomePage extends StatefulWidget {
  const RtHomePage({super.key});

  @override
  State<RtHomePage> createState() => _RtHomePageState();
}

class _RtHomePageState extends State<RtHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      final rtId = authVM.currentUser?.rt?.id ?? 1;

      context.read<RtDashboardViewModel>().fetchDashboard(rtId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final namaUser = authVM.currentUser?.warga?.nama ?? "Ketua RT";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<RtDashboardViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text("Error: ${viewModel.errorMessage}"));
            }

            final data = viewModel.dashboardData;

            if (data == null) {
              return const Center(child: Text("Data belum tersedia"));
            }

            // Hitung persentase gender secara dinamis untuk progress bar
            final int totalGender = data.totalWanita + data.totalPria;
            final double progressWanita = totalGender > 0 ? data.totalWanita / totalGender : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER GREETING
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selamat Pagi,",
                            style: TextStyle(fontSize: 16, color: ColorsUtils.darkgray),
                          ),
                          Text(
                            namaUser,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: ColorsUtils.black800,
                            ),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 2. KAS CARD (GRADIENT)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [ColorsUtils.b300, ColorsUtils.b500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Saldo Kas RT",
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(data.saldoKas,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _kasInfo("Kas Masuk", data.kasMasuk),
                            _kasInfo("Kas Keluar", data.kasKeluar),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                Text("Diperbarui",
                                    style: TextStyle(color: Colors.white60, fontSize: 10)),
                                Text("Hari Ini",
                                    style: TextStyle(color: Colors.white, fontSize: 11)),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 3. STATS GRID (2x2)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.6,
                    children: [
                      _statCard("Total Penduduk", data.totalPenduduk.toString()),
                      _statCard("Jumlah KK", data.jumlahKk.toString()),
                      _statCard("Surat Pending", data.suratPending.toString()),
                      _statCard("Surat Diproses", data.suratDiproses.toString()),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 4. DEMOGRAFI UMUM (GENDER DINAMIS)
                  const Text("Demografi Umum",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.female, color: Colors.pink, size: 18),
                      Text(" Wanita (${data.totalWanita})", style: const TextStyle(fontSize: 13)),
                      const Spacer(),
                      Text("Pria (${data.totalPria}) ", style: const TextStyle(fontSize: 13)),
                      const Icon(Icons.male, color: ColorsUtils.b300, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressWanita,
                      minHeight: 10,
                      backgroundColor: ColorsUtils.b200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 5. BERDASARKAN USIA (DINAMIS)
                  const Text("Berdasarkan Usia",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _ageRow(Icons.child_care, "Anak", "(0-15 tahun)", data.totalAnak.toString()),
                  _ageRow(Icons.accessibility_new, "Usia Produktif", "(15-64 tahun)", data.totalProduktif.toString()),
                  _ageRow(Icons.elderly, "Lansia", "(>64 tahun)", data.totalLansia.toString()),
                  const SizedBox(height: 30),

                  // 6. KEGIATAN BERLANGSUNG
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: ColorsUtils.b300),
                      const SizedBox(width: 10),
                      const Text("Kegiatan Berlangsung",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Bagian Kegiatan (Bisa diekspansi menggunakan List dari API ke depannya)
                  _kegiatanCard(
                    status: "BERLANGSUNG",
                    statusColor: ColorsUtils.green,
                    title: "Kerja Bakti Bersih RT 02",
                    desc: "Kegiatan membersihkan lingkungan RT 02 yang mencakup seluruh blok...",
                    date: "11 - 15 Mei 2026",
                  ),
                  _kegiatanCard(
                    status: "UPCOMING",
                    statusColor: ColorsUtils.b300,
                    title: "Pelatihan Pupuk Kompos",
                    desc: "Kegiatan pelatihan pembuatan pupuk dari sampah organik untuk warga...",
                    date: "20 - 24 Mei 2026",
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _kasInfo(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        Text(amount,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: ColorsUtils.gray, fontSize: 13)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _ageRow(IconData icon, String label, String range, String count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorsUtils.b300),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 5),
            Text(range, style: const TextStyle(color: ColorsUtils.gray, fontSize: 12)),
            const Spacer(),
            Text(count,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _kegiatanCard({
    required String status,
    required Color statusColor,
    required String title,
    required String desc,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(status,
                style: TextStyle(
                    color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(desc,
              style: const TextStyle(color: ColorsUtils.gray, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Text(date,
              style: const TextStyle(color: ColorsUtils.darkgray, fontSize: 12)),
        ],
      ),
    );
  }
}