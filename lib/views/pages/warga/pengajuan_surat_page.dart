import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/warga/pengajuan_surat_viewmodel.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/views/pages/warga/tambah_surat_page.dart';

class PengajuanSuratPage extends StatefulWidget {
  const PengajuanSuratPage({super.key});

  @override
  State<PengajuanSuratPage> createState() => _PengajuanSuratPageState();
}

class _PengajuanSuratPageState extends State<PengajuanSuratPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PengajuanSuratViewModel>().fetchDummy();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final nama = authVM.currentUser?.warga?.nama ?? "-";

    return Scaffold(
      appBar: AppBarUtils.buildAppBar(
        name: nama,
        title: "Pengajuan Surat",
        subtitle: "Ajukan surat anda",
        showName: false,
        showAvatar: false,
        showGreeting: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Consumer<PengajuanSuratViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(child: Text(vm.errorMessage!));
          }

          return Column(
            children: [
              _summary(vm),
              _filter(vm),
              const SizedBox(height: 10),
              Expanded(child: _list(vm)),
            ],
          );
        },
      ),

      // ✅ PINDAH KE SINI (bukan di dalam Column)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahSuratPage()),
          );

          context.read<PengajuanSuratViewModel>().fetchDummy();
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          "Ajukan Surat",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _summary(PengajuanSuratViewModel vm) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
            color: Colors.blue.withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          _item(vm.totalTertunda, "Tertunda"),
          _divider(),
          _item(vm.totalDisetujui, "Disetujui"),
          _divider(),
          _item(vm.totalDitolak, "Ditolak"),
        ],
      ),
    );
  }

  Widget _item(int value, String title) {
    return Expanded(
      child: Column(
        children: [
          Text(
            "$value",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 30, color: Colors.grey.shade300);

  Widget _filter(PengajuanSuratViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(vm, "Semua", FilterSurat.semua),
            _chip(vm, "Tertunda", FilterSurat.tertunda),
            _chip(vm, "Disetujui", FilterSurat.disetujui),
            _chip(vm, "Ditolak", FilterSurat.ditolak),
            _chip(vm, "Selesai", FilterSurat.selesai),
          ],
        ),
      ),
    );
  }
}

Widget _chip(PengajuanSuratViewModel vm, String text, FilterSurat filter) {
  final selected = vm.selectedFilter == filter;

  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: () => vm.setFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  );
}

String _labelFilter(FilterSurat f) {
  switch (f) {
    case FilterSurat.tertunda:
      return "Tertunda";
    case FilterSurat.disetujui:
      return "Disetujui";
    case FilterSurat.ditolak:
      return "Ditolak";
    case FilterSurat.selesai:
      return "Selesai";
    default:
      return "Semua";
  }
}

Widget _list(PengajuanSuratViewModel vm) {
  if (vm.list.isEmpty) {
    return const Center(child: Text("Belum ada pengajuan surat"));
  }

  return ListView.builder(
    padding: const EdgeInsets.only(bottom: 80),
    itemCount: vm.list.length,
    itemBuilder: (context, i) {
      final item = vm.list[i];
      return _card(item);
    },
  );
}

Widget _card(PengajuanSurat item) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          blurRadius: 8,
          offset: const Offset(0, 3),
          color: Colors.grey.withOpacity(0.08),
        ),
      ],
    ),
    child: IntrinsicHeight(
      child: Row(
        children: [
          // strip kiri
          Container(
            width: 5,
            decoration: BoxDecoration(
              color: _statusColor(item.status),
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
                  // title + badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.jenisSurat,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _badge(item.status),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    item.subjectKeperluan,
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item.waktuDibuat != null
                        ? _formatDate(item.waktuDibuat!)
                        : "-",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),

                  const SizedBox(height: 14),

                  _actionButton(item),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Color _statusColor(SuratStatus status) {
  switch (status) {
    case SuratStatus.disetujui:
      return Colors.green;
    case SuratStatus.ditolak:
      return Colors.red;
    case SuratStatus.selesai:
      return Colors.blue;
    default:
      return Colors.orange;
  }
}

Widget _badge(SuratStatus status) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _statusColor(status),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      _statusLabel(status),
      style: const TextStyle(color: Colors.white, fontSize: 12),
    ),
  );
}

Widget _actionButton(PengajuanSurat item) {
  switch (item.status) {
    case SuratStatus.tertunda:
      return _btn("Menunggu", Colors.orange, null);

    case SuratStatus.disetujui:
      return _btn("Lihat Surat", Colors.blue, () {});

    case SuratStatus.selesai:
      return _btn("Download", Colors.green, () {});

    case SuratStatus.ditolak:
      return _btn("Ditolak", Colors.red, null);
  }
}

Widget _btn(String text, Color color, VoidCallback? onTap) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    ),
  );
}

String _statusLabel(SuratStatus status) {
  switch (status) {
    case SuratStatus.tertunda:
      return "Tertunda";
    case SuratStatus.disetujui:
      return "Disetujui";
    case SuratStatus.ditolak:
      return "Ditolak";
    case SuratStatus.selesai:
      return "Selesai";
  }
}

String _formatDate(DateTime d) => "${d.day}-${d.month}-${d.year}";
