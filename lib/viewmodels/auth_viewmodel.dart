import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/auth_response_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  AuthResponse? authData;

  final List<Warga> _dummyWarga = [
    Warga(id: 1, nik: "3275010101010001", nama: "Budi"),
    Warga(id: 2, nik: "3275010101010002", nama: "Siti"),
  ];

  final List<User> _dummyUsers = [
    User(id: 1, wargaId: 1, role: Role.warga, createdAt: DateTime.now()),
  ];

  Future<void> login(String nik, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final warga = _dummyWarga.where((w) => w.nik == nik).firstOrNull;

      if (warga == null) {
        errorMessage = "NIK tidak terdaftar";
        return;
      }

      final user = _dummyUsers.where((u) => u.wargaId == warga.id).firstOrNull;

      if (user == null) {
        errorMessage = "Akun belum dibuat oleh RT";
        return;
      }

      if (password != "123456") {
        errorMessage = "Password salah";
        return;
      }

      authData = AuthResponse(token: "dummy_token_123", user: user);
    } catch (e) {
      errorMessage = "Terjadi kesalahan";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> register(String nik, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    try {
      final warga = _dummyWarga.where((w) => w.nik == nik).firstOrNull;

      if (warga == null) {
        errorMessage = "NIK belum terdaftar oleh RT";
        return;
      }

      final existingUser = _dummyUsers
          .where((u) => u.wargaId == warga.id)
          .firstOrNull;

      if (existingUser != null) {
        errorMessage = "Akun sudah terdaftar";
        return;
      }

      final newUser = User(
        id: _dummyUsers.length + 1,
        wargaId: warga.id,
        role: Role.warga,
        createdAt: DateTime.now(),
      );

      _dummyUsers.add(newUser);

      authData = AuthResponse(token: "dummy_token_123", user: newUser);
    } catch (e) {
      errorMessage = "Gagal register";
    }

    isLoading = false;
    notifyListeners();
  }

  void logout() {
    authData = null;
    notifyListeners();
  }

  bool get isLoggedIn => authData != null;
  User? get currentUser => authData?.user;
}
