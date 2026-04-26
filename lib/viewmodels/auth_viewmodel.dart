import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/models/auth_response_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  AuthResponse? authData;

  int _failedLoginCount = 0;
  bool _isLocked = false;
  int _lockSeconds = 0;


  bool get isLoggedIn => authData != null;
  User? get currentUser => authData?.user;

  bool get isLocked => _isLocked;
  int get lockSeconds => _lockSeconds;
  int get failedLoginCount => _failedLoginCount;

  final List<Warga> _dummyWarga = [
    Warga(id: 1, nik: "3275010101010001", nama: "Budi"),
    Warga(id: 2, nik: "3275010101010002", nama: "Siti"),
  ];

  final List<User> _dummyUsers = [
    User(id: 1, wargaId: 1, role: Role.warga, createdAt: DateTime.now()),
  ];

  void initAuth() {
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> login(String nik, String password) async {
  if (_isLocked) {
    errorMessage =
        "Terlalu banyak percobaan. Coba lagi dalam $_lockSeconds detik";
    notifyListeners();
    return;
  }

  isLoading = true;
  errorMessage = null;

  authData = null;

  notifyListeners();

  await Future.delayed(const Duration(seconds: 1));

  try {
    final warga = _dummyWarga.where((w) => w.nik == nik).firstOrNull;

    if (warga == null) {
      _onLoginFailed("NIK tidak terdaftar");
      return;
    }

    final user =
        _dummyUsers.where((u) => u.wargaId == warga.id).firstOrNull;

    if (user == null) {
      _onLoginFailed("Akun belum dibuat oleh RT");
      return;
    }

    if (password != "123456") {
      _onLoginFailed("Password salah");
      return;
    }

    _failedLoginCount = 0;
    errorMessage = null;

    authData = AuthResponse(
      token: "dummy_token_123",
      user: user,
    );
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
        isLoading = false;
        notifyListeners();
        return;
      }

      final existingUser = _dummyUsers
          .where((u) => u.wargaId == warga.id)
          .firstOrNull;

      if (existingUser != null) {
        errorMessage = "Akun sudah terdaftar";
        isLoading = false;
        notifyListeners();
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

      errorMessage = null;
    } catch (e) {
      errorMessage = "Gagal register";
    }

    isLoading = false;
    notifyListeners();
  }

  void logout() {
    authData = null;
    errorMessage = null;
    _failedLoginCount = 0;
    _isLocked = false;
    _lockSeconds = 0;
    notifyListeners();
  }

  void _onLoginFailed(String message) {
    _failedLoginCount++;
    errorMessage = message;

    if (_failedLoginCount >= 3) {
      _startLockTimer();
    }

    isLoading = false;
    notifyListeners();
  }

  void _startLockTimer() {
    _isLocked = true;
    _lockSeconds = 10;
    notifyListeners();

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      _lockSeconds--;

      notifyListeners();
      return _lockSeconds > 0;
    }).then((_) {
      _isLocked = false;
      _failedLoginCount = 0;
      _lockSeconds = 0;
      errorMessage = null;
      notifyListeners();
    });
  }
}
