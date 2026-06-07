import 'package:flutter/material.dart';
import 'package:rukun_app_proyek4/repositories/auth_repository.dart';

class KelolaProfileViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  KelolaProfileViewModel(this.authRepository);

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

  Future<bool> submit() async {
    errorMessage = null;
    successMessage = null;

    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty) {
      errorMessage = "Password lama wajib diisi";
      notifyListeners();
      return false;
    }

    if (newPassword.isEmpty) {
      errorMessage = "Password baru wajib diisi";
      notifyListeners();
      return false;
    }

    if (newPassword.length < 6) {
      errorMessage = "Password minimal 6 karakter";
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      errorMessage = "Konfirmasi password tidak sesuai";
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      await authRepository.changePassword(oldPassword, newPassword);

      successMessage = "Password berhasil diubah";

      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
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
