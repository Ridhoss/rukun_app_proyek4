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
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          _buildSection('Data Pribadi', Icons.person_outline, _dataPribadi()),
          const SizedBox(height: 16),

          _buildSection('Data Identitas', Icons.badge_outlined, _dataIdentitas()),
          const SizedBox(height: 16),

          _buildSection('Status Perkawinan', Icons.favorite_border, _dataPerkawinan()),
          const SizedBox(height: 16),

          _buildSection('Kewarganegaraan & Dokumen', Icons.article_outlined, _dataKewarganegaraan()),
          const SizedBox(height: 16),

          _buildSection('Data Keluarga', Icons.family_restroom, _dataKeluarga()),
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _dataPribadi() {
    return Column(
      children: [
        _textField('Nama Lengkap'),
        const SizedBox(height: 14),

        _textField('NIK', keyboard: TextInputType.number),
        const SizedBox(height: 14),

        _dropdown('Jenis Kelamin', ['Laki-Laki', 'Perempuan']),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(child: _textField('Tempat Lahir')),
            const SizedBox(width: 12),
            Expanded(child: _dateField('Tanggal Lahir')),
          ],
        ),
      ],
    );
  }

  Widget _dataIdentitas() {
    return Column(
      children: [
        _dropdown('Agama', [
          'Islam','Kristen','Katolik','Hindu','Buddha','Konghucu'
        ]),
        const SizedBox(height: 14),

        _dropdown('Pendidikan', [
          'SD','SMP','SMA','D3','S1','S2','S3'
        ]),
        const SizedBox(height: 14),

        _dropdown('Pekerjaan', [
          'Belum Bekerja','Pelajar','Karyawan','Wiraswasta'
        ]),
        const SizedBox(height: 14),

        _dropdown('Golongan Darah', ['A','B','AB','O']),
      ],
    );
  }

  Widget _dataPerkawinan() {
    return Column(
      children: [
        _dropdown('Status Perkawinan', [
          'Belum Kawin','Kawin','Cerai Hidup','Cerai Mati'
        ]),
        const SizedBox(height: 14),

        _dateField('Tanggal Perkawinan'),
      ],
    );
  }

  Widget _dataKewarganegaraan() {
    return Column(
      children: [
        _dropdown('Kewarganegaraan', ['WNI','WNA']),
        const SizedBox(height: 14),

        _textField('No. Paspor'),
        const SizedBox(height: 14),

        _textField('No. KITAP'),
      ],
    );
  }

  Widget _dataKeluarga() {
    return Column(
      children: [
        _dropdown('Status Hubungan', [
          'Kepala Keluarga','Suami','Istri','Anak','Menantu',
          'Cucu','Orang Tua','Mertua','Famili Lain'
        ]),
        const SizedBox(height: 14),

        _textField('Nama Ayah'),
        const SizedBox(height: 14),

        _textField('Nama Ibu'),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _textField(String label, {TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboard,
          decoration: _input(),
        ),
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
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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

  Widget _bottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsUtils.b500,
            foregroundColor: ColorsUtils.white
          ),
          child: const Text('Simpan Data'),
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
}