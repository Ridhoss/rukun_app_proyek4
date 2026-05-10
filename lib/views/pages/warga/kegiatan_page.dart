import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/kegiatan_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/status_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/warga/kegiatan/kegiatan_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/warga/home_page.dart';

class KegiatanPage extends StatelessWidget {
  const KegiatanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KegiatanViewmodel()..loadDummy(),
      child: Scaffold(
        appBar: AppBarUtils.buildAppBar(
          name: "",
          title: "Kegiatan",
          subtitle: "Daftar kegiatan warga",
          showName: false,
          showAvatar: false,
          showGreeting: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WargaHomePage()),
            ),
          ),
        ),
        body: Consumer<KegiatanViewmodel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.errorMessage != null) {
              return Center(child: Text(vm.errorMessage!));
            }

            return _list(vm);
          },
        ),
      ),
    );
  }

  Widget _list(KegiatanViewmodel vm) {
    if (vm.data.isEmpty) {
      return const Center(child: Text("Tidak ada kegiatan"));
    }

    return ListView.builder(
      itemCount: vm.data.length,
      itemBuilder: (context, i) => _card(vm.data[i]),
    );
  }

  Widget _card(Kegiatan item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: ColorsUtils.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: ColorsUtils.b200.withOpacity(0.20),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // garis kiri (status color)
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: item.statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _badge(item.statusLabel, item.statusColor),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // DESKRIPSI
                    if (item.deskripsi != null && item.deskripsi!.isNotEmpty)
                      Text(
                        item.deskripsi!,
                        style: TextStyle(color: Colors.grey[700]),
                      ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _infoItem(
                          Icons.calendar_today,
                          _tanggal(item),
                          Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _infoItem(
                          Icons.groups,
                          item.level == KegiatanLevel.rt ? "RT" : "RW",
                          Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  String _tanggal(Kegiatan k) {
    if (k.tanggalSelesai != null) {
      return "${k.tanggalMulai.day}/${k.tanggalMulai.month} - ${k.tanggalSelesai!.day}/${k.tanggalSelesai!.month}";
    }
    return "${k.tanggalMulai.day}/${k.tanggalMulai.month}";
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
