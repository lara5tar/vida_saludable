import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/data/services/auth_service.dart';

import '../../../data/services/calculadora_imc_service.dart';
import '../../../data/services/nivel_socioeconomico.dart';
import '../../../data/services/presion_arterial_service.dart';

class UserController extends GetxController {
  // Observable para datos del usuario
  var user = <String, dynamic>{}.obs;

  // Copia editable de datos de usuario
  var userEditInfo = <String, dynamic>{}.obs;

  // Servicio de autenticación
  final authService = Get.find<AuthService>();

  // Estados de la UI
  var isLoading = true.obs;
  var isSaving = false.obs;
  var isEditing = false.obs;
  var accessDenied = false.obs;
  var hasErrors = false.obs;
  var errorMessage = ''.obs;

  // Variables para preguntas no contestadas
  var unansweredQuestions = <String>[].obs;

  // Variables para validación de campos
  var fieldErrors = <String, String>{}.obs;

  // ID del usuario actual
  var currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Limpiamos datos al inicializar
    _resetControllerData();
    // Escuchar cambios en los parámetros de la ruta
    ever(_routeParamListener, _onRouteParamChanged);
    // Iniciar carga de datos
    fetchUserData();
  }

  // Observable para detectar cambios en la ruta
  final _routeParamListener = ''.obs;

  // Método para manejar cambios en la ruta
  void _onRouteParamChanged(String userId) {
    if (userId.isNotEmpty && userId != currentUserId.value) {
      _resetControllerData();
      getUser(userId);
    }
  }

  // Método para resetear completamente los datos del controlador
  void _resetControllerData() {
    user.clear();
    userEditInfo.clear();
    unansweredQuestions.clear();
    fieldErrors.clear();
    isLoading.value = true;
    isSaving.value = false;
    isEditing.value = false;
    accessDenied.value = false;
    hasErrors.value = false;
    errorMessage.value = '';
  }

  // Método principal para cargar datos de usuario
  Future<void> fetchUserData() async {
    final userId = Get.parameters['id'];
    if (userId != null && userId.isNotEmpty) {
      _routeParamListener.value = userId; // Actualizar observable de ruta
      if (userId != currentUserId.value) {
        await getUser(userId);
      }
    } else {
      isLoading.value = false;
      errorMessage.value = 'ID de usuario no proporcionado';
      hasErrors.value = true;
    }
  }

  // Obtener datos del usuario desde Firestore
  Future<void> getUser(String userId) async {
    try {
      // Establecer estado de carga y limpiar datos previos
      isLoading.value = true;
      hasErrors.value = false;
      errorMessage.value = '';
      user.clear();
      userEditInfo.clear();
      accessDenied.value = false;
      unansweredQuestions.clear();
      currentUserId.value = userId; // Guardar ID del usuario actual

      print('🔄 Cargando datos del usuario: $userId');

      var result = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (result.exists) {
        // Crear nuevo mapa para evitar problemas de referencia
        final userData = Map<String, dynamic>.from(result.data() ?? {});
        userData['id'] = userId;

        // Actualizar el observable con los nuevos datos
        user.assignAll(userData);

        print('✅ Datos cargados para usuario: $userId');

        // Verificar acceso a esta escuela
        if (!_checkUserAccess()) {
          return;
        }

        // Inicializar copia para edición
        resetEditableUserInfo();

        // Identificar preguntas no contestadas si es admin
        if (authService.isAdmin.value) {
          findUnansweredQuestions();
        }
      } else {
        errorMessage.value = 'Usuario no encontrado';
        hasErrors.value = true;
        currentUserId.value = '';
        print('❌ Usuario no encontrado: $userId');
      }
    } catch (e) {
      print('❌ Error getting user data: $e');
      errorMessage.value = 'Error al cargar datos: $e';
      hasErrors.value = true;
      user.clear();
      currentUserId.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  // Verificar si el usuario tiene acceso a los datos
  bool _checkUserAccess() {
    // Obtener ID de escuela
    String userSchoolId = _getUserSchoolId();

    // Si el usuario no es administrador y la escuela no coincide, denegar acceso
    if (!authService.isAdmin.value &&
        authService.assignedSchoolId.value.isNotEmpty &&
        userSchoolId != authService.assignedSchoolId.value) {
      print('❌ Acceso denegado: El usuario no tiene acceso a esta escuela');
      print('🏫 Escuela del usuario: $userSchoolId');
      print('🏫 Escuela asignada: ${authService.assignedSchoolId.value}');

      accessDenied.value = true;
      user.clear();
      currentUserId.value = '';

      // Mostrar mensaje de error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Acceso denegado',
          'No tienes permisos para ver los datos de este usuario',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        // Regresar a la pantalla anterior
        Get.back();
      });

      return false;
    }
    return true;
  }

  // Obtener ID de escuela con prioridades
  String _getUserSchoolId() {
    if (user['schoolId'] != null && user['schoolId'].toString().isNotEmpty) {
      return user['schoolId'].toString();
    } else if (user['sec_TamMad'] != null &&
        user['sec_TamMad'].toString().isNotEmpty) {
      return user['sec_TamMad'].toString();
    } else if (user['nombre_escuela'] != null &&
        user['nombre_escuela'].toString().isNotEmpty) {
      return user['nombre_escuela'].toString();
    }
    return '';
  }

  // Reiniciar datos editables
  void resetEditableUserInfo() {
    userEditInfo.clear();
    if (user.isNotEmpty) {
      // Crea una copia profunda de los datos para evitar referencias
      userEditInfo.assignAll(Map<String, dynamic>.from(user));
    }
  }

  // Iniciar modo edición
  void startEditing() {
    resetEditableUserInfo();
    isEditing.value = true;
    fieldErrors.clear();
  }

  // Cancelar modo edición
  void cancelEditing() {
    isEditing.value = false;
    fieldErrors.clear();
  }

  // Guardar cambios del usuario
  Future<bool> saveUser() async {
    if (!validateUserData()) {
      Get.snackbar(
        'Datos inválidos',
        'Por favor corrige los errores en los campos marcados',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return false;
    }

    try {
      isSaving.value = true;

      // Convertir tipos de datos según corresponda
      _convertUserDataTypes();

      final userId = user['id'];
      if (userId == null || userId.toString().isEmpty) {
        throw Exception('ID de usuario no válido');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId.toString())
          .update(userEditInfo);

      // Actualizar datos locales con una copia nueva
      user.assignAll(Map<String, dynamic>.from(userEditInfo));

      // Actualizar preguntas no contestadas después de guardar
      if (authService.isAdmin.value) {
        findUnansweredQuestions();
      }

      Get.snackbar(
        'Datos actualizados',
        'Los datos del usuario han sido actualizados correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      isEditing.value = false;
      return true;
    } catch (e) {
      print('Error saving user data: $e');
      Get.snackbar(
        'Error al guardar',
        'No se pudieron actualizar los datos: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Convertir tipos de datos para almacenamiento
  void _convertUserDataTypes() {
    // Convertir edad a entero
    userEditInfo['age'] = int.tryParse(userEditInfo['age'].toString()) ?? 0;

    // Convertir medidas a double
    userEditInfo['peso'] =
        double.tryParse(userEditInfo['peso'].toString()) ?? 0;
    userEditInfo['estatura'] =
        double.tryParse(userEditInfo['estatura'].toString()) ?? 0;
    userEditInfo['cintura'] =
        double.tryParse(userEditInfo['cintura'].toString()) ?? 0;
    userEditInfo['cadera'] =
        double.tryParse(userEditInfo['cadera'].toString()) ?? 0;
    userEditInfo['sistolica'] =
        double.tryParse(userEditInfo['sistolica'].toString()) ?? 0;
    userEditInfo['diastolica'] =
        double.tryParse(userEditInfo['diastolica'].toString()) ?? 0;
  }

  // Validar datos antes de guardar
  bool validateUserData() {
    fieldErrors.clear();
    bool isValid = true;

    // Validar nombre
    if (userEditInfo['name'] == null ||
        userEditInfo['name'].toString().trim().isEmpty) {
      fieldErrors['name'] = 'El nombre es obligatorio';
      isValid = false;
    }

    // Validar edad
    final age = int.tryParse(userEditInfo['age'].toString());
    if (age == null || age <= 0 || age > 120) {
      fieldErrors['age'] = 'Edad inválida';
      isValid = false;
    }

    // Validar medidas (si están presentes)
    if (userEditInfo['peso'] != null) {
      final peso = double.tryParse(userEditInfo['peso'].toString());
      if (peso == null || peso <= 0 || peso > 500) {
        fieldErrors['peso'] = 'Peso inválido';
        isValid = false;
      }
    }

    if (userEditInfo['estatura'] != null) {
      final estatura = double.tryParse(userEditInfo['estatura'].toString());
      if (estatura == null || estatura <= 0 || estatura > 3) {
        fieldErrors['estatura'] = 'Estatura inválida';
        isValid = false;
      }
    }

    return isValid;
  }

  // Actualizar un campo específico
  void updateField(String field, dynamic value) {
    userEditInfo[field] = value;

    // Limpiar error específico si existe
    if (fieldErrors.containsKey(field)) {
      fieldErrors.remove(field);
    }
  }

  // Eliminar usuario
  Future<bool> deleteUser() async {
    try {
      isLoading.value = true;

      // Confirmación previa (debería manejarse en la UI)
      const confirmedInUI = true;

      if (!confirmedInUI) {
        return false;
      }

      final userId = user['id']?.toString();
      if (userId == null || userId.isEmpty) {
        throw Exception('ID de usuario no válido');
      }

      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      Get.snackbar(
        'Usuario eliminado',
        'El usuario ha sido eliminado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Limpiar datos después de eliminar
      _resetControllerData();
      currentUserId.value = '';

      // Navegación de regreso a la lista de usuarios
      Get.back();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      Get.snackbar(
        'Error al eliminar',
        'No se pudo eliminar el usuario: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Función para identificar preguntas no contestadas
  void findUnansweredQuestions() {
    unansweredQuestions.clear();

    for (int i = 1; i <= 51; i++) {
      String key = 'pr$i';
      // Si la pregunta no existe o su valor es nulo o vacío o cero
      if (!user.containsKey(key) ||
          user[key] == null ||
          user[key].toString().isEmpty ||
          user[key].toString() == '0') {
        unansweredQuestions.add(key);
      }
    }
  }

  // MÉTODOS DE CÁLCULO DE ÍNDICES Y EVALUACIONES

  String getIMC(Map<String, dynamic> userData) {
    final peso = double.tryParse(userData['peso'].toString());
    final estatura = double.tryParse(userData['estatura'].toString());

    if (peso == null || estatura == null || estatura == 0) {
      return 'Datos inválidos';
    }

    final imc = peso / (estatura * estatura);
    return CalculadoraIMC.calcular(
      imc,
      userData['age'] ?? 0,
      userData['gender'].toString().toLowerCase(),
    );
  }

  String getIndiceCircunferenciaCintura() {
    final cintura = double.tryParse(user['cintura'].toString());
    final estatura = double.tryParse(user['estatura'].toString());

    if (cintura == null || estatura == null || estatura == 0) {
      return 'Datos inválidos';
    }

    final icc = cintura / estatura;
    final ratio = icc.toStringAsFixed(2);

    return '${icc >= 0.50 ? 'Incrementa riesgos cardio-metabólicos' : 'Saludable'} ($ratio)';
  }

  String getIndiceCircunferenciaCadera() {
    final cintura = double.tryParse(user['cintura'].toString());
    final cadera = double.tryParse(user['cadera'].toString());
    final gender = user['gender'].toString().toLowerCase();

    if (cintura == null || cadera == null || cadera == 0) {
      return 'Datos inválidos';
    }

    final icc = cintura / cadera;
    final ratio = icc.toStringAsFixed(2);

    if (gender == 'masculino' || gender == 'hombre') {
      return '${icc <= 0.90 ? 'Saludable' : 'Con riesgos cardio-metabólicos'} ($ratio)';
    } else if (gender == 'femenino' || gender == 'mujer') {
      return '${icc <= 0.85 ? 'Saludable' : 'Con riesgos cardio-metabólicos'} ($ratio)';
    }

    return 'Género no válido';
  }

  String getPresionArterial() {
    try {
      final sistolica = double.tryParse(user['sistolica'].toString()) ?? 0;
      final diastolica = double.tryParse(user['diastolica'].toString()) ?? 0;
      final edad = int.tryParse(user['age'].toString()) ?? 0;
      final sexo = user['gender'].toString().toLowerCase();

      return EvaluadorPresionArterial.evaluar(
          sistolica, diastolica, edad, sexo == 'hombre' ? 'hombre' : 'mujer');
    } catch (e) {
      return 'Datos inválidos para presión arterial';
    }
  }

  getNivelSE() {
    return SocioEconomicCalculator.calculateNSE(user);
  }

  Map<String, dynamic> getEstiloVidaTotal() {
    int puntajeTotal = 0;

    // Sumar todas las preguntas de pr1 a pr51
    for (int i = 1; i <= 51; i++) {
      String key = 'pr$i';
      if (user.containsKey(key)) {
        puntajeTotal += int.tryParse(user[key].toString()) ?? 0;
      }
    }

    String evaluacion;
    String color;

    if (puntajeTotal >= 204) {
      evaluacion = 'Estilo de vida saludable';
      color = 'green';
    } else if (puntajeTotal >= 170) {
      evaluacion = 'Estilo de vida regular';
      color = 'yellow';
    } else {
      evaluacion = 'Mal estilo de vida';
      color = 'red';
    }

    return {
      'puntaje': puntajeTotal,
      'evaluacion': evaluacion,
      'color': color,
    };
  }

  @override
  void onClose() {
    // Asegurarnos de limpiar los datos cuando se cierra el controlador
    _resetControllerData();
    super.onClose();
  }
}
