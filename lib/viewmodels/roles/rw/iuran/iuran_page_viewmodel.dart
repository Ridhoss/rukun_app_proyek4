import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repository.dart';
import 'package:rukun_app_proyek4/services/local/local_iuran_cache_service.dart';

enum IuranFilter { semua, rutin, khusus }

enum DashboardMode { rw, rt }

class RwIuranViewModel extends ChangeNotifier {
  final IuranRepository repository;

  RwIuranViewModel({required this.repository});

  final IuranLocalCacheService _cache = IuranLocalCacheService();

  List<Iuran> _iurans = [];
  bool _isLoading = false;
  String? _error;

  IuranFilter _selectedFilter = IuranFilter.semua;

  List<Iuran> get iurans => _iurans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  IuranFilter get selectedFilter => _selectedFilter;

  DashboardMode _mode = DashboardMode.rw;

  DashboardMode get mode => _mode;

  void setMode(DashboardMode value) {
    _mode = value;
    notifyListeners();
  }

  List<Iuran> get filteredIurans {
    var data = _iurans.where((e) {
      if (_mode == DashboardMode.rw) {
        return e.level == IuranLevel.rw;
      }

      return e.level == IuranLevel.rt;
    }).toList();

    switch (_selectedFilter) {
      case IuranFilter.semua:
        return data;

      case IuranFilter.rutin:
        return data.where((e) => e.tipe == IuranType.reguler).toList();

      case IuranFilter.khusus:
        return data.where((e) => e.tipe == IuranType.insidentil).toList();
    }
  }

  void setFilter(IuranFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> fetchDashboard(int rwId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _iurans = await repository.getIuranByRWId(rwId);
    } catch (e) {
      debugPrint('[RwIuranVM] fetchDashboard error: $e');
      _iurans = await _getCachedIuran(rwId);
      if (_iurans.isEmpty) {
        _error = e.toString();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Iuran>> _getCachedIuran(int rwId) async {
    try {
      final cached = await _cache.readIuranRwRaw(rwId);
      if (cached.isNotEmpty) {
        return cached.map(Iuran.fromJson).toList();
      }

      final allCached = await _cache.readIuranRaw();
      return allCached
          .where((item) => (item['rw_id'] as num?)?.toInt() == rwId)
          .map(Iuran.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
