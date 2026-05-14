import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';
import 'package:rukun_app_proyek4/utils/appbar_utils.dart';
import 'package:rukun_app_proyek4/utils/colors_utils.dart';
import 'package:rukun_app_proyek4/utils/notification_utils.dart';
import 'package:rukun_app_proyek4/viewmodels/rt/penduduk/warga/detail_warga_viewmodel.dart';
import 'package:rukun_app_proyek4/viewmodels/rt/penduduk/warga/edit_warga_viewmodel.dart';
import 'package:rukun_app_proyek4/views/pages/rt/penduduk/crudwarga/edit_warga_page.dart';

class DetailWargaPage extends StatelessWidget {
  final int wargaId;
  final int? currentUserWargaId;

  const DetailWargaPage({
    super.key,
    required this.wargaId,
    this.currentUserWargaId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          DetailWargaViewModel(repo: context.read<WargaRepository>())
            ..getDetailWarga(wargaId),
      child: _DetailWargaView(wargaId: wargaId, currentUserWargaId: currentUserWargaId,),
    );
  }
}

class _DetailWargaView extends StatelessWidget {
  final int wargaId;
  final int? currentUserWargaId;

  const _DetailWargaView({required this.wargaId, this.currentUserWargaId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetailWargaViewModel>();
    final warga = vm.warga;

    if (vm.isLoading || warga == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isSelf =
        currentUserWargaId != null &&
        warga.id != null &&
        warga.id == currentUserWargaId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBarUtils.buildAppBar(
        name: "",
        title: "Detail Warga",
        subtitle: "Ringkasan data detail warga",
        showName: false,
        showAvatar: false,
        showGreeting: false,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(warga),

          const SizedBox(height: 16),

          _buildSection(
            title: "Data Warga",
            children: [
              _item("NIK", warga.nik),
              _item("Nama", warga.nama),
              _item("Jenis Kelamin", _jkText(warga.jk)),
              _item("Tempat Lahir", warga.tempatLahir),
              _item("Tanggal Lahir", _formatDate(warga.tglLahir)),
              _item("Agama", _agamaText(warga.agama)),
              _item("Pendidikan", warga.pendidikan),
              _item("Pekerjaan", warga.jenisPekerjaan),
              _item("Golongan Darah", warga.golonganDarah),

              _item(
                "Status Perkawinan",
                _statusKawinText(warga.statusPerkawinan),
              ),

              _item("Tanggal Perkawinan", _formatDate(warga.tglPerkawinan)),

              _item("Status Hubungan", _hubunganText(warga.statusHubungan)),

              _item(
                "Kewarganegaraan",
                _kewarganegaraanText(warga.kewarganegaraan),
              ),

              _item("Negara WNA", warga.wnaNegara),
              _item("No Paspor", warga.noPaspor),
              _item("No KITAP", warga.noKitap),
              _item("Nama Ayah", warga.namaAyah),
              _item("Nama Ibu", warga.namaIbu),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider(
                          create: (_) => EditWargaViewModel(
                            repo: context.read<WargaRepository>(),
                            idWarga: warga.id!,
                          ),
                          child: const EditWargaPage(),
                        ),
                      ),
                    );

                    if (result == true && context.mounted) {
                      await vm.getDetailWarga(warga.id!);
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text("Edit"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsUtils.b500,
                    side: const BorderSide(color: ColorsUtils.b500),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isSelf
                      ? null
                      : () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Hapus Warga"),
                              content: const Text(
                                "Apakah Anda yakin ingin menghapus data warga ini?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text("Batal"),
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Hapus"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final success = await vm.deleteWarga(warga.id!);

                            if (!context.mounted) return;

                            if (success) {
                              NotificationUtils.showSuccess(
                                context,
                                "Warga berhasil dihapus",
                              );

                              Navigator.pop(context, true);
                            } else {
                              NotificationUtils.showError(
                                context,
                                vm.error ?? "Gagal menghapus Warga",
                              );
                            }
                          }
                        },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(isSelf ? "Akun Sendiri" : "Delete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildHeaderCard(Warga warga) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: ColorsUtils.b50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: ColorsUtils.b500, size: 28),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                warga.nama,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                warga.nik,
                style: const TextStyle(fontSize: 13, color: ColorsUtils.gray),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSection({required String title, required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),

        const SizedBox(height: 16),

        ...children,
      ],
    ),
  );
}

Widget _item(String title, String? value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, color: ColorsUtils.gray),
          ),
        ),

        Expanded(
          child: Text(
            value == null || value.isEmpty ? "-" : value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime? date) {
  if (date == null) return "-";

  return DateFormat("dd MMMM yyyy", "id_ID").format(date);
}

String _jkText(JenisKelamin? value) {
  switch (value) {
    case JenisKelamin.lakiLaki:
      return "Laki-Laki";
    case JenisKelamin.perempuan:
      return "Perempuan";
    default:
      return "-";
  }
}

String _agamaText(Agama? value) {
  switch (value) {
    case Agama.islam:
      return "Islam";
    case Agama.kristen:
      return "Kristen";
    case Agama.katolik:
      return "Katolik";
    case Agama.hindu:
      return "Hindu";
    case Agama.buddha:
      return "Buddha";
    case Agama.konghucu:
      return "Konghucu";
    default:
      return "-";
  }
}

String _statusKawinText(StatusPerkawinan? value) {
  switch (value) {
    case StatusPerkawinan.belumKawin:
      return "Belum Kawin";
    case StatusPerkawinan.kawin:
      return "Kawin";
    case StatusPerkawinan.ceraiHidup:
      return "Cerai Hidup";
    case StatusPerkawinan.ceraiMati:
      return "Cerai Mati";
    default:
      return "-";
  }
}

String _hubunganText(StatusHubungan? value) {
  switch (value) {
    case StatusHubungan.kepalaKeluarga:
      return "Kepala Keluarga";
    case StatusHubungan.suami:
      return "Suami";
    case StatusHubungan.istri:
      return "Istri";
    case StatusHubungan.anak:
      return "Anak";
    case StatusHubungan.menantu:
      return "Menantu";
    case StatusHubungan.cucu:
      return "Cucu";
    case StatusHubungan.orangTua:
      return "Orang Tua";
    case StatusHubungan.mertua:
      return "Mertua";
    case StatusHubungan.familiLain:
      return "Famili Lain";
    default:
      return "-";
  }
}

String _kewarganegaraanText(Kewarganegaraan? value) {
  switch (value) {
    case Kewarganegaraan.wni:
      return "WNI";
    case Kewarganegaraan.wna:
      return "WNA";
    default:
      return "-";
  }
}
