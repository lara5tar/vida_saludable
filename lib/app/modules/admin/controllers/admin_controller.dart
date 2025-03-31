import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Controladores para el formulario de creación de usuarios
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Reemplazamos el TextEditingController por una variable reactiva para la escuela seleccionada
  var selectedEscuela = ''.obs;
  var escuelas = <String>[].obs;

  RxBool isAdmin = false.obs;
  RxBool isLoading = false.obs;
  RxBool obscurePassword = true.obs;
  RxBool obscureConfirmPassword = true.obs;

  // Lista de usuarios
  RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;

  // Variable reactiva para edición de escuela
  var editingUserId = ''.obs;
  var editingEscuela = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadAllUsers();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> loadAllUsers() async {
    try {
      var result = await FirebaseFirestore.instance.collection('users').get();
      allUsers.value = result.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      escuelas.value = getEscuelasUnicas();
      if (escuelas.isNotEmpty) {
        selectedEscuela.value = escuelas[0];
      }
    } catch (e) {
      print('Error al cargar usuarios: $e');
    }
  }

  List<String> getEscuelasUnicas() {
    Set<String> escuelas = {};

    for (var user in allUsers) {
      // Agregar escuela del campo nombre_escuela si existe y no está vacío
      if (user['nombre_escuela'] != null &&
          user['nombre_escuela'].toString().isNotEmpty) {
        escuelas.add(user['nombre_escuela'].toString());
      }
      // Agregar escuela del campo sec_TamMad si existe y no está vacío
      if (user['sec_TamMad'] != null &&
          user['sec_TamMad'].toString().isNotEmpty) {
        escuelas.add(user['sec_TamMad'].toString());
      }
    }

    // Convertir a lista y ordenar alfabéticamente
    var listaEscuelas = escuelas.toList()..sort();
    return listaEscuelas;
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    try {
      final usersList = await _authService.getAllSuperUsers();
      users.assignAll(usersList);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> createUser() async {
    if (!validateForm()) {
      return;
    }

    isLoading.value = true;
    try {
      final userData = {
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'name': nameController.text.trim(),
        'isAdmin': isAdmin.value,
        'nombre_escuela': selectedEscuela.value,
      };

      final result = await _authService.createSuperUser(
        emailController.text.trim(),
        passwordController.text,
        nameController.text.trim(),
        isAdmin.value,
      );

      if (result) {
        clearForm();
        await loadUsers();
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool validateForm() {
    if (nameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'El nombre es obligatorio',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (emailController.text.isEmpty ||
        !GetUtils.isEmail(emailController.text)) {
      Get.snackbar(
        'Error',
        'Ingresa un correo electrónico válido',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'La contraseña debe tener al menos 6 caracteres',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Las contraseñas no coinciden',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedEscuela.isEmpty) {
      Get.snackbar(
        'Error',
        'Debes seleccionar una escuela',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    if (escuelas.isNotEmpty) {
      selectedEscuela.value = escuelas[0];
    } else {
      selectedEscuela.value = '';
    }
    isAdmin.value = false;
  }

  Future<void> changeUserAdminStatus(String userId, bool newStatus) async {
    isLoading.value = true;
    try {
      await _authService.updateSuperUserData(userId, {'isAdmin': newStatus});
      await loadUsers();
    } finally {
      isLoading.value = false;
    }
  }

  // Método para iniciar la edición de la escuela de un usuario
  void startEditingEscuela(String userId, String currentEscuela) {
    editingUserId.value = userId;
    editingEscuela.value = currentEscuela;
  }

  // Método para cancelar la edición
  void cancelEditingEscuela() {
    editingUserId.value = '';
    editingEscuela.value = '';
  }

  // Método para guardar la escuela de un usuario
  Future<void> saveUserEscuela(String userId, String newEscuela) async {
    isLoading.value = true;
    try {
      await _authService
          .updateSuperUserData(userId, {'nombre_escuela': newEscuela});
      Get.snackbar(
        'Éxito',
        'Escuela actualizada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      cancelEditingEscuela();
      await loadUsers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la escuela: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetUserPassword(String userId) async {
    isLoading.value = true;
    try {
      await _authService.changeUserPassword(userId, passwordController.text);
      Get.snackbar(
        'Éxito',
        'Contraseña restablecida con éxito',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
