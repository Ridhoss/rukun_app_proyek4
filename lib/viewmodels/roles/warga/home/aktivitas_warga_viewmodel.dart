import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/pengajuan_surat_model.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repository.dart';
import 'package:rukun_app_proyek4/repositories/kegiatan_repository.dart';
import 'package:rukun_app_proyek4/repositories/surat_repository.dart';

class AktivitasWargaViewModel extends ChangeNotifier {
  final SuratRepository suratRepository;
  final IuranRepository iuranRepository;
  final KegiatanRepository kegiatanRepository;

  AktivitasWargaViewModel({
    required this.suratRepository,
    required this.iuranRepository,
    required this.kegiatanRepository,
  });

  bool isLoading = false;

  List<Map<String, dynamic>> aktivitas = [];

  Future<void> loadAktivitas({required int rwId}) async {
    try {
      isLoading = true;
      notifyListeners();

      aktivitas.clear();

      final suratList = await suratRepository.getSuratSaya();
      final iuranList = await iuranRepository.getIuranSaya();
      final kegiatanList = await kegiatanRepository.getKegiatanByRW(rwId);

      for (final surat in suratList) {
        aktivitas.add({
          "title": "${surat.keperluan} (${surat.status.value})",
          "date": surat.waktuDibuat,
          "type": "surat",
          "color": Colors.orange,
        });
      }

      for (final item in iuranList) {
        if (item.transaksiTerbaru != null) {
          aktivitas.add({
            "title": item.iuran.nama,
            "date": item.transaksiTerbaru?.waktuBayar,
            "type": "iuran",
            "color": Colors.blue,
          });
        }
      }

      for (final kegiatan in kegiatanList) {
        aktivitas.add({
          "title": kegiatan.nama,
          "date": kegiatan.waktuDibuat,
          "type": "kegiatan",
          "color": Colors.green,
        });
      }

      aktivitas.sort((a, b) {
        final dateA = a["date"] as DateTime?;
        final dateB = b["date"] as DateTime?;

        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA);
      });

      aktivitas = aktivitas.take(3).toList();
    } catch (e) {
      debugPrint("Gagal load aktivitas: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
