import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/auth_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/warga/pengajuan_surat_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/warga/surat/pengajuan_surat_page.dart';

class TambahSuratPage extends StatefulWidget {
  const TambahSuratPage({super.key});

  @override
  State<TambahSuratPage> createState() => _TambahSuratPageState();
}

class _TambahSuratPageState extends State<TambahSuratPage> {
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

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          autovalidateMode: AutovalidateMode.onUserInteraction,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _infoBox(),

              const SizedBox(height: 20),
              const Text(
                "Data Diri Pemohon",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),

              const SizedBox(height: 10),
              _dataCard(authVM),

              const SizedBox(height: 22),
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
                    setState(() {
                      selectedJenis = value;
                    });
                  },

                  decoration: InputDecoration(
                    hintText: "Pilih jenis surat",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  validator: (v) {
                    if (v == null) {
                      return "Silakan pilih jenis surat";
                    }
                    return null;
                  },
                ),
              ),

              _buildField(
                title: "Keperluan",
                isRequired: true,

                child: TextFormField(
                  controller: keperluanController,

                  decoration: InputDecoration(
                    hintText: "Contoh: Untuk melamar pekerjaan",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Keperluan wajib diisi";
                    }

                    if (v.trim().length < 5) {
                      return "Minimal 5 karakter";
                    }

                    return null;
                  },
                ),
              ),

              _buildField(
                title: "Keterangan Tambahan",
                isRequired: true,

                child: TextFormField(
                  controller: keteranganController,
                  maxLines: 5,

                  decoration: InputDecoration(
                    hintText: "Tambahkan informasi tambahan",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Keterangan wajib diisi";
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(height: 24),
              vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PengajuanSuratPage(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Batal"),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submit,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsUtils.b100,

                              padding: const EdgeInsets.symmetric(vertical: 14),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua field")),
      );
      return;
    }

    final data = PengajuanSurat(
      wargaId: 1,
      jenisSurat: selectedJenis!,
      subjectKeperluan: keperluanController.text.trim(),
      keterangan: keteranganController.text.trim(),
    );

    final success = await context.read<PengajuanSuratViewModel>().submit(data);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pengajuan berhasil")));
    }
  }

  Widget _infoBox() {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),

      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(Icons.info_outline, color: Colors.blue),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              "Pengajuan akan diproses oleh pengurus. Pastikan data sudah benar sebelum mengajukan surat.",
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

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _dataCard(AuthViewModel authVM) {
    final warga = authVM.currentUser?.warga;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Column(
        children: [
          _row("Nama", warga?.nama ?? "-"),

          _row("NIK", warga?.nik ?? "-"),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 100,

            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
