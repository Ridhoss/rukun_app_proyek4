import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';

class DetailWargaViewModel extends ChangeNotifier {
  final WargaRepository repo;

  DetailWargaViewModel({required this.repo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Warga? warga;

  Future<void> getDetailWarga(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      warga = await repo.getWargaById(id);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteWarga(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repo.deleteWarga(id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}