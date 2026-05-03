import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/kartukeluarga/add_kk_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/rt/penduduk/add_warga_page.dart';

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

          if (vm.isKKSaved)
            _buildAfterSaved(context, vm)
          else
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
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
            decoration: const InputDecoration(labelText: 'Kode Pos'),
            onChanged: (value) => vm.kodePos = value,
          ),
        ],
      ),
    );
  }

  Widget _buildAfterSaved(BuildContext context, AddKKViewModel vm) {
    return Column(
      children: [
        _buildCard(
          header: _buildSectionHeader('Anggota Keluarga', Icons.people_outline),
          child: Column(
            children: [
              const Text('KK berhasil disimpan'),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddWargaPage()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorsUtils.b500),
                  ),
                  child: const Center(
                    child: Text(
                      'Tambah Anggota',
                      style: TextStyle(
                        color: ColorsUtils.b500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
