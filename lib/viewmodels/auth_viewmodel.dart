import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/helpers/log_helper.dart';
import 'package:rukun_app_proyek4/models/auth_response_model.dart';
import 'package:rukun_app_proyek4/models/user_model.dart';
import 'package:rukun_app_proyek4/models/warga_model.dart';
import 'package:rukun_app_proyek4/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

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

  bool useMock = true; //sementara
  Warga? wargaData;

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
    try {
      late AuthResponse result;

      if (useMock) {
        //dummy mockup
        await Future.delayed(const Duration(milliseconds: 800));

        result = AuthResponse(
          token: "dummy_token",
          user: User(
            id: 1,
            wargaId: 10,
            role: Role.pengurus,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        result = await _authRepository.login(nik, password);
      }

      // try {
      //   final result = await _authRepository.login(nik, password);

      _failedLoginCount = 0;
      errorMessage = null;
      authData = result;
      await fetchWarga(); //sementara
    } catch (e, st) {
      final message = e.toString().replaceAll("Exception: ", "");
      _onLoginFailed(message);

      await LogHelper.writeLog(
        "Login gagal: $message",
        source: "AuthViewModel.login",
        level: 1,
        error: e,
        stackTrace: st,
      );
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> register(
    String nik,
    String password,
    String confirmPassword,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(
        nik: nik,
        password: password,
        confirmPassword: confirmPassword,
      );

      _failedLoginCount = 0;
      errorMessage = null;
    } catch (e, st) {
      final message = e.toString().replaceAll("Exception: ", "");

      errorMessage = message;

      await LogHelper.writeLog(
        "Register gagal: $message",
        source: "AuthViewModel.register",
        level: 1,
        error: e,
        stackTrace: st,
      );
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    if (!useMock) {
      //sementara
      await _authRepository.logout();
    }
    // void logout() {
    authData = null;
    errorMessage = null;
    _failedLoginCount = 0;
    _isLocked = false;
    _lockSeconds = 0;
    notifyListeners();
  }

  Future<void> fetchWarga() async {//sementara
    final wargaId = authData?.user.wargaId;

    if (wargaId == null) {
      debugPrint("WARGA ID NULL");
      return;
    }

    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));

      wargaData = Warga(id: wargaId, nama: "Admin RW", nik: "3201010101010001");
    } else {
      wargaData = await _authRepository.getWarga(wargaId);
    }

    notifyListeners();
  }

  Future<void> checkAuth() async {
    debugPrint("CHECK AUTH START");

    isLoading = true;
    notifyListeners();

    try {
      // sementara
      if (useMock) {
        await Future.delayed(const Duration(milliseconds: 500));

        authData = AuthResponse(
          token: "dummy_token",
          user: User(
            id: 1,
            wargaId: 10,
            role: Role.pengurus,
            createdAt: DateTime.now(),
          ),
        );
      } else {
        final token = await _authRepository.getToken();

        if (token == null || token.isEmpty) {
          authData = null;
        } else {
          final user = await _authRepository.getMe(token);

          authData = AuthResponse(token: token, user: user);
          await fetchWarga(); //sementara
        }
      }
      // try {
      //   final token = await _authRepository.getToken();
      //   debugPrint("TOKEN: $token");

      //   if (token == null || token.isEmpty) {
      //     authData = null;
      //     return;
      //   }

      //   final user = await _authRepository.getMe(token);

      //   authData = AuthResponse(token: token, user: user);

      //   debugPrint("AUTH SUCCESS");
    } catch (e, st) {
      debugPrint("AUTH ERROR: $e");

      await LogHelper.writeLog(
        "CheckAuth gagal: $e",
        source: "AuthViewModel.checkAuth",
        level: 1,
        error: e,
        stackTrace: st,
      );

      authData = null;
    } finally {
      isLoading = false;
      notifyListeners();
      debugPrint("CHECK AUTH DONE");
    }
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
