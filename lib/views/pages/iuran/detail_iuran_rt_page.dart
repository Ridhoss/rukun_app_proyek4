import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/iuran/iuran_rt_detail_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/iuran/detail_iuran_bulanan_page.dart';

class IuranRTDetailPage extends StatefulWidget {
  final int iuranId;
  final int rtId;
  final User user;
  final bool showSetoranButton;

  const IuranRTDetailPage({
    super.key,
    required this.iuranId,
    required this.rtId,
    required this.user,
    this.showSetoranButton = false,
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
      backgroundColor: ColorsUtils.lightgray,
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
          final iuran = vm.iuran;
          final level = widget.user.pengurus?.level.toLowerCase();
          final isRTUser = level == "rt";

          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(child: Text(vm.errorMessage!));
          }

          if (iuran == null) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final rt = vm.rtDetail;

          final transaksi = vm.transaksi;

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

                // if (canShowSetoranButton)
                //   SizedBox(
                //     width: double.infinity,
                //     child: ElevatedButton.icon(
                //       icon: const Icon(Icons.upload),
                //       label: const Text("Setoran RT ke RW"),
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.blue,
                //         foregroundColor: Colors.white,
                //       ),
                //       onPressed: () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (_) => RTSetoranRWPage(
                //               iuranId: widget.iuranId,
                //               rtId: widget.rtId,
                //               user: widget.user,
                //             ),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                _buildMonthlyList(
                  months,
                  transaksi,
                  rt?.totalKeluarga ?? 0,
                  rt?.id ?? 0,
                  iuran.id ?? 0,
                  isRTUser,
                ),
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
        color: ColorsUtils.white,
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
              _buildBadge(iuran.level.name.toUpperCase(), ColorsUtils.gray),
              const SizedBox(width: 8),
              _buildBadge(iuran.tipe.name.toUpperCase(), ColorsUtils.green),
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
        color: ColorsUtils.white,
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
        color: ColorsUtils.white,
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

  Widget _buildMonthlyList(
    List<DateTime> months,
    List<Transaksi> transaksi,
    int totalKeluarga,
    int rtId,
    int iuranId,
    bool isRTUser,
  ) {
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

          final transaksiBulan = transaksi.where((t) {
            final tDate = t.waktuBayar;
            if (tDate == null) return false;

            return tDate.year == month.year &&
                tDate.month == month.month &&
                t.status == StatusPembayaran.dibayar;
          }).toList();

          final jumlahPembayar = transaksiBulan.length;

          final totalPendapatan = transaksiBulan.fold<int>(
            0,
            (sum, item) => sum + (item.jumlah ?? 0),
          );

          final progress = "$jumlahPembayar/$totalKeluarga";

          return InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailIuranBulananPage(
                    iuranId: iuranId,
                    rtId: rtId,
                    month: month,
                    user: widget.user,
                  ),
                ),
              );

              if (context.mounted) {
                context.read<IuranRTDetailViewModel>().fetchDetail(
                  widget.iuranId,
                  widget.rtId,
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColorsUtils.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Progress: $progress"),
                      Text(
                        "Rp $totalPendapatan",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (isRTUser)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.account_balance_wallet),
                        label: const Text("Setor ke RW"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          TextEditingController jumlahController =
                              TextEditingController(
                                text: totalPendapatan.toString(),
                              );
                          TextEditingController catatanController =
                              TextEditingController();

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              TextEditingController jumlahController =
                                  TextEditingController(
                                    text: totalPendapatan.toString(),
                                  );
                              TextEditingController catatanController =
                                  TextEditingController();

                              String? fileName;

                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return Container(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(
                                        context,
                                      ).viewInsets.bottom,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // HANDLE BAR
                                            Center(
                                              child: Container(
                                                width: 50,
                                                height: 5,
                                                margin: const EdgeInsets.only(
                                                  bottom: 16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),

                                            // HEADER
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.blue.shade600,
                                                    Colors.blue.shade300,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .account_balance_wallet,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text(
                                                          "Setoran RT ke RW",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          "Kelola laporan keuangan bulanan",
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.9,
                                                                ),
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(height: 16),

                                            // PERIODE CHIP
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "Periode: $label",
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 16),

                                            // RINGKASAN CARD
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.trending_up,
                                                    color: Colors.green,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "Total Pendapatan",
                                                      ),
                                                      Text(
                                                        "Rp $totalPendapatan",
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(height: 16),

                                            // INPUT JUMLAH
                                            TextField(
                                              controller: jumlahController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: "Jumlah Setoran",
                                                prefixIcon: Icon(
                                                  Icons.payments,
                                                ),
                                                border: OutlineInputBorder(),
                                              ),
                                            ),

                                            const SizedBox(height: 12),

                                            // CATATAN
                                            TextField(
                                              controller: catatanController,
                                              decoration: const InputDecoration(
                                                labelText: "Catatan (opsional)",
                                                prefixIcon: Icon(Icons.note),
                                                border: OutlineInputBorder(),
                                              ),
                                            ),

                                            const SizedBox(height: 12),

                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Bukti Setoran",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),

                                                const SizedBox(height: 10),

                                                GestureDetector(
                                                  onTap: () async {
                                                    // TODO: image_picker / file_picker
                                                    setState(() {
                                                      fileName =
                                                          "bukti_setoran.jpg";
                                                    });
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 170,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors
                                                            .blue
                                                            .shade300,
                                                      ),
                                                      color: fileName == null
                                                          ? const Color(
                                                              0xFFF9FAFB,
                                                            )
                                                          : Colors.transparent,
                                                    ),
                                                    child: fileName == null
                                                        ? const Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .cloud_upload_outlined,
                                                                size: 40,
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Text(
                                                                "Upload Bukti Setoran",
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                "Foto / PDF / Dokumen",
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : Stack(
                                                            children: [
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                height: double
                                                                    .infinity,
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                  color: Colors
                                                                      .green
                                                                      .withOpacity(
                                                                        0.05,
                                                                      ),
                                                                ),
                                                                child: const Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .description,
                                                                        size:
                                                                            50,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        "File Terupload",
                                                                        style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),

                                                              // edit overlay (kayak AddKKPage kamu)
                                                              Positioned(
                                                                right: 8,
                                                                top: 8,
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        6,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .black54,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                  child: const Icon(
                                                                    Icons.edit,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  ),
                                                ),

                                                if (fileName != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8,
                                                        ),
                                                    child: Text(
                                                      "File: $fileName",
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),

                                            // BUTTON SUBMIT
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: ColorsUtils.b300,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "Setoran $label berhasil dikirim ke RW",
                                                        style: TextStyle(color: ColorsUtils.white),
                                                      ),
                                                      backgroundColor:
                                                          ColorsUtils.b300,
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  "Kirim Setoran",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: ColorsUtils.white
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
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
          Icon(icon, size: 16, color: ColorsUtils.b200),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
