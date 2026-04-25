import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/keluarga.dart';
import 'package:rukun_app_proyek4/models/warga.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/kk_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/kependudukan/add_warga_page.dart';

// ================================================================
// AddKKPage
// View — StatefulWidget hanya untuk lifecycle ViewModel.
// Semua state & logika ada di KKViewModel.
// ================================================================

class AddKKPage extends StatefulWidget {
  final Keluarga? editData;
  const AddKKPage({super.key, this.editData});

  @override
  State<AddKKPage> createState() => _AddKKPageState();
}

// !! PERHATIAN: State class ini HANYA berisi: !!
//   1. Lifecycle  : initState, dispose
//   2. Controllers: TextEditingController (state UI murni, bukan logika)
//   3. FormKey    : milik widget Form
// TIDAK ada logika bisnis di sini. Semua logika → KKViewModel.
class _AddKKPageState extends State<AddKKPage> {
  late final KKViewModel _vm;
  final _formKey = GlobalKey<FormState>();

  // TextEditingController = "apa yang user ketik di layar" = state UI, bukan bisnis
  final _noKKCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = KKViewModel();
    _vm.init(editData: widget.editData);

    if (widget.editData != null) {
      _noKKCtrl.text = widget.editData!.noKK;
      _addressCtrl.text = widget.editData!.alamat;
    }
  }

  @override
  void dispose() {
    _vm.dispose(); // wajib dispose ChangeNotifier
    _noKKCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // build() = fungsi murni tampilan, tidak ada logika di sini
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
          widget.editData != null
              ? 'Edit Kartu Keluarga'
              : 'Tambah Kartu Keluarga',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        centerTitle: true,
        actions: _vm.kkSaved
            ? [
                TextButton(
                  onPressed: _onSelesai,
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      color: ColorsUtils.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                _buildKKSection(context),
                const SizedBox(height: 20),
                _buildAnggotaSection(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _vm.kkSaved
          ? _buildBottomBar()
          : const SizedBox.shrink(),
    );
  }

  // ── Handlers: jembatan tipis View → ViewModel ─────────────────
  // Handler hanya: ambil data dari UI (controller/formkey), lalu lempar ke VM.
  // TIDAK ada if/else logika di sini.

  Future<void> _onSaveKK() async {
    if (!_formKey.currentState!.validate()) return;

    final kk = Keluarga(
      noKK: _noKKCtrl.text.trim(),
      rtId: _vm.selectedRTId!,
      alamat: _addressCtrl.text.trim(),
      kodePos: "40535",
    );

    final success = await _vm.saveKK(kk); // logika ada di VM

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Data KK berhasil disimpan. Silakan tambah anggota.'
              : (_vm.errorMessage ?? 'Terjadi kesalahan.'),
        ),
        backgroundColor: success ? ColorsUtils.b500 : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onSelesai() {
    if (_vm.anggotaList.isEmpty) {
      _showKonfirmasiSelesai();
    } else {
      Navigator.pop(context);
    }
  }

  void _showKonfirmasiSelesai() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Konfirmasi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('KK ini belum memiliki anggota. Tetap selesai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Tambah dulu',
              style: TextStyle(color: ColorsUtils.b500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsUtils.b500,
              foregroundColor: ColorsUtils.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  void _goToAddWarga() {
    Navigator.push<WargaModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddWargaPage(keluargaId: _vm.savedKKId),
      ),
    ).then((warga) {
      if (warga != null) _vm.addAnggota(warga);
    });
  }

  void _goToEditWarga(int index) {
    Navigator.push<WargaModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddWargaPage(
          keluargaId: _vm.savedKKId,
          editData: _vm.anggotaList[index],
        ),
      ),
    ).then((updated) {
      if (updated != null) _vm.updateAnggota(index, updated);
    });
  }

  void _confirmDeleteWarga(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Hapus Anggota?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text('Yakin hapus "${_vm.anggotaList[index].nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: ColorsUtils.gray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: ColorsUtils.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _vm.removeAnggota(index); // logika ada di VM
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ── UI Builders ────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Container(
      color: ColorsUtils.b500,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          _buildStep(
            number: '1',
            label: 'Data KK',
            active: true,
            done: _vm.kkSaved,
          ),
          _buildStepLine(active: _vm.kkSaved),
          _buildStep(
            number: '2',
            label: 'Anggota',
            active: _vm.kkSaved,
            done: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String label,
    required bool active,
    required bool done,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? Colors.green
                : active
                ? ColorsUtils.white
                : ColorsUtils.b400,
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    number,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: active ? ColorsUtils.b500 : Colors.white54,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? ColorsUtils.white : Colors.white54,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
        color: active ? Colors.white : Colors.white24,
      ),
    );
  }

  Widget _buildKKSection(BuildContext context) {
    return _buildCard(
      header: _buildSectionHeader(
        'Data Kartu Keluarga',
        Icons.home_outlined,
        trailing: _vm.kkSaved ? _buildBadge('Tersimpan', Colors.green) : null,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('No. Kartu Keluarga', true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _noKKCtrl,
              keyboardType: TextInputType.number,
              maxLength: 16,
              enabled: !_vm.kkSaved,
              decoration: _inputDecoration(hint: '16 digit nomor KK'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'No. KK wajib diisi';
                if (v.trim().length != 16) return 'No. KK harus 16 digit';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildLabel('RT', true),
            const SizedBox(height: 6),
            _vm.isLoadingRT
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ColorsUtils.b500,
                      ),
                    ),
                  )
                : DropdownButtonFormField<int>(
                    value: _vm.selectedRTId,
                    decoration: _inputDecoration(),
                    isExpanded: true,
                    hint: Text(
                      'Pilih RT',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    items: _vm.rtList
                        .map(
                          (rt) => DropdownMenuItem<int>(
                            value: rt['id'] as int,
                            child: Text(
                              rt['name'] as String,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _vm.kkSaved ? null : _vm.selectRT,
                    validator: (v) => v == null ? 'RT wajib dipilih' : null,
                  ),
            const SizedBox(height: 14),
            _buildLabel('Alamat Lengkap', true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 3,
              enabled: !_vm.kkSaved,
              decoration: _inputDecoration(
                hint: 'Jl. nama jalan, No. rumah, RT/RW...',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Alamat wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            if (!_vm.kkSaved)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  icon: _vm.isLoadingKK
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ColorsUtils.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: const Text(
                    'Simpan Data KK',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  onPressed: _vm.isLoadingKK ? null : _onSaveKK,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsUtils.b500,
                    foregroundColor: ColorsUtils.white,
                    disabledBackgroundColor: ColorsUtils.b75,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            if (_vm.kkSaved)
              TextButton.icon(
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: ColorsUtils.b500,
                ),
                label: const Text(
                  'Ubah Data KK',
                  style: TextStyle(
                    color: ColorsUtils.b500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _vm.unlockKK,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnggotaSection(BuildContext context) {
    return _buildCard(
      header: _buildSectionHeader(
        'Anggota Keluarga',
        Icons.people_outline,
        trailing: _buildBadge(
          '${_vm.anggotaList.length} orang',
          ColorsUtils.b500,
        ),
      ),
      child: Column(
        children: [
          if (!_vm.kkSaved)
            _buildInfoBox(
              'Simpan data KK terlebih dahulu sebelum menambah anggota keluarga.',
            )
          else ...[
            if (_vm.anggotaList.isEmpty) _buildEmptyAnggota(),
            ..._vm.anggotaList.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildAnggotaCard(e.value, e.key),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.person_add_outlined,
                  size: 18,
                  color: ColorsUtils.b500,
                ),
                label: const Text(
                  'Tambah Anggota Keluarga',
                  style: TextStyle(
                    color: ColorsUtils.b500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _goToAddWarga,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ColorsUtils.b500, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyAnggota() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: ColorsUtils.gray),
          SizedBox(height: 10),
          Text(
            'Belum ada anggota keluarga',
            style: TextStyle(
              color: ColorsUtils.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tekan tombol di bawah untuk menambahkan',
            style: TextStyle(color: ColorsUtils.gray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAnggotaCard(WargaModel warga, int index) {
    final isKK = warga.statusHubungan == 'Kepala Keluarga';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isKK ? ColorsUtils.b50 : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isKK ? ColorsUtils.b75 : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isKK
                  ? ColorsUtils.b500
                  : ColorsUtils.gray.withOpacity(0.15),
            ),
            child: Center(
              child: Text(
                warga.nama.isNotEmpty ? warga.nama[0].toUpperCase() : '?',
                style: TextStyle(
                  color: isKK ? ColorsUtils.white : ColorsUtils.gray,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      warga.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: ColorsUtils.black800,
                      ),
                    ),
                    if (isKK) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsUtils.b500,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'KK',
                          style: TextStyle(
                            color: ColorsUtils.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${warga.nik} · ${warga.statusHubungan}',
                  style: const TextStyle(color: ColorsUtils.gray, fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              size: 18,
              color: ColorsUtils.gray,
            ),
            onSelected: (val) {
              if (val == 'edit') _goToEditWarga(index);
              if (val == 'delete') _confirmDeleteWarga(index);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
          onPressed: _onSelesai,
          style: ElevatedButton.styleFrom(
            backgroundColor: _vm.anggotaList.isNotEmpty
                ? Colors.green
                : ColorsUtils.b500,
            foregroundColor: ColorsUtils.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _vm.anggotaList.isNotEmpty
                    ? Icons.check_circle_outline
                    : Icons.arrow_forward,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _vm.anggotaList.isNotEmpty
                    ? 'Selesai (${_vm.anggotaList.length} anggota)'
                    : 'Selesai Tanpa Anggota',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Reusable UI helpers ────────────────────────────────────────

  Widget _buildCard({required Widget header, required Widget child}) {
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
          header,
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Widget? trailing}) {
    return Container(
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ColorsUtils.b400,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFFD97706)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF92400E)),
            ),
          ),
        ],
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFEEF0F5)),
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
}
