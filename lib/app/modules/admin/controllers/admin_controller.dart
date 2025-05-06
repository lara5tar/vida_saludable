import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Constante para el correo del superadministrador que no puede ser modificado
  static const String SUPER_ADMIN_EMAIL = 'admin@vidasaludable.com';

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

  // Controladores para edición de usuarios
  final editNameController = TextEditingController();
  final editEmailController = TextEditingController();
  RxBool editIsAdmin = false.obs;

  // Estado de edición
  RxBool isEditingUser = false.obs;

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
    editNameController.dispose();
    editEmailController.dispose();
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

  // Iniciar edición de un usuario
  void startEditingUser(Map<String, dynamic> user) {
    editingUserId.value = user['id'];
    editNameController.text = user['name'] ?? '';
    editEmailController.text = user['email'] ?? '';
    editIsAdmin.value = user['isAdmin'] == true;
    editingEscuelaId.value = user['schoolId'] ?? '';
    editingEscuela.value = user['nombre_escuela'] ?? '';
    isEditingUser.value = true;
  }

  // Cancelar edición
  void cancelEditingUser() {
    editingUserId.value = '';
    editNameController.clear();
    editEmailController.clear();
    editingEscuelaId.value = '';
    editingEscuela.value = '';
    editIsAdmin.value = false;
    isEditingUser.value = false;
  }

  // Guardar cambios del usuario en edición
  Future<void> saveUserEdits() async {
    // Verificar si el usuario que se está editando es el superadministrador
    final userToEdit = users.firstWhere(
        (user) => user['id'] == editingUserId.value,
        orElse: () => {});
    if (userToEdit.isNotEmpty && userToEdit['email'] == SUPER_ADMIN_EMAIL) {
      Get.snackbar(
        'Error',
        'No se puede modificar al superadministrador',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      cancelEditingUser();
      return;
    }

    if (editNameController.text.isEmpty) {
      Get.snackbar('Error', 'El nombre es obligatorio',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (editEmailController.text.isEmpty ||
        !GetUtils.isEmail(editEmailController.text)) {
      Get.snackbar('Error', 'Ingresa un correo electrónico válido',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Solo requerimos escuela para usuarios normales
    if (!editIsAdmin.value && editingEscuelaId.isEmpty) {
      Get.snackbar(
          'Error', 'Debes seleccionar una escuela para usuarios normales',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final Map<String, dynamic> updatedData = {
        'name': editNameController.text.trim(),
        'email': editEmailController.text.trim(),
        'isAdmin': editIsAdmin.value,
        'schoolId': editingEscuelaId.value,
        'nombre_escuela': editingEscuela.value,
      };

      await _authService.updateSuperUserData(editingUserId.value, updatedData);

      Get.snackbar('Éxito', 'Usuario actualizado correctamente',
          backgroundColor: Colors.green, colorText: Colors.white);

      cancelEditingUser();
      await loadUsers();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el usuario: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Verifica si un usuario es el superadministrador principal
  bool isSuperAdmin(Map<String, dynamic> user) {
    return user['email'] == SUPER_ADMIN_EMAIL;
  }

  // Verifica si un usuario puede ser editado
  bool canEditUser(Map<String, dynamic> user) {
    return user['email'] != SUPER_ADMIN_EMAIL;
  }

  // Verifica si un usuario puede ser eliminado
  bool canDeleteUser(Map<String, dynamic> user) {
    // No permitir eliminar si es el superadmin o si es administrador
    if (user['email'] == SUPER_ADMIN_EMAIL) {
      return false;
    }
    // Solo permitir eliminar si NO es un administrador
    return user['isAdmin'] != true;
  }

  // Eliminar usuario
  Future<void> deleteUser(String userId) async {
    // Verificar si el usuario existe en la lista y obtener sus datos
    final userToDelete =
        users.firstWhere((user) => user['id'] == userId, orElse: () => {});

    // Si no se encontró el usuario, mostrar error
    if (userToDelete.isEmpty) {
      Get.snackbar('Error', 'Usuario no encontrado',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Verificar si el usuario es el superadministrador
    if (userToDelete['email'] == SUPER_ADMIN_EMAIL) {
      Get.snackbar('Error', 'No se puede eliminar el superadministrador',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Verificar si el usuario es administrador
    if (userToDelete['isAdmin'] == true) {
      Get.snackbar('Error', 'No se puede eliminar un usuario administrador',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      await _authService.deleteSuperUser(userId);

      Get.snackbar('Éxito', 'Usuario eliminado correctamente',
          backgroundColor: Colors.green, colorText: Colors.white);

      await loadUsers();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar el usuario: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
