import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> user = Rx<User?>(null);

  // Variable observable para verificar si el usuario actual es administrador
  RxBool isAdmin = false.obs;
  RxBool isInitialized = false.obs;

  // Variable para almacenar el ID de la escuela asignada al usuario
  RxString assignedSchoolId = RxString('');

  // Método para inicializar el servicio
  Future<AuthService> init() async {
    try {
      user.value = _auth.currentUser;

      // Listener para cambios en el estado de autenticación
      _auth.authStateChanges().listen((User? firebaseUser) async {
        user.value = firebaseUser;

        // Si hay un usuario autenticado, verificar si es administrador
        if (firebaseUser != null) {
          await checkAdminStatus();
        } else {
          isAdmin.value = false;
          assignedSchoolId.value = '';
        }

        // Marcar como inicializado después de configurar el estado inicial
        if (!isInitialized.value) {
          isInitialized.value = true;
        }
      });

      // Si hay un usuario actualmente autenticado, verificamos su estado
      if (user.value != null) {
        await checkAdminStatus();
      }

      // Marcar como inicializado
      isInitialized.value = true;

      return this;
    } catch (e) {
      print('Error al inicializar AuthService: $e');
      isInitialized.value = true;
      return this;
    }
  }

  // Verificar si el usuario actual es administrador
  Future<void> checkAdminStatus() async {
    try {
      if (user.value != null) {
        final userData = await _firestore
            .collection('superUsers')
            .doc(user.value!.uid)
            .get();

        // Verificar si existe el documento
        if (!userData.exists) {
          print(
              '⚠️ El documento del usuario no existe en Firestore: ${user.value!.uid}');
          isAdmin.value = false;
          assignedSchoolId.value = '';
          return;
        }

        final adminStatus = userData.data()?['isAdmin'] == true;
        isAdmin.value = adminStatus;

        // Obtener el ID de la escuela asignada (si existe)
        assignedSchoolId.value = userData.data()?['nombre_escuela'] ?? '';

        print(
            '✅ Verificación de administrador para el usuario ${user.value!.email}: ${isAdmin.value}');
        print('📄 Datos del usuario: ${userData.data()}');
        print('🏫 Escuela asignada: ${assignedSchoolId.value}');
      }
    } catch (e) {
      print('❌ Error al verificar el estado de administrador: $e');
      isAdmin.value = false;
      assignedSchoolId.value = '';
    }
  }

  // Obtener el ID de la escuela asignada al usuario actual
  String getAssignedSchoolId() {
    return assignedSchoolId.value;
  }

  // Verificar si el usuario tiene acceso a una escuela específica
  bool hasAccessToSchool(String schoolId) {
    // Los administradores tienen acceso a todas las escuelas
    if (isAdmin.value) return true;

    // Los usuarios normales solo tienen acceso a su escuela asignada
    return assignedSchoolId.value == schoolId;
  }

  // Iniciar sesión con correo y contraseña
  Future<UserCredential?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await checkAdminStatus();
      return result;
    } catch (e) {
      Get.snackbar(
        'Error de autenticación',
        _getAuthErrorMessage(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      await _auth.signOut();
      user.value = null;
      isAdmin.value = false;
      assignedSchoolId.value = '';
    } catch (e) {
      Get.snackbar(
        'Error al cerrar sesión',
        'Ocurrió un error al cerrar la sesión',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Verificar si existen usuarios registrados y crear uno administrador si no hay
  Future<bool> checkAndCreateInitialAdmin(String email, String password) async {
    try {
      // Verificar si hay usuarios en Firestore
      final usersSnapshot =
          await _firestore.collection('superUsers').limit(1).get();

      // Si no hay usuarios, crear el primer administrador
      if (usersSnapshot.docs.isEmpty) {
        // Crear usuario en Firebase Auth
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Guardar datos adicionales en Firestore
        await _firestore
            .collection('superUsers')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'name': 'Administrador',
          'isAdmin': true,
          'createdAt': Timestamp.now(),
        });

        Get.snackbar(
          'Administrador creado',
          'Se ha creado el primer usuario administrador',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      }

      return false;
    } catch (e) {
      Get.snackbar(
        'Error al crear administrador',
        _getAuthErrorMessage(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Obtener todos los usuarios del sistema (solo para administradores)
  Future<List<Map<String, dynamic>>> getAllSuperUsers() async {
    try {
      if (!isAdmin.value) {
        throw Exception('No tienes permisos de administrador');
      }

      final querySnapshot = await _firestore.collection('superUsers').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener los usuarios: $e');
      return [];
    }
  }

  // Crear un nuevo usuario (solo para administradores)
  Future<bool> createSuperUser(
      String email, String password, String name, bool makeAdmin,
      {String schoolId = ''}) async {
    try {
      if (!isAdmin.value) {
        throw Exception('No tienes permisos de administrador');
      }

      // Crear usuario en Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Guardar datos adicionales en Firestore
      await _firestore
          .collection('superUsers')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'name': name,
        'isAdmin': makeAdmin,
        'schoolId': schoolId, // Guardar la escuela asignada
        'createdAt': Timestamp.now(),
      });

      Get.snackbar(
        'Usuario creado',
        'El usuario se ha creado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error al crear usuario',
        _getAuthErrorMessage(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Actualizar datos de usuario (solo para administradores)
  Future<bool> updateSuperUserData(
      String userId, Map<String, dynamic> data) async {
    try {
      if (!isAdmin.value) {
        throw Exception('No tienes permisos de administrador');
      }

      await _firestore.collection('superUsers').doc(userId).update(data);

      Get.snackbar(
        'Usuario actualizado',
        'Los datos del usuario se han actualizado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error al actualizar usuario',
        'Ocurrió un error al actualizar los datos del usuario',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Cambiar contraseña de usuario (solo para administradores)
  Future<bool> changeUserPassword(String userId, String newPassword) async {
    try {
      if (!isAdmin.value) {
        throw Exception('No tienes permisos de administrador');
      }

      // Esta operación requiere un token de admin o que el usuario esté autenticado
      // Para simplificar, obtendríamos el correo del usuario y le enviaríamos un correo de restablecimiento
      final userData =
          await _firestore.collection('superUsers').doc(userId).get();
      final email = userData.data()?['email'];

      if (email != null) {
        await _auth.sendPasswordResetEmail(email: email);

        Get.snackbar(
          'Correo enviado',
          'Se ha enviado un correo para restablecer la contraseña',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } else {
        throw Exception('No se encontró el correo del usuario');
      }
    } catch (e) {
      Get.snackbar(
        'Error al cambiar contraseña',
        'Ocurrió un error al cambiar la contraseña del usuario',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Método para forzar la concesión de permisos de administrador a un usuario por su correo
  Future<bool> forceGrantAdminRights(String email) async {
    try {
      if (user.value == null || user.value!.email != email) {
        Get.snackbar(
          'Error',
          'Debes iniciar sesión con la cuenta que deseas convertir en administrador',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Actualizar en Firestore el estado de administrador
      await _firestore.collection('superUsers').doc(user.value!.uid).set({
        'email': email,
        'name': 'Administrador',
        'isAdmin': true,
        'createdAt': Timestamp.now(),
      }, SetOptions(merge: true));

      // Verificar el estado de nuevo
      await checkAdminStatus();

      Get.snackbar(
        'Permisos actualizados',
        'Se han concedido permisos de administrador a esta cuenta',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      print('Error al conceder permisos de administrador: $e');
      Get.snackbar(
        'Error',
        'No se pudieron conceder permisos de administrador: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // Método para obtener mensajes de error más amigables
  String _getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No existe una cuenta con este correo electrónico';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'email-already-in-use':
          return 'Este correo electrónico ya está registrado';
        case 'weak-password':
          return 'La contraseña es demasiado débil';
        case 'invalid-email':
          return 'El formato del correo electrónico es inválido';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return 'Error de autenticación: $error';
  }
}
