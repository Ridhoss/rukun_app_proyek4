import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/iuransaya_model.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repostiory.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/warga/iuranwarga_viewmodel.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';
import 'package:rukun_app_proyek4/models/iuran_model.dart';
import 'package:rukun_app_proyek4/utils/status_utils.dart';
import 'package:rukun_app_proyek4/views/pages/warga/home_page.dart';
import 'package:rukun_app_proyek4/views/pages/warga/warga_upload_iuran_page.dart';

class WargaIuranPage extends StatelessWidget {
  const WargaIuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nama = context.watch<AuthViewModel>().currentUser?.warga?.nama ?? "-";

    return ChangeNotifierProvider(
      create: (_) =>
          IuranwargaViewmodel(context.read<IuranRepository>())..loadIuranSaya(),
      child: Scaffold(
        appBar: AppBarUtils.buildAppBar(
          name: nama,
          title: "Iuran Saya",
          subtitle: "Kelola & lihat pembayaran",
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
        body: Consumer<IuranwargaViewmodel>(
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
                _typeToggle(vm),
                _statusFilter(vm),

                const SizedBox(height: 15),

                Expanded(child: _list(vm)),
              ],
            );
          },
        ),
      ),
    );
  }

  //summary status dan total bayar dari setiap status
  Widget _summary(IuranwargaViewmodel vm) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.8),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
            color: ColorsUtils.b300.withOpacity(0.09),
          ),
        ],
      ),
      child: Row(
        children: [
          _item(vm.totalDibayar, "Dibayar"),
          _divider(),
          _item(vm.totalBelum, "Belum"),
          _divider(),
          _item(vm.totalKeseluruhan, "Total"),
        ],
      ),
    );
  }

  //text color summary
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

  // pembatas antar item summary
  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color.fromARGB(255, 78, 59, 59),
    );
  }

  // toggle type iuran
  Widget _typeToggle(IuranwargaViewmodel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _typeItem(vm, "Reguler", IuranType.wajib),
            _typeItem(vm, "Insidentil", IuranType.sedekah),
          ],
        ),
      ),
    );
  }

  // type toggle item
  Widget _typeItem(IuranwargaViewmodel vm, String text, IuranType type) {
    final selected = vm.selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => vm.setType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? ColorsUtils.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // status filter
  Widget _statusFilter(IuranwargaViewmodel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(vm, "Semua", FilterStatus.semua),
            _chip(vm, "Tagihan", FilterStatus.belumDibayar),
            _chip(vm, "Diproses", FilterStatus.diproses),
            _chip(vm, "Dibayar", FilterStatus.dibayar),
            _chip(vm, "Ditolak", FilterStatus.ditolak),
          ],
        ),
      ),
    );
  }

  // chip status filter
  Widget _chip(IuranwargaViewmodel vm, String text, FilterStatus status) {
    final selected = vm.selectedStatus == status;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => vm.setStatus(status),
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

  Widget _list(IuranwargaViewmodel vm) {
    if (vm.data.isEmpty) {
      return const Center(child: Text("Tidak ada data iuran"));
    }

    return ListView.builder(
      itemCount: vm.data.length,
      itemBuilder: (context, i) => _card(context, vm.data[i]),
    );
  }

  // card item iuran dengan transaksi
  Widget _card(BuildContext context, IuranSaya item) {
    final trx = item.transaksiTerbaru;
    final status = trx?.status ?? StatusPembayaran.belumDibayar;

    final isRejected = trx?.status == StatusPembayaran.ditolak;

    final canUpload =
        trx == null ||
        trx.status == StatusPembayaran.belumDibayar ||
        trx.status == StatusPembayaran.ditolak;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: ColorsUtils.white,
        boxShadow: [
          BoxShadow(
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
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: status.color,
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
                            item.iuran.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _badge(status),
                      ],
                    ),

                    const SizedBox(height: 6),

                    if (item.iuran.jumlah != null)
                      Text(
                        "Rp ${item.iuran.jumlah!.toString()}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 6),

                    // INFO
                    Row(
                      children: [
                        _infoItem(
                          Icons.holiday_village,
                          _levelLabel(item.iuran.level),
                          Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _infoItem(
                          Icons.groups,
                          _scopeLabel(item.iuran.cakupan),
                          Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _infoItem(
                          Icons.calendar_month,
                          _periodeLabel(item.iuran.periode),
                          Colors.orange,
                        ),
                      ],
                    ),

                    // REJECT NOTE
                    if (isRejected &&
                        item.iuran.catatan != null &&
                        item.iuran.catatan!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.iuran.catatan!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // BUTTON
                    if (canUpload)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRejected
                                ? Colors.red
                                : Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WargaUploadIuranPage(item: item),
                              ),
                            );
                          },
                          icon: const Icon(Icons.upload),
                          label: Text(
                            isRejected ? "Upload Ulang" : "Upload Bukti",
                          ),
                        ),
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
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String _levelLabel(IuranLevel level) {
    switch (level) {
      case IuranLevel.rt:
        return "RT";
      case IuranLevel.rw:
        return "RW";
    }
  }

  String _scopeLabel(IuranScope scope) {
    switch (scope) {
      case IuranScope.keluarga:
        return "Keluarga";
      case IuranScope.warga:
        return "Per Warga";
    }
  }

  String _periodeLabel(PeriodeType periode) {
    switch (periode) {
      case PeriodeType.bulanan:
        return "Bulanan";
      case PeriodeType.sekali:
        return "Sekali";
    }
  }

  // badge status pembayaran
  Widget _badge(StatusPembayaran status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
