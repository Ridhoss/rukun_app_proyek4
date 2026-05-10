import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/iuran_model.dart';
import 'package:rukun_app_proyek4/models/iuransaya_model.dart';
import 'package:rukun_app_proyek4/models/transaksi_model.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repostiory.dart';

enum FilterStatus { semua, belumDibayar, diproses, dibayar, ditolak }

class IuranItem {
  final DateTime bulan;
  final Transaksi? transaksi;

  IuranItem({required this.bulan, this.transaksi});

  StatusPembayaran get status {
    if (transaksi == null) return StatusPembayaran.belumDibayar;
    return transaksi!.status;
  }
}

class IuranwargaViewmodel extends ChangeNotifier {
  final IuranRepository repository;

  IuranwargaViewmodel(this.repository);

  List<IuranSaya> _items = [];

  FilterStatus selectedStatus = FilterStatus.semua;
  IuranType selectedType = IuranType.wajib;

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadIuranSaya() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _items = await repository.getIuranSaya();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  List<IuranSaya> get data {
    return _items.where((item) {
      if (item.iuran.tipe != selectedType) return false;

      final trx = item.transaksiTerbaru;

      switch (selectedStatus) {
        case FilterStatus.semua:
          return true;

        case FilterStatus.belumDibayar:
          return trx == null;

        case FilterStatus.diproses:
          return trx?.status == StatusPembayaran.diproses;

        case FilterStatus.dibayar:
          return trx?.status == StatusPembayaran.dibayar;

        case FilterStatus.ditolak:
          return trx?.status == StatusPembayaran.ditolak;
      }
    }).toList();
  }

  int get totalDibayar {
    return data.where((item) {
      return getStatusSummary(item) == StatusPembayaran.dibayar;
    }).length;
  }

  int get totalDiproses {
    return data.where((item) {
      return getStatusSummary(item) == StatusPembayaran.diproses;
    }).length;
  }

  int get totalBelum {
    return data.where((item) {
      return getStatusSummary(item) == StatusPembayaran.belumDibayar;
    }).length;
  }

  int get totalKeseluruhan => data.length;

  void setStatus(FilterStatus status) {
    selectedStatus = status;
    notifyListeners();
  }

  void setType(IuranType type) {
    selectedType = type;
    notifyListeners();
  }

  List<IuranItem> generateHistory(IuranSaya item) {
    final start = item.iuran.waktuDibuat ?? DateTime.now();
    final now = DateTime.now();

    final List<IuranItem> result = [];

    DateTime current = DateTime(start.year, start.month);

    while (!current.isAfter(DateTime(now.year, now.month))) {
      final trx = _findTransactionByMonth(item.transaksi, current);

      result.add(IuranItem(bulan: current, transaksi: trx));

      current = DateTime(current.year, current.month + 1);
    }

    return result;
  }

  Transaksi? _findTransactionByMonth(List<Transaksi> list, DateTime month) {
    for (final t in list) {
      if (t.waktuBayar == null) continue;

      if (t.waktuBayar!.year == month.year &&
          t.waktuBayar!.month == month.month) {
        return t;
      }
    }
    return null;
  }

  bool cekTunggakan(IuranSaya item) {
    final history = generateHistory(item);

    return history.any((e) => e.transaksi == null);
  }

  StatusPembayaran getStatusSummary(IuranSaya item) {
    final trx = item.transaksiTerbaru;

    if (item.iuran.periode == PeriodeType.sekali) {
      return trx?.status ?? StatusPembayaran.belumDibayar;
    }

    final history = generateHistory(item);

    final adaBelumBayar = history.any(
      (e) =>
          e.transaksi == null ||
          e.status == StatusPembayaran.belumDibayar ||
          e.status == StatusPembayaran.ditolak,
    );

    return adaBelumBayar
        ? StatusPembayaran.belumDibayar
        : StatusPembayaran.dibayar;
  }
}
