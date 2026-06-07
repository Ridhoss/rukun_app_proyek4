import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/kas_mutasi_model.dart';
import 'package:rukun_app_proyek4/models/rt_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/rt/rt_dashboard_viewmodel.dart';

class RtKasCard extends StatelessWidget {
  final double saldo;
  final double masuk;
  final double keluar;
  final RtModel rt;

  const RtKasCard({
    super.key,
    required this.saldo,
    required this.masuk,
    required this.keluar,
    required this.rt,
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
    return Stack(
      children: [
        Container(
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
              const Text(
                "Saldo Kas RT",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 8),

              Text(
                rupiah(saldo),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _item("Kas Masuk", "+ ${rupiah(masuk)}", Colors.greenAccent),
                  _item("Kas Keluar", "- ${rupiah(keluar)}", Colors.redAccent),
                  const _ItemStatic("Diperbarui", "Hari Ini", Colors.white70),
                ],
              ),
            ],
          ),
        ),

        // titik 3 kanan atas
        Positioned(
          top: 0,
          right: 0,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              showKasModal(
                context,
                title: value == 'masuk' ? 'Kas Masuk' : 'Kas Keluar',
              );
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'masuk', child: Text('Kas Masuk')),
              PopupMenuItem(value: 'keluar', child: Text('Kas Keluar')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void showKasModal(BuildContext context, {required String title}) {
    final nominalController = TextEditingController();
    final keteranganController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nominal',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: keteranganController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsUtils.b300,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              final nominal = int.tryParse(
                                nominalController.text.replaceAll('.', ''),
                              );

                              if (nominal == null) return;

                              setState(() => isLoading = true);

                              final vm = modalContext
                                  .read<RtDashboardViewModel>();

                              final kas = KasMutasi(
                                level: KasLevel.rt,
                                tipe: title == "Kas Masuk"
                                    ? KasTipe.masuk
                                    : KasTipe.keluar,
                                nominal: nominal,
                                keterangan: keteranganController.text,
                                rwId: rt.rwId,
                                rtId: rt.id,
                              );

                              try {
                                final result = await vm.tambahKas(kas: kas);

                                if (result != null) {
                                  NotificationUtils.showError(context, result);
                                  return;
                                }

                                if (!modalContext.mounted) return;

                                Navigator.pop(modalContext);

                                NotificationUtils.showSuccess(
                                  context,
                                  "Kas berhasil ditambahkan",
                                );
                              } catch (e) {
                                NotificationUtils.showError(
                                  context,
                                  "Gagal menambahkan kas",
                                );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Simpan"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ItemStatic extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ItemStatic(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
