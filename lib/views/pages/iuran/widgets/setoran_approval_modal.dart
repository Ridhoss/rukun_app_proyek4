import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/iuran/iuran_rt_detail_viewmodel.dart';

class SetoranApprovalModal extends StatelessWidget {
  final String label;
  final DateTime month;
  final int iuranId;
  final int rtId;
  final int jumlahPembayar;
  final int totalPendapatan;
  final int saldoKasRt;
  final dynamic detailSetoran;

  const SetoranApprovalModal({
    super.key,
    required this.label,
    required this.month,
    required this.iuranId,
    required this.rtId,
    required this.jumlahPembayar,
    required this.totalPendapatan,
    required this.saldoKasRt,
    this.detailSetoran,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.read<IuranRTDetailViewModel>();

    final isApproved = detailSetoran?.status == "approved";
    final isRejected = detailSetoran?.status == "rejected";

    final String? documentUrl = detailSetoran?.documentRef;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Review Setoran $label",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // INFO CARD
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _info("Total Pembayar", "$jumlahPembayar"),
                  _info("Total Pendapatan", "Rp $totalPendapatan"),
                  _info("Saldo Kas RT", "Rp $saldoKasRt"),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // STATUS
            if (detailSetoran != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isApproved
                      ? Colors.green.withOpacity(0.1)
                      : isRejected
                      ? Colors.red.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved
                          ? Icons.check_circle
                          : isRejected
                          ? Icons.cancel
                          : Icons.hourglass_bottom,
                      color: isApproved
                          ? Colors.green
                          : isRejected
                          ? Colors.red
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Status: ${detailSetoran.status}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // FOTO BUKTI
            if (documentUrl != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bukti Setoran",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      documentUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Text("Gagal memuat gambar"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // ACTION BUTTONS
            if (detailSetoran == null)
              const Center(child: Text("Belum ada setoran dari RT"))
            else if (!isApproved && !isRejected)
              Row(
                children: [
                  // ❌ REJECT (LEFT)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        // await vm.rejectSetoran(detailSetoran.id);
                        Navigator.pop(context);
                      },
                      child: const Text("Tolak"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ✅ APPROVE (RIGHT)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: ColorsUtils.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        // await vm.approveSetoran(detailSetoran.id);
                        Navigator.pop(context);
                      },
                      child: const Text("Approve"),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: Text(
                  isApproved ? "SUDAH DIAPPROVE" : "DITOLAK",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isApproved ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
