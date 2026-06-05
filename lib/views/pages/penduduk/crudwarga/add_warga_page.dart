import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/keluarga_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/penduduk/warga/add_warga_viewmodel.dart';
import 'package:rukun_app_proyek4/views/widgets/scan_ktp_widget.dart';

class AddWargaPage extends StatelessWidget {
  final Keluarga keluarga;

  const AddWargaPage({super.key, required this.keluarga});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddWargaViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBarUtils.buildAppBar(
        context: context,
        name: "",
        title: "Tambah Data Warga",
        subtitle: "Halaman tambah data warga baru",
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        children: [
          _header(),

          const SizedBox(height: 16),

          // Scan KTP Section
          _buildSection(
            'Scan KTP',
            Icons.document_scanner_outlined,
            ScanKTPWidget(
              onConfirmed: ({String? nik}) {
                vm.applyScanResults(scannedNik: nik);
              },
            ),
          ),

          const SizedBox(height: 16),

          _buildSection(
            'Data Pribadi',
            Icons.person_outline,
            _dataPribadi(context, vm),
          ),
          _buildSection(
            'Data Identitas',
            Icons.badge_outlined,
            _dataIdentitas(vm),
          ),
          _buildSection(
            'Status Perkawinan',
            Icons.favorite_border,
            _dataPerkawinan(context, vm),
          ),
          _buildSection(
            'Kewarganegaraan',
            Icons.public,
            _dataKewarganegaraan(vm),
          ),
          _buildSection(
            'Data Keluarga',
            Icons.family_restroom,
            _dataKeluarga(vm),
          ),
        ],
      ),

      bottomNavigationBar: _bottomBar(context, vm),
    );
  }

  Widget _header() {
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
            child: const Icon(Icons.person_add, color: ColorsUtils.b500),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Lengkapi data warga dengan benar sesuai dokumen resmi',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: ColorsUtils.b500),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _dataPribadi(BuildContext context, AddWargaViewModel vm) {
    return Column(
      children: [
        _textField('Nama Lengkap', controller: vm.namaController, onChanged: vm.setNama),
        _textField('NIK', controller: vm.nikController, keyboard: TextInputType.number, onChanged: vm.setNik),

        _dropdown(
          'Jenis Kelamin',
          ['Laki-Laki', 'Perempuan'],
          value: vm.jenisKelamin,
          onChanged: vm.setJenisKelamin,
        ),

        Row(
          children: [
            Expanded(
              child: _textField('Tempat Lahir', controller: vm.tempatLahirController, onChanged: vm.setTempatLahir),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dateField(
                context,
                'Tanggal Lahir',
                vm.tanggalLahir,
                vm.setTanggalLahir,
              ),
            ),
          ],
        ),
      ].withSpacing(),
    );
  }

  Widget _dataIdentitas(AddWargaViewModel vm) {
    return Column(
      children: [
        _dropdown(
          'Agama',
          ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'],
          value: vm.agama,
          onChanged: vm.setAgama,
        ),

        _dropdown(
          'Pendidikan',
          ['SD', 'SMP', 'SMA', 'D3', 'S1', 'S2', 'S3'],
          value: vm.pendidikan,
          onChanged: vm.setPendidikan,
        ),

        _textField('Pekerjaan', controller: vm.pekerjaanController, onChanged: vm.setPekerjaan),

        _dropdown(
          'Golongan Darah',
          ['A', 'B', 'AB', 'O'],
          value: vm.golonganDarah,
          onChanged: vm.setGolDarah,
        ),
      ].withSpacing(),
    );
  }

  Widget _dataPerkawinan(BuildContext context, AddWargaViewModel vm) {
    return Column(
      children: [
        _dropdown(
          'Status Perkawinan',
          ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'],
          value: vm.statusPerkawinan,
          onChanged: vm.setStatusPerkawinan,
        ),

        _dateField(
          context,
          'Tanggal Perkawinan',
          vm.tanggalPerkawinan,
          vm.setTanggalPerkawinan,
        ),
      ].withSpacing(),
    );
  }

  Widget _dataKewarganegaraan(AddWargaViewModel vm) {
    return Column(
      children: [
        _dropdown(
          'Kewarganegaraan',
          ['WNI', 'WNA'],
          value: vm.kewarganegaraan,
          onChanged: vm.setKewarganegaraan,
        ),

        if (vm.kewarganegaraan == 'WNA')
          _textField('Negara Asal', onChanged: vm.setNegara),

        _textField('No. Paspor'),
        _textField('No. KITAP'),
      ].withSpacing(),
    );
  }

  Widget _dataKeluarga(AddWargaViewModel vm) {
    return Column(
      children: [
        _dropdown(
          'Status Hubungan',
          [
            'Kepala Keluarga',
            'Suami',
            'Istri',
            'Anak',
            'Orang Tua',
            'Cucu',
            'Cicit',
            'Menantu',
            'Mertua',
            'Famili Lain',
          ],
          value: vm.statusHubungan,
          onChanged: vm.setStatusHubungan,
        ),

        _textField('Nama Ayah', onChanged: (v) => vm.namaAyah = v),
        _textField('Nama Ibu', onChanged: (v) => vm.namaIbu = v),
      ].withSpacing(),
    );
  }

  Widget _dateField(
    BuildContext context,
    String label,
    DateTime? value,
    Function(DateTime) onPick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),

        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );

            if (picked != null) {
              onPick(picked);
            }
          },

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDDE3ED)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null
                        ? 'Pilih tanggal'
                        : "${value.day}/${value.month}/${value.year}",
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomBar(BuildContext context, AddWargaViewModel vm) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: ColorsUtils.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: ElevatedButton(
          onPressed: vm.isSaving
              ? null
              : () async {
                  await vm.saveWarga(keluarga);

                  if (vm.errorMessage != null) {
                    NotificationUtils.showError(context, vm.errorMessage!);
                  } else {
                    NotificationUtils.showSuccess(
                      context,
                      "Warga berhasil disimpan",
                    );

                    Navigator.pop(context, true);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsUtils.b500,
            foregroundColor: ColorsUtils.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Simpan Data Warga',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  InputDecoration _input() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDE3ED)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDE3ED)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorsUtils.b500, width: 1.5),
      ),
      filled: true,
      fillColor: ColorsUtils.white,
    );
  }

  Widget _dropdown(
    String label,
    List<String> items, {
    String? value,
    Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: items.contains(value) ? value : null,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: _input(),
          hint: Text('Pilih $label'),
        ),
      ],
    );
  }

  Widget _textField(
    String label, {
    TextEditingController? controller,
    TextInputType keyboard = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          onChanged: onChanged,
          decoration: _input(),
        ),
      ],
    );
  }
}

extension Spacing on List<Widget> {
  List<Widget> withSpacing([double space = 14]) {
    return expand((widget) => [widget, SizedBox(height: space)]).toList()
      ..removeLast();
  }
}
