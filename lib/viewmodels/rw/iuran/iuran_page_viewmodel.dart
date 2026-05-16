import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/iuran/iuran_model.dart';
import 'package:rukun_app_proyek4/repositories/iuran_repostiory.dart';

class RwIuranViewModel extends ChangeNotifier {
  final IuranRepository repository;

  RwIuranViewModel({required this.repository});

  List<Iuran> _iurans = [];
  bool _isLoading = false;
  String? _error;

  List<Iuran> get iurans => _iurans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboard(int rwId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _iurans = await repository.getIuranByRWId(rwId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}