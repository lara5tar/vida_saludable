import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final adminEmailController = TextEditingController();
  final adminPasswordController = TextEditingController();
  final confirmAdminPasswordController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool obscurePassword = true.obs;
  RxBool isCreatingAdmin = false.obs;
  RxBool obscureAdminPassword = true.obs;
  RxBool obscureConfirmAdminPassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    adminEmailController.dispose();
    adminPasswordController.dispose();
    confirmAdminPasswordController.dispose();
    super.onClose();
  }

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleObscureAdminPassword() {
    obscureAdminPassword.value = !obscureAdminPassword.value;
  }

  void toggleObscureConfirmAdminPassword() {
    obscureConfirmAdminPassword.value = !obscureConfirmAdminPassword.value;
  }

  void toggleCreatingAdmin() {
    isCreatingAdmin.value = !isCreatingAdmin.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Por favor ingresa tu correo y contraseña',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final userCredential = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (userCredential != null) {
        // Si el login fue exitoso, redirigir a la pantalla principal
        Get.offAllNamed(Routes.HOME);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createInitialAdmin() async {
    // Validar que los campos estén completos
    if (adminEmailController.text.isEmpty ||
        !GetUtils.isEmail(adminEmailController.text)) {
      Get.snackbar(
        'Error',
        'Por favor ingresa un correo electrónico válido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (adminPasswordController.text.isEmpty ||
        adminPasswordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'La contraseña debe tener al menos 6 caracteres',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (adminPasswordController.text != confirmAdminPasswordController.text) {
      Get.snackbar(
        'Error',
        'Las contraseñas no coinciden',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final created = await _authService.checkAndCreateInitialAdmin(
        adminEmailController.text.trim(),
        adminPasswordController.text,
      );

      if (created) {
        emailController.text = adminEmailController.text;
        passwordController.text = adminPasswordController.text;
        isCreatingAdmin.value = false;
        Get.snackbar(
          'Éxito',
          'Administrador creado correctamente. Ya puedes iniciar sesión.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Información',
          'Ya existen usuarios en el sistema. No se puede crear el administrador inicial.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
