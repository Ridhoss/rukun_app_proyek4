import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/helpers/log_helper.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/repositories/auth_repository.dart';
import 'package:rukun_app_proyek4/repositories/warga_repository.dart';

class DetailWargaViewModel extends ChangeNotifier {
  final WargaRepository repo;
  final AuthRepository authRepository;

  DetailWargaViewModel({required this.repo, required this.authRepository});

  Warga? warga;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _hasAccount = false;
  bool get hasAccount => _hasAccount;

  User? _accountUser;
  User? get accountUser => _accountUser;

  bool _isChecking = false;
  bool get isChecking => _isChecking;

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

  Future<bool> createAccount({
    required String nik,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authRepository.register(
        nik: nik,
        password: password,
        confirmPassword: confirmPassword,
      );

      return true;
    } catch (e, st) {
      final message = e.toString().replaceAll("Exception: ", "");
      _error = message;

      await LogHelper.writeLog(
        "Create account gagal: $message",
        source: "DetailWargaViewModel.createAccount",
        level: 1,
        error: e,
        stackTrace: st,
      );

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<void> checkAccountStatus(int wargaId) async {
    _isChecking = true;
    _error = null;
    notifyListeners();

    try {
      final result = await authRepository.getUserByWargaId(wargaId);

      _accountUser = result;
      _hasAccount = result != null;
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      _hasAccount = false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<bool> adminChangePassword({
    required int userId,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authRepository.adminChangePassword(userId, password);

      return true;
    } catch (e) {
      _error = e.toString().replaceAll("Exception: ", "");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
