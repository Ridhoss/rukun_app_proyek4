import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/kartukeluarga/add_kk_viewmodel.dart';

class AddKKPage extends StatelessWidget {
  const AddKKPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddKKViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: ColorsUtils.b500,
        foregroundColor: Colors.white,
        title: const Text('Tambah Kartu Keluarga'),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          _buildKKSection(vm),

          const SizedBox(height: 20),

          _buildSaveButton(context, vm),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, AddKKViewModel vm) {
    return OutlinedButton(
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
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: ColorsUtils.b500, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        foregroundColor: ColorsUtils.b500,
      ),
      child: vm.isSaving
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Simpan Kartu Keluarga',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildKKSection(AddKKViewModel vm) {
    return _buildCard(
      header: _buildSectionHeader('Data Kartu Keluarga', Icons.home_outlined),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'No KK'),
            onChanged: (value) => vm.noKK = value,
          ),

          const SizedBox(height: 10),

          TextField(
            decoration: const InputDecoration(labelText: 'Alamat'),
            onChanged: (value) => vm.alamat = value,
          ),

          const SizedBox(height: 10),

          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Kode Pos'),
            onChanged: (value) => vm.kodePos = value,
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
          onTap: () {
            vm.pickFotoKK();
          },
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorsUtils.b500),
            ),
            child: vm.fotoKK == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 40),
                        SizedBox(height: 8),
                        Text("Upload Foto KK"),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(vm.fotoKK!, fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
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
