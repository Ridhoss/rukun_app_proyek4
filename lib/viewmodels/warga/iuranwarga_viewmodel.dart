import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/iuran_model.dart';
import 'package:rukun_app_proyek4/models/iuran_with_transaksi.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repostiory.dart';

enum FilterStatus { semua, belumDibayar, diproses, dibayar, ditolak }

class IuranwargaViewmodel extends ChangeNotifier {
  final IuranRepository repository;

  IuranwargaViewmodel(this.repository);

  final List<IuranWithTransaksi> _items = [];

  FilterStatus selectedStatus = FilterStatus.semua;

  IuranType selectedType = IuranType.wajib;

  bool isLoading = false;

  String? errorMessage;

  Future<void> loadIuranSaya() async {
    isLoading = true;
    errorMessage = null;

    notifyListeners();

    try {
      final result = await repository.getIuranSaya();

      _items
        ..clear()
        ..addAll(
          result.map(
            (e) => IuranWithTransaksi(iuran: e.iuran, transaksi: e.transaksi),
          ),
        );
    } catch (e) {
      errorMessage = e.toString().replaceAll("Exception: ", "");
    }

    isLoading = false;
    notifyListeners();
  }

  List<IuranWithTransaksi> get data {
    return _items.where((item) {
      final iuran = item.iuran;
      final trx = item.transaksi;

      // filter tipe
      if (iuran.tipe != selectedType) {
        return false;
      }

      // filter status
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
    }).toList();
  }

  int get totalDibayar =>
      data.where((e) => e.transaksi?.status == StatusPembayaran.dibayar).length;

  int get totalBelum => data
      .where(
        (e) =>
            e.transaksi == null ||
            e.transaksi!.status == StatusPembayaran.belumDibayar,
      )
      .length;

  int get totalKeseluruhan => data.fold(0, (sum, e) => sum + e.iuran.jumlah);

  void setStatus(FilterStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  void setType(IuranType type) {
    selectedType = type;
    notifyListeners();
  }
}
