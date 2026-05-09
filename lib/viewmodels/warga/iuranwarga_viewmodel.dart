import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/iuran_model.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';
import 'package:rukun_app_proyek4/models/iuran_with_transaksi.dart';

enum FilterStatus { semua, belumDibayar, diproses, dibayar, ditolak }

class IuranwargaViewmodel extends ChangeNotifier {
  final List<Iuran> _iuranList = [];
  final List<Transaksi> _transaksiList = [];

  FilterStatus selectedStatus = FilterStatus.semua;

  IuranType selectedType = IuranType.reguler;

  bool isLoading = false;
  String? errorMessage;

  // data dummy
  void loadDummy() {
    isLoading = true;
    notifyListeners();

    try {
      _iuranList
        ..clear()
        ..addAll([
          Iuran(
            id: 1,
            nama: "Iuran Sampah RT 02",
            jumlah: 50000,
            level: IuranLevel.rt,
            type: IuranType.reguler,
            cakupan: IuranScope.warga,
            periode: PeriodeType.bulanan,
          ),
          Iuran(
            id: 2,
            nama: "Santunan Kematian",
            jumlah: 25000,
            level: IuranLevel.rt,
            type: IuranType.insidentil,
            cakupan: IuranScope.warga,
            periode: PeriodeType.sekali,
          ),
        ]);

      _transaksiList
        ..clear()
        ..addAll([
          Transaksi(
            id: 1,
            iuranId: 1,
            jumlah: 50000,
            status: StatusPembayaran.belumDibayar,
          ),
          Transaksi(
            id: 2,
            iuranId: 2,
            jumlah: 25000,
            waktuBayar: DateTime.now(),
            status: StatusPembayaran.diproses,
            imgRef: "https://picsum.photos/seed/surat/400",
          ),
        ]);

      errorMessage = null;
    } catch (e) {
      errorMessage = "Gagal load data";
    }

    isLoading = false;
    notifyListeners();
  }

  List<IuranWithTransaksi> get data {
    return _iuranList
        .where((iuran) => iuran.type == selectedType)
        .map((iuran) {
          final trx = _transaksiList
              .where((t) => t.iuranId == iuran.id)
              .cast<Transaksi?>()
              .firstWhere((e) => true, orElse: () => null);

          return IuranWithTransaksi(iuran: iuran, transaksi: trx);
        })
        .where((item) {
          final trx = item.transaksi;

          switch (selectedStatus) {
            case FilterStatus.semua:
              return true;

            case FilterStatus.belumDibayar:
              return trx == null || trx.status == StatusPembayaran.belumDibayar;

            case FilterStatus.diproses:
              return trx?.status == StatusPembayaran.diproses;

            case FilterStatus.dibayar:
              return trx?.status == StatusPembayaran.dibayar;

            case FilterStatus.ditolak:
              return trx?.status == StatusPembayaran.ditolak;
          }
        })
        .toList();
  }

  List<IuranWithTransaksi> get allData {
    return _iuranList.map((iuran) {
      final trx = _transaksiList
          .where((t) => t.iuranId == iuran.id)
          .cast<Transaksi?>()
          .firstWhere((e) => true, orElse: () => null);

      return IuranWithTransaksi(iuran: iuran, transaksi: trx);
    }).toList();
  }

  int get totalDibayar => allData
      .where((e) => e.transaksi?.status == StatusPembayaran.dibayar)
      .length;

  int get totalBelum => allData
      .where(
        (e) =>
            e.transaksi == null ||
            e.transaksi!.status == StatusPembayaran.belumDibayar,
      )
      .length;

  int get totalKeseluruhan => allData.fold(0, (sum, e) => sum + e.iuran.jumlah);

  void setStatus(FilterStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  void setType(IuranType type) {
    selectedType = type;
    notifyListeners();
  }
}
