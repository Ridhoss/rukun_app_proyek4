import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/kas_mutasi_model.dart';
import 'package:rukun_app_proyek4/models/rw_model.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/rw/dashboard/rw_dashboard_viewmodel.dart';

class RwKasCard extends StatelessWidget {
  final double saldo;
  final double masuk;
  final double keluar;
  final RwModel rw;

  const RwKasCard({
    super.key,
    required this.saldo,
    required this.masuk,
    required this.keluar,
    required this.rw,
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
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [ColorsUtils.b200, ColorsUtils.b300],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saldo Kas RW ${rw.noRw}",
                style: const TextStyle(color: ColorsUtils.white, fontSize: 13),
              ),

              const SizedBox(height: 8),

              Text(
                rupiah(saldo),
                style: const TextStyle(
                  color: ColorsUtils.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _item("Kas Masuk", rupiah(masuk), ColorsUtils.green),
                  _item("Kas Keluar", "- ${rupiah(keluar)}", ColorsUtils.red),
                  _item("Diperbarui", "20 Apr 2026", ColorsUtils.white),
                ],
              ),
            ],
          ),
        ),

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
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'masuk', child: Text('Kas Masuk')),
              const PopupMenuItem(value: 'keluar', child: Text('Kas Keluar')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(color: ColorsUtils.white, fontSize: 11),
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
            return SafeArea(
              child: SingleChildScrollView(
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
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                final nominal = int.tryParse(
                                  nominalController.text.replaceAll('.', ''),
                                );

                                if (nominal == null) {
                                  NotificationUtils.showError(
                                    context,
                                    "Nominal tidak valid",
                                  );
                                  return;
                                }

                                setState(() => isLoading = true);

                                final vm = context.read<DashboardRwViewModel>();

                                final kas = KasMutasi(
                                  level: KasLevel.rw,
                                  tipe: title == "Kas Masuk"
                                      ? KasTipe.masuk
                                      : KasTipe.keluar,
                                  nominal: nominal,
                                  keterangan: keteranganController.text,
                                  rwId: rw.id,
                                );

                                final result = await vm.tambahKas(kas: kas);

                                setState(() => isLoading = false);

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
              ),
            );
          },
        );
      },
    );
  }
}
