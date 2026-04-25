import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/warga.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/warga_viewmodel.dart';

// ================================================================
// AddWargaPage
// View — StatefulWidget hanya untuk lifecycle ViewModel.
// Semua state dropdown/date ada di WargaViewModel.
// TextEditingController (state UI) tetap di State class.
// ================================================================

class AddWargaPage extends StatefulWidget {
  final int? keluargaId;
  final WargaModel? editData;

  const AddWargaPage({super.key, this.keluargaId, this.editData});

  @override
  State<AddWargaPage> createState() => _AddWargaPageState();
}

class _AddWargaPageState extends State<AddWargaPage> {
  late final WargaViewModel _vm;
  final _formKey = GlobalKey<FormState>();

  // TextEditingController = state UI (teks yang diketik user)
  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _tempatLahirCtrl = TextEditingController();
  final _noPasporCtrl = TextEditingController();
  final _noKitapCtrl = TextEditingController();
  final _namaAyahCtrl = TextEditingController();
  final _namaIbuCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = WargaViewModel();
    if (widget.editData != null) {
      final w = widget.editData!;
      _namaCtrl.text = w.nama;
      _nikCtrl.text = w.nik;
      _tempatLahirCtrl.text = w.tempatLahir;
      _noPasporCtrl.text = w.noPaspor ?? '';
      _noKitapCtrl.text = w.noKitap ?? '';
      _namaAyahCtrl.text = w.namaAyah;
      _namaIbuCtrl.text = w.namaIbu;
      _vm.populateFromModel(w); // state dropdown/date → VM
    }
  }

  @override
  void dispose() {
    _vm.dispose();
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _noPasporCtrl.dispose();
    _noKitapCtrl.dispose();
    _namaAyahCtrl.dispose();
    _namaIbuCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) => _buildScaffold(context),
    );
  }

  // ── Scaffold ───────────────────────────────────────────────────

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: ColorsUtils.b500,
        foregroundColor: ColorsUtils.white,
        elevation: 0,
        title: Text(
          widget.editData != null ? 'Edit Data Warga' : 'Tambah Data Warga',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          children: [
            _buildSection(
              'Data Pribadi',
              Icons.person_outline,
              _buildDataPribadi(),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Data Identitas',
              Icons.badge_outlined,
              _buildDataIdentitas(),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Status Perkawinan',
              Icons.favorite_border,
              _buildDataPerkawinan(),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Kewarganegaraan & Dokumen',
              Icons.article_outlined,
              _buildDataKewarganegaraan(),
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Data Keluarga',
              Icons.family_restroom,
              _buildDataKeluarga(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Handler ────────────────────────────────────────────────────

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final warga = WargaModel(
      nama: _namaCtrl.text.trim(),
      nik: _nikCtrl.text.trim(),
      jk: _vm.selectedJK!,
      tempatLahir: _tempatLahirCtrl.text.trim(),
      tglLahir: _vm.tglLahir,
      agama: _vm.selectedAgama!,
      pendidikan: _vm.selectedPendidikan!,
      jenisPekerjaan: _vm.selectedPekerjaan!,
      golonganDarah: _vm.selectedGolDarah!,
      statusPerkawinan: _vm.selectedStatusKawin!,
      tglPerkawinan: _vm.tglPerkawinan,
      statusHubungan: _vm.selectedStatusHubungan!,
      kewarganegaraan: _vm.selectedKewarganegaraan!,
      noPaspor: _noPasporCtrl.text.trim().isEmpty
          ? null
          : _noPasporCtrl.text.trim(),
      noKitap: _noKitapCtrl.text.trim().isEmpty
          ? null
          : _noKitapCtrl.text.trim(),
      namaAyah: _namaAyahCtrl.text.trim(),
      namaIbu: _namaIbuCtrl.text.trim(),
      keluargaId: widget.keluargaId,
    );

    final isEdit = widget.editData != null;
    final success = isEdit
        ? await _vm.updateWarga((widget.editData!.id ?? 0).toString(), warga)
        : await _vm.saveWarga(warga);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, warga);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data warga berhasil disimpan'),
          backgroundColor: ColorsUtils.b500,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_vm.errorMessage ?? 'Terjadi kesalahan.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate({required bool isTglLahir}) async {
    final now = DateTime.now();
    final initial = isTglLahir
        ? (_vm.tglLahir ?? DateTime(2000))
        : (_vm.tglPerkawinan ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorsUtils.b500),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      isTglLahir ? _vm.setTglLahir(picked) : _vm.setTglPerkawinan(picked);
    }
  }

  // ── Section Content Builders ───────────────────────────────────

  Widget _buildDataPribadi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          ctrl: _namaCtrl,
          label: 'Nama Lengkap',
          hint: 'Sesuai KTP',
          required: true,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          ctrl: _nikCtrl,
          label: 'NIK',
          hint: '16 digit nomor induk kependudukan',
          required: true,
          keyboardType: TextInputType.number,
          maxLength: 16,
          validator: (v) {
            if (v == null || v.isEmpty) return 'NIK wajib diisi';
            if (v.length != 16) return 'NIK harus 16 digit';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          label: 'Jenis Kelamin',
          value: _vm.selectedJK,
          items: const ['Laki-laki', 'Perempuan'],
          required: true,
          onChanged: _vm.setJK,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                ctrl: _tempatLahirCtrl,
                label: 'Tempat Lahir',
                hint: 'Kota/Kabupaten',
                required: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'Tanggal Lahir',
                value: _vm.tglLahir,
                required: true,
                onTap: () => _pickDate(isTglLahir: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataIdentitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Agama',
          value: _vm.selectedAgama,
          required: true,
          items: const [
            'Islam',
            'Kristen',
            'Katolik',
            'Hindu',
            'Buddha',
            'Konghucu',
            'Lainnya',
          ],
          onChanged: _vm.setAgama,
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          label: 'Pendidikan Terakhir',
          value: _vm.selectedPendidikan,
          required: true,
          items: const [
            'Tidak/Belum Sekolah',
            'SD/Sederajat',
            'SMP/Sederajat',
            'SMA/Sederajat',
            'D1/D2/D3',
            'S1/D4',
            'S2',
            'S3',
          ],
          onChanged: _vm.setPendidikan,
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          label: 'Jenis Pekerjaan',
          value: _vm.selectedPekerjaan,
          required: true,
          items: const [
            'Belum/Tidak Bekerja',
            'Mengurus Rumah Tangga',
            'Pelajar/Mahasiswa',
            'Pegawai Negeri Sipil (PNS)',
            'TNI/POLRI',
            'Karyawan Swasta',
            'Wiraswasta',
            'Petani/Nelayan/Pekebun',
            'Buruh',
            'Pensiunan',
            'Lainnya',
          ],
          onChanged: _vm.setPekerjaan,
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          label: 'Golongan Darah',
          value: _vm.selectedGolDarah,
          required: true,
          items: const [
            'A',
            'B',
            'AB',
            'O',
            'A+',
            'A-',
            'B+',
            'B-',
            'AB+',
            'AB-',
            'O+',
            'O-',
            'Tidak Tahu',
          ],
          onChanged: _vm.setGolDarah,
        ),
      ],
    );
  }

  Widget _buildDataPerkawinan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Status Perkawinan',
          value: _vm.selectedStatusKawin,
          required: true,
          items: const ['Belum Kawin', 'Kawin', 'Cerai Hidup', 'Cerai Mati'],
          onChanged: _vm.setStatusKawin,
        ),
        const SizedBox(height: 14),
        _buildDateField(
          label: 'Tanggal Perkawinan',
          value: _vm.tglPerkawinan,
          required: false,
          hint: 'Kosongkan jika belum/tidak kawin',
          onTap: () => _pickDate(isTglLahir: false),
        ),
      ],
    );
  }

  Widget _buildDataKewarganegaraan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Kewarganegaraan',
          value: _vm.selectedKewarganegaraan,
          required: true,
          items: const ['WNI', 'WNA'],
          onChanged: _vm.setKewarganegaraan,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          ctrl: _noPasporCtrl,
          label: 'No. Paspor',
          hint: 'Kosongkan jika tidak ada',
          required: false,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          ctrl: _noKitapCtrl,
          label: 'No. KITAP',
          hint: 'Khusus WNA — kosongkan jika tidak ada',
          required: false,
        ),
      ],
    );
  }

  Widget _buildDataKeluarga() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Status Hubungan dalam Keluarga',
          value: _vm.selectedStatusHubungan,
          required: true,
          items: const [
            'Kepala Keluarga',
            'Suami',
            'Istri',
            'Anak',
            'Menantu',
            'Cucu',
            'Orang Tua',
            'Mertua',
            'Famili Lain',
            'Pembantu',
          ],
          onChanged: _vm.setStatusHubungan,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          ctrl: _namaAyahCtrl,
          label: 'Nama Ayah',
          hint: 'Nama lengkap ayah kandung',
          required: true,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          ctrl: _namaIbuCtrl,
          label: 'Nama Ibu',
          hint: 'Nama lengkap ibu kandung',
          required: true,
        ),
        if (widget.keluargaId != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ColorsUtils.b50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorsUtils.b75),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, size: 16, color: ColorsUtils.b500),
                const SizedBox(width: 8),
                Text(
                  'KK ID: ${widget.keluargaId}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorsUtils.b400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Reusable UI Builders ───────────────────────────────────────

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: ColorsUtils.b50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: ColorsUtils.b500),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ColorsUtils.b400,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: content),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController ctrl,
    required String label,
    String? hint,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: _inputDecoration(hint: hint),
          validator:
              validator ??
              (required
                  ? (v) => (v == null || v.trim().isEmpty)
                        ? '$label wajib diisi'
                        : null
                  : null),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: _inputDecoration(),
          isExpanded: true,
          hint: Text(
            'Pilih $label',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
          validator: required
              ? (v) => v == null ? '$label wajib dipilih' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    String? hint,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        FormField<DateTime>(
          initialValue: value,
          validator: required
              ? (_) => _vm.tglLahir == null ? '$label wajib diisi' : null
              : null,
          builder: (state) => InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: state.hasError ? Colors.red : const Color(0xFFDDE3ED),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value != null
                          ? _formatDate(value)
                          : (hint ?? 'Pilih tanggal'),
                      style: TextStyle(
                        fontSize: 14,
                        color: value != null
                            ? ColorsUtils.black800
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: ColorsUtils.gray,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: ColorsUtils.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _vm.isLoading ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsUtils.b500,
            foregroundColor: ColorsUtils.white,
            disabledBackgroundColor: ColorsUtils.b75,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: _vm.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: ColorsUtils.white,
                  ),
                )
              : Text(
                  widget.editData != null
                      ? 'Simpan Perubahan'
                      : 'Tambah Anggota',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, bool required) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ColorsUtils.black800,
        ),
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : [],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: ColorsUtils.white,
      counterText: '',
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}
