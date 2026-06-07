import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/repositories/auth_repository.dart';

class KelolaProfileViewModel extends ChangeNotifier {
  KelolaProfileViewModel(this._authRepository);

  final AuthRepository _authRepository;

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscureOldPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  bool isLoading = false;

  String? errorMessage;
  String? successMessage;

  void toggleOldPassword() {
    obscureOldPassword = !obscureOldPassword;
    notifyListeners();
  }

  void toggleNewPassword() {
    obscureNewPassword = !obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<void> submit() async {
    try {
      isLoading = true;
      errorMessage = null;
      successMessage = null;

      notifyListeners();

      await _validateForm();

      successMessage =
          "Validasi berhasil. Menunggu integrasi backend ganti password.";
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _validateForm() async {
    final savedPassword = await _authRepository.getSavedPassword();

    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      throw Exception("Semua field wajib diisi");
    }

    if (savedPassword == null) {
      throw Exception("Password lama tidak ditemukan");
    }

    if (oldPassword != savedPassword) {
      throw Exception("Password lama tidak sesuai");
    }

    if (newPassword.length < 8) {
      throw Exception("Password minimal 8 karakter");
    }

    if (newPassword == oldPassword) {
      throw Exception("Password baru tidak boleh sama dengan password lama");
    }

    if (newPassword != confirmPassword) {
      throw Exception("Konfirmasi password tidak sesuai");
    }
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
