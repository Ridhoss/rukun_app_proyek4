import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/penduduk/kartukeluarga/add_kk_viewmodel.dart';
import 'package:rukun_app_proyek4/views/widgets/scan_kk_widget.dart';

class AddKKPage extends StatelessWidget {
  const AddKKPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddKKViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: "",
        title: "Tambah Kartu Keluarga",
        subtitle: "Halaman tambah kartu keluarga baru",
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),

          const SizedBox(height: 16),

          _buildScanCard(vm),

          const SizedBox(height: 16),

          _buildFormCard(vm),

          const SizedBox(height: 16),

          _buildSaveButton(context, vm),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: ColorsUtils.b50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.credit_card, color: ColorsUtils.b500),
          ),
          const SizedBox(width: 16),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tambah Data",
                style: TextStyle(fontSize: 12, color: ColorsUtils.gray),
              ),
              SizedBox(height: 4),
              Text(
                "Kartu Keluarga",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorsUtils.b400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard(AddKKViewModel vm) {
    return _buildCard(
      header: _buildSectionHeader('Scan Kartu Keluarga', Icons.document_scanner_outlined),
      child: ScanKKWidget(
        onConfirmed: ({String? noKK, String? alamat, String? kodePos, fotoKK}) {
          vm.applyScanResults(
            scannedNoKK: noKK,
            scannedAlamat: alamat,
            scannedKodePos: kodePos,
            scannedFoto: fotoKK,
          );
        },
      ),
    );
  }

  Widget _buildFormCard(AddKKViewModel vm) {
    return _buildCard(
      header: _buildSectionHeader('Data Kartu Keluarga', Icons.home_outlined),
      child: Column(
        children: [
          TextFormField(
            controller: vm.noKKController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'No KK',
              hintText: 'Masukkan 16 digit nomor KK',
            ),
            onChanged: (value) => vm.noKK = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'No KK wajib diisi';
              }
              final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
              if (cleaned.length != 16) {
                return 'No KK harus 16 digit';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: vm.alamatController,
            decoration: const InputDecoration(
              labelText: 'Alamat',
              hintText: 'Masukkan alamat lengkap',
            ),
            onChanged: (value) => vm.alamat = value,
            maxLines: 2,
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: vm.kodePosController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Kode Pos',
              hintText: 'Masukkan 5 digit kode pos',
            ),
            onChanged: (value) => vm.kodePos = value,
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length != 5) {
                return 'Kode Pos harus 5 digit';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildFotoKK(vm),
        ],
      ),
    );
  }

  Widget _buildFotoKK(AddKKViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Foto Kartu Keluarga",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 10),

        GestureDetector(
          onTap: vm.pickFotoKK,
          child: Container(
            width: double.infinity,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorsUtils.b500),
              color: vm.fotoKK == null
                  ? const Color(0xFFF9FAFB)
                  : Colors.transparent,
            ),
            child: vm.fotoKK == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, size: 40),
                      SizedBox(height: 8),
                      Text("Upload Foto KK"),
                      SizedBox(height: 4),
                      Text("Format JPG/PNG", style: TextStyle(fontSize: 11)),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          vm.fotoKK!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // overlay edit
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, AddKKViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: vm.isSaving
            ? null
            : () async {
                await vm.createKK();

                if (vm.errorMessage != null) {
                  NotificationUtils.showError(context, vm.errorMessage!);
                } else {
                  NotificationUtils.showSuccess(
                    context,
                    "Kartu Keluarga berhasil disimpan",
                  );
                  Navigator.pop(context);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsUtils.b500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: vm.isSaving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Simpan Kartu Keluarga',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildCard({required Widget header, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          header,
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [Icon(icon), const SizedBox(width: 8), Text(title)]),
    );
  }
}
