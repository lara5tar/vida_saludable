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
  var selectedEscuelaId = ''.obs; // ID de la escuela seleccionada
  var escuelas = <Map<String, dynamic>>[]
      .obs; // Ahora almacenamos objeto completo con ID y nombre

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
  var editingEscuelaId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
    loadAllUsers();
    loadEscuelas();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Cargar la lista de escuelas desde Firestore
  Future<void> loadEscuelas() async {
    try {
      isLoading.value = true;

      // Primero intentamos cargar desde la colección 'schools' si existe
      var schoolsSnapshot =
          await FirebaseFirestore.instance.collection('schools').get();

      if (schoolsSnapshot.docs.isNotEmpty) {
        escuelas.value = schoolsSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'nombre': doc.data()['nombre'] ?? 'Sin nombre',
          };
        }).toList();
      } else {
        // Si no hay colección 'schools', usamos las escuelas de los usuarios como respaldo
        escuelas.value = getEscuelasUnicas();
      }

      // Seleccionar la primera escuela por defecto si hay alguna
      if (escuelas.isNotEmpty) {
        selectedEscuela.value = escuelas[0]['nombre'];
        selectedEscuelaId.value = escuelas[0]['id'];
      }
    } catch (e) {
      print('Error al cargar escuelas: $e');
      Get.snackbar(
        'Error',
        'No se pudieron cargar las escuelas: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllUsers() async {
    try {
      var result = await FirebaseFirestore.instance.collection('users').get();
      allUsers.value = result.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Si no tenemos escuelas cargadas, intentamos obtenerlas de los usuarios
      if (escuelas.isEmpty) {
        escuelas.value = getEscuelasUnicas();
        if (escuelas.isNotEmpty) {
          selectedEscuela.value = escuelas[0]['nombre'];
          selectedEscuelaId.value = escuelas[0]['id'];
        }
      }
    } catch (e) {
      print('Error al cargar usuarios: $e');
    }
  }

  List<Map<String, dynamic>> getEscuelasUnicas() {
    Set<String> nombreEscuelas = {};
    Map<String, String> escuelasMap =
        {}; // Nombre de escuela -> ID (para evitar duplicados)

    for (var user in allUsers) {
      // Agregar escuela del campo nombre_escuela si existe y no está vacío
      if (user['nombre_escuela'] != null &&
          user['nombre_escuela'].toString().isNotEmpty) {
        nombreEscuelas.add(user['nombre_escuela'].toString());
        // Si tiene schoolId, lo guardamos
        if (user['schoolId'] != null &&
            user['schoolId'].toString().isNotEmpty) {
          escuelasMap[user['nombre_escuela'].toString()] =
              user['schoolId'].toString();
        }
      }

      // Agregar escuela del campo sec_TamMad si existe y no está vacío
      if (user['sec_TamMad'] != null &&
          user['sec_TamMad'].toString().isNotEmpty) {
        nombreEscuelas.add(user['sec_TamMad'].toString());
        // Si tiene schoolId, lo guardamos
        if (user['schoolId'] != null &&
            user['schoolId'].toString().isNotEmpty) {
          escuelasMap[user['sec_TamMad'].toString()] =
              user['schoolId'].toString();
        }
      }
    }

    // Convertir a lista de mapas con nombre e ID
    List<Map<String, dynamic>> listaEscuelas = nombreEscuelas.map((nombre) {
      return {
        'nombre': nombre,
        'id': escuelasMap[nombre] ??
            nombre, // Si no hay ID, usamos el nombre como ID
      };
    }).toList();

    // Ordenar alfabéticamente por nombre
    listaEscuelas.sort(
        (a, b) => a['nombre'].toString().compareTo(b['nombre'].toString()));

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
      final result = await _authService.createSuperUser(
        emailController.text.trim(),
        passwordController.text,
        nameController.text.trim(),
        isAdmin.value,
        schoolId: selectedEscuelaId.value, // Pasar el ID de la escuela
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

    // Solo requerimos escuela para usuarios normales
    if (!isAdmin.value && selectedEscuelaId.isEmpty) {
      Get.snackbar(
        'Error',
        'Debes seleccionar una escuela para usuarios normales',
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
      selectedEscuela.value = escuelas[0]['nombre'];
      selectedEscuelaId.value = escuelas[0]['id'];
    } else {
      selectedEscuela.value = '';
      selectedEscuelaId.value = '';
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
  void startEditingEscuela(
      String userId, String currentEscuela, String currentEscuelaId) {
    editingUserId.value = userId;
    editingEscuela.value = currentEscuela;
    editingEscuelaId.value = currentEscuelaId;
  }

  // Método para cancelar la edición
  void cancelEditingEscuela() {
    editingUserId.value = '';
    editingEscuela.value = '';
    editingEscuelaId.value = '';
  }

  // Método para guardar la escuela de un usuario
  Future<void> saveUserEscuela(
      String userId, String newEscuelaId, String newEscuelaNombre) async {
    isLoading.value = true;
    try {
      // Actualizar el ID de la escuela y el nombre para mantener la compatibilidad
      await _authService.updateSuperUserData(userId,
          {'schoolId': newEscuelaId, 'nombre_escuela': newEscuelaNombre});

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

  // Seleccionar una escuela (para el formulario de creación de usuarios)
  void selectEscuela(String escuelaId, String escuelaNombre) {
    selectedEscuelaId.value = escuelaId;
    selectedEscuela.value = escuelaNombre;
  }

  // Seleccionar una escuela (para editar la escuela de un usuario)
  void selectEditingEscuela(String escuelaId, String escuelaNombre) {
    editingEscuelaId.value = escuelaId;
    editingEscuela.value = escuelaNombre;
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
