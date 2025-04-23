import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/data/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../../data/services/calculadora_imc_service.dart';
import '../../../data/services/random_forms.dart';

class SearchController extends GetxController {
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var filters = <String, dynamic>{}.obs;
  final authService = Get.find<AuthService>();

  var isTestUser = false.obs;

  final itemsPerPage = 10.obs;
  final currentPage = 0.obs;

  @override
  void onInit() {
    getUsers();
    super.onInit();
  }

  var users = <Map<String, dynamic>>[].obs;
  var filteredUsers = <Map<String, dynamic>>[].obs;

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      isLoading.value = true;

      // Crear consulta base
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('users');

      // Si el usuario no es administrador, filtrar por escuela asignada
      if (!authService.isAdmin.value &&
          authService.assignedSchoolId.value.isNotEmpty) {
        print(
            '🔍 Filtrando por escuela: ${authService.assignedSchoolId.value}');
        // Filtrar usuarios por el ID de escuela asignada
        var queryByTamMad = query.where('sec_TamMad',
            isEqualTo: authService.assignedSchoolId.value);

        var resultByTamMad = await queryByTamMad.get();

        // Si encontramos resultados con sec_TamMad, usamos esta consulta
        if (resultByTamMad.docs.isNotEmpty) {
          query = queryByTamMad;
        } else {
          // Si no, intentamos filtrar por nombre_escuela
          query = query.where('nombre_escuela',
              isEqualTo: authService.assignedSchoolId.value);
        }
      }

      var result = await query.get();

      users.value = result.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();

      filterUsers();
      return users;
    } catch (e) {
      print('❌ Error al obtener usuarios: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  List<String> getEscuelasUnicas() {
    Set<String> escuelas = {};

    for (var user in users) {
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

  List<String> getCiudadesUnicas() {
    Set<String> ciudades = {};

    for (var user in users) {
      // Agregar ciudad del campo ciudad si existe y no está vacío
      if (user['municipio'] != null &&
          user['municipio'].toString().isNotEmpty) {
        ciudades.add(user['municipio'].toString());
      }
    }

    // Convertir a lista y ordenar alfabéticamente
    var listaCiudades = ciudades.toList()..sort();
    return listaCiudades;
  }

  void filterUsers() {
    isLoading.value = true;
    try {
      var filtered = users.where((user) {
        // Aplicar filtro de búsqueda por texto
        if (searchQuery.value.isNotEmpty) {
          final name = user['name'].toString().toLowerCase();
          if (!name.contains(searchQuery.value.toLowerCase())) {
            return false;
          }
        }

        // Aplicar otros filtros
        bool matches = true;
        filters.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            if (key == 'age_range') {
              int userAge = int.tryParse(user['age'].toString()) ?? 0;
              if (value == 'Menor a 10 años') {
                if (userAge >= 10) matches = false;
              } else if (value == 'Mayor a 20 años') {
                if (userAge <= 20) matches = false;
              } else {
                int filterAge = int.tryParse(value) ?? 0;
                if (userAge != filterAge) matches = false;
              }
            } else if (key == 'escuela') {
              // Verificar tanto nombre_escuela como sec_TamMad
              bool escuelaMatch = false;
              if (user['nombre_escuela'] != null) {
                escuelaMatch =
                    user['nombre_escuela'].toString() == value.toString();
              }
              if (!escuelaMatch && user['sec_TamMad'] != null) {
                escuelaMatch =
                    user['sec_TamMad'].toString() == value.toString();
              }
              if (!escuelaMatch) matches = false;
            } else if (user[key].toString().toLowerCase() !=
                value.toString().toLowerCase()) {
              matches = false;
            }
          }
        });
        return matches;
      }).toList();

      // Ordenar alfabéticamente por nombre
      filtered.sort((a, b) => (a['name'].toString().toLowerCase())
          .compareTo(b['name'].toString().toLowerCase()));

      filteredUsers.value = filtered;
    } finally {
      isLoading.value = false;
    }
  }

  int get totalPages => (filteredUsers.length / itemsPerPage.value).ceil();

  List<Map<String, dynamic>> get paginatedUsers {
    if (filteredUsers.isEmpty) return [];

    final startIndex = currentPage.value * itemsPerPage.value;
    final endIndex = startIndex + itemsPerPage.value > filteredUsers.length
        ? filteredUsers.length
        : startIndex + itemsPerPage.value;

    if (startIndex >= filteredUsers.length) {
      currentPage.value = totalPages - 1;
      return paginatedUsers;
    }

    return filteredUsers.sublist(startIndex, endIndex);
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      currentPage.value = page;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    currentPage.value = 0; // Reset to first page when applying new filters
    filterUsers();
  }

  void updateFilter(String key, dynamic value) {
    // No permitir que usuarios no administradores usen el filtro de escuela
    if (key == 'escuela' && !authService.isAdmin.value) {
      Get.snackbar(
        'Acceso restringido',
        'Solo los administradores pueden filtrar por escuela',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    filters[key] = value;
    currentPage.value = 0; // Reset to first page when applying new filters
    filterUsers();
  }

  void clearFilters() {
    filters.clear();
    currentPage.value = 0; // Reset to first page when clearing filters
    filterUsers();
  }

  String getIMC(user) {
    final peso = double.tryParse(user['peso'].toString());
    final estatura = double.tryParse(user['estatura'].toString());

    if (peso == null || estatura == null || estatura == 0) {
      return 'Datos inválidos';
    }

    final imc = peso / (estatura * estatura);
    return CalculadoraIMC.calcular(
        imc, user['age'], user['gender'].toLowerCase());
  }

  String getIndiceCircunferenciaCintura(user) {
    final cintura = double.tryParse(user['cintura'].toString());
    final estatura = double.tryParse(user['estatura'].toString());

    if (cintura == null || estatura == null || estatura == 0) {
      return 'Datos inválidos';
    }

    final icc = cintura / estatura;
    final ratio = icc.toStringAsFixed(2);

    return '$ratio - ${icc >= 0.50 ? 'Incrementa riesgos cardio-metabólicos' : 'Saludable'}';
  }

  String getIndiceCircunferenciaCadera(user) {
    final cintura = double.tryParse(user['cintura'].toString());
    final cadera = double.tryParse(user['cadera'].toString());
    final gender = user['gender'].toString().toLowerCase();

    if (cintura == null || cadera == null || cadera == 0) {
      return 'Datos inválidos';
    }

    final icc = cintura / cadera;
    final ratio = icc.toStringAsFixed(2);

    if (gender == 'masculino' || gender == 'hombre') {
      return '$ratio - ${icc <= 0.90 ? 'Saludable' : 'Con riesgos cardio-metabólicos'}';
    } else if (gender == 'femenino' || gender == 'mujer') {
      return '$ratio - ${icc <= 0.85 ? 'Saludable' : 'Con riesgos cardio-metabólicos'}';
    }

    return 'Género no válido';
  }

  String totalPersonas() => users.length.toString();

  Map<String, String> getTotalesPorGenero() {
    final totales = {'hombres': '0', 'mujeres': '0'};

    for (var user in users) {
      final gender = user['gender'].toString().toLowerCase();
      if (gender == 'masculino' || gender == 'hombre') {
        totales['hombres'] = ((int.parse(totales['hombres']!) + 1)).toString();
      } else if (gender == 'femenino' || gender == 'mujer') {
        totales['mujeres'] = ((int.parse(totales['mujeres']!) + 1)).toString();
      }
    }

    return totales;
  }

  Future<void> generateTestUser() async {
    final generator = RandomFormGenerator();
    generator.uploadRandomPersona();
  }
}
