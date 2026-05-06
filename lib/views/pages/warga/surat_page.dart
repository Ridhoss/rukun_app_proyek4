import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/warga/pengajuan_surat_viewmodel.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';

class WargaSuratPage extends StatefulWidget {
  const WargaSuratPage({super.key});

  @override
  State<WargaSuratPage> createState() => _WargaSuratPageState();
}

class _WargaSuratPageState extends State<WargaSuratPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedJenis;
  final keperluanController = TextEditingController();
  final keteranganController = TextEditingController();

  @override
  void dispose() {
    keperluanController.dispose();
    keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PengajuanSuratViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final nama = authVM.currentUser?.warga?.nama ?? "-";

    return Scaffold(
      appBar: AppBarUtils.buildAppBar(
        name: nama,
        title: "Pengajuan Surat",
        subtitle: "Ajukan surat anda",
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoBox(),

              const SizedBox(height: 16),
              _buildField(
                title: "Jenis Surat",
                isRequired: true,
                child: DropdownButtonFormField<String>(
                  initialValue: selectedJenis,
                  items: const [
                    DropdownMenuItem(
                      value: "Surat Pengantar KTP",
                      child: Text("Surat Pengantar KTP"),
                    ),
                    DropdownMenuItem(
                      value: "Surat Domisili",
                      child: Text("Surat Domisili"),
                    ),
                    DropdownMenuItem(
                      value: "Surat Keterangan Tidak Mampu",
                      child: Text("Surat Keterangan Tidak Mampu"),
                    ),
                    DropdownMenuItem(
                      value: "Surat Keterangan Berkelakuan Baik",
                      child: Text("Surat Keterangan Berkelakuan Baik"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedJenis = value);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null ? "Silakan pilih jenis surat" : null,
                ),
              ),

              // keperluan
              _buildField(
                title: "Keperluan",
                isRequired: true,
                child: TextFormField(
                  controller: keperluanController,
                  decoration: const InputDecoration(
                    hintText:
                        "Silahkan jelaskan keperluan pengajuan surat ini...",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? "Keperluan wajib diisi"
                      : null,
                ),
              ),

              // keterangan tambahan
              _buildField(
                title: "Keterangan Tambahan",
                isRequired: true,
                child: TextFormField(
                  controller: keteranganController,
                  maxLines: 7,
                  decoration: const InputDecoration(
                    hintText: "Informasi tambahan yang perlu diketahui RW...",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? "Keterangan wajib diisi"
                      : null,
                ),
              ),

              const SizedBox(height: 10),
              // data diri (otomatis)
              const Text(
                "Data Diri Pemohon (otomatis)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),
              _dataCard(vm),

              // submit button
              const SizedBox(height: 20),
              vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Batal"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Harap lengkapi semua field yang wajib diisi",
                                    ),
                                  ),
                                );
                                return;
                              }

                              final data = PengajuanSurat(
                                wargaId: 1,
                                jenisSurat: selectedJenis!,
                                subjectKeperluan: keperluanController.text
                                    .trim(),
                                keterangan: keteranganController.text.trim(),
                              );

                              final success = await context
                                  .read<PengajuanSuratViewModel>()
                                  .submitPengajuan(data);

                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Pengajuan berhasil"),
                                  ),
                                );
                              }
                            },
                            child: const Text("Ajukan Surat"),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Isi Form pengajuan dibawah ini. Pengurus akan meninjau dan mengirimkan surat yang diajukan jika disetujui",
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String title,
    required Widget child,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            children: isRequired
                ? const [
                    TextSpan(
                      text: " *",
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _dataCard(PengajuanSuratViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _dataRow("Nama", vm.nama),
          _dataRow("NIK", vm.nik),
          _dataRow("RW/RT", "${vm.rw}/${vm.rt}"),
          _dataRow("Alamat", vm.alamat),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
