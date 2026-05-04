import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';

class AddWargaPage extends StatelessWidget {
  const AddWargaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: ColorsUtils.b500,
        foregroundColor: ColorsUtils.white,
        elevation: 0,
        title: const Text(
          'Tambah Data Warga',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        children: [
          _header(),

          const SizedBox(height: 16),

          _buildSection('Data Pribadi', Icons.person_outline, _dataPribadi()),
          _buildSection(
            'Data Identitas',
            Icons.badge_outlined,
            _dataIdentitas(),
          ),
          _buildSection(
            'Status Perkawinan',
            Icons.favorite_border,
            _dataPerkawinan(),
          ),
          _buildSection(
            'Kewarganegaraan',
            Icons.public,
            _dataKewarganegaraan(),
          ),
          _buildSection(
            'Data Keluarga',
            Icons.family_restroom,
            _dataKeluarga(),
          ),
        ],
      ),

      bottomNavigationBar: _bottomBar(),
    );
  }

  // ================= HEADER =================
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

  // ================= SECTION =================
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

  // ================= FORM =================
  Widget _dataPribadi() {
    return Column(
      children: [
        _textField('Nama Lengkap'),
        _textField('NIK', keyboard: TextInputType.number),
        _dropdown('Jenis Kelamin', ['Laki-Laki', 'Perempuan']),

        Row(
          children: [
            Expanded(child: _textField('Tempat Lahir')),
            const SizedBox(width: 12),
            Expanded(child: _dateField('Tanggal Lahir')),
          ],
        ),
      ].withSpacing(),
    );
  }

  Widget _dataIdentitas() {
    return Column(
      children: [
        _dropdown('Agama', [
          'Islam',
          'Kristen',
          'Katolik',
          'Hindu',
          'Buddha',
          'Konghucu',
        ]),
        _dropdown('Pendidikan', ['SD', 'SMP', 'SMA', 'D3', 'S1', 'S2', 'S3']),
        _dropdown('Pekerjaan', [
          'Belum Bekerja',
          'Pelajar',
          'Karyawan',
          'Wiraswasta',
        ]),
        _dropdown('Golongan Darah', ['A', 'B', 'AB', 'O']),
      ].withSpacing(),
    );
  }

  Widget _dataPerkawinan() {
    return Column(
      children: [
        _dropdown('Status Perkawinan', [
          'Belum Kawin',
          'Kawin',
          'Cerai Hidup',
          'Cerai Mati',
        ]),
        _dateField('Tanggal Perkawinan'),
      ].withSpacing(),
    );
  }

  Widget _dataKewarganegaraan() {
    return Column(
      children: [
        _dropdown('Kewarganegaraan', ['WNI', 'WNA']),
        _textField('No. Paspor'),
        _textField('No. KITAP'),
      ].withSpacing(),
    );
  }

  Widget _dataKeluarga() {
    return Column(
      children: [
        _dropdown('Status Hubungan', [
          'Kepala Keluarga',
          'Suami',
          'Istri',
          'Anak',
        ]),
        _textField('Nama Ayah'),
        _textField('Nama Ibu'),
      ].withSpacing(),
    );
  }

  // ================= INPUT =================
  Widget _textField(
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(keyboardType: keyboard, decoration: _input()),
      ],
    );
  }

  Widget _dropdown(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (_) {},
          decoration: _input(),
          hint: Text('Pilih $label'),
        ),
      ],
    );
  }

  Widget _dateField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDE3ED)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Expanded(child: Text('Pilih tanggal')),
              Icon(Icons.calendar_today_outlined, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  // ================= BUTTON =================
  Widget _bottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: ColorsUtils.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: ElevatedButton(
          onPressed: () {},
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

  // ================= DECORATION =================
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
}

extension Spacing on List<Widget> {
  List<Widget> withSpacing([double space = 14]) {
    return expand((widget) => [widget, SizedBox(height: space)]).toList()
      ..removeLast();
  }
}
