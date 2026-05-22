import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';
import 'package:rukun_app_proyek4/utils/status_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/roles/warga/surat/pengajuan_surat_viewmodel.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/views/pages/roles/warga/surat/tambah_surat_page.dart';
import 'package:rukun_app_proyek4/views/pages/roles/warga/surat/widgets/detail_pengajuan_surat_modal.dart';

class PengajuanSuratPage extends StatefulWidget {
  final User user;

  const PengajuanSuratPage({super.key, required this.user});

  @override
  State<PengajuanSuratPage> createState() => _PengajuanSuratPageState();
}

class _PengajuanSuratPageState extends State<PengajuanSuratPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<PengajuanSuratViewModel>().fetchSuratSaya();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final nama = authVM.currentUser?.warga?.nama ?? "-";

    return Scaffold(
      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: nama,
        title: "Pengajuan Surat",
        subtitle: "Ajukan surat anda",
        showName: false,
        showAvatar: false,
        showGreeting: false,
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TambahSuratPage(user: widget.user),
            ),
          );

          if (result == true && context.mounted) {
            await context.read<PengajuanSuratViewModel>().fetchSuratSaya();

            NotificationUtils.showSuccess(context, "Pengajuan surat berhasil");
          }
        },
        backgroundColor: ColorsUtils.b400,
        foregroundColor: ColorsUtils.white,
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
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsUtils.lightgray, width: 1.5),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
            color: ColorsUtils.b300.withOpacity(0.10),
          ),
        ],
      ),
      child: Row(
        children: [
          _item(vm.totalDiajukan, "Diajukan"),
          _divider(),
          _item(vm.totalDisetujui, "Disetujui"),
          _divider(),
          _item(vm.totalDitolak, "Ditolak"),
          _divider(),
          _item(vm.totalSelesai, "Selesai"),
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
          Text(title, style: TextStyle(color: ColorsUtils.darkgray)),
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
            _chip(vm, "Diajukan", FilterSurat.diajukan),
            _chip(vm, "Disetujui", FilterSurat.disetujui),
            _chip(vm, "Ditolak", FilterSurat.ditolak),
            _chip(vm, "Selesai", FilterSurat.selesai),
          ],
        ),
      ),
    );
  }

  Widget _chip(PengajuanSuratViewModel vm, String text, FilterSurat filter) {
    final selected = vm.selectedFilter == filter;

    return GestureDetector(
      onTap: () => vm.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? ColorsUtils.b300 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _list(PengajuanSuratViewModel vm) {
    if (vm.list.isEmpty) {
      return const Center(child: Text("Belum ada pengajuan surat"));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: vm.filteredList.length,
      itemBuilder: (context, i) {
        final item = vm.filteredList[i];
        return _card(context, item);
      },
    );
  }

  bool _isActionable(SuratStatus status) {
    return status == SuratStatus.disetujui || status == SuratStatus.selesai;
  }

  Widget _card(BuildContext context, PengajuanSurat item) {
    final ui = item.status.ui;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: ColorsUtils.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 3),
            color: ColorsUtils.gray.withOpacity(0.08),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: ui.color,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.keperluan,
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
                      item.keterangan ?? '-',
                      style: TextStyle(color: ColorsUtils.darkgray),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      item.waktuDibuat != null
                          ? _formatDate(item.waktuDibuat!)
                          : "-",
                      style: TextStyle(
                        color: ColorsUtils.darkgray,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (_isActionable(item.status))
                      Align(
                        alignment: Alignment.centerRight,
                        child: _actionIcon(context, item),
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

  Widget _actionIcon(BuildContext context, PengajuanSurat item) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: ColorsUtils.darkgray,
          builder: (_) {
            return DetailPengajuanSuratModal(item: item);
          },
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.visibility, size: 18, color: ColorsUtils.b300),
            SizedBox(width: 6),
            Text(
              "Lihat Detail",
              style: TextStyle(
                color: ColorsUtils.b200,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(SuratStatus status) {
    final ui = status.ui;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ui.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        ui.label,
        style: const TextStyle(color: ColorsUtils.white, fontSize: 12),
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}-${d.month}-${d.year}";
}
