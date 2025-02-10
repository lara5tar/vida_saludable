import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:math';

import '../../../data/services/calculadora_imc_service.dart';

class SearchController extends GetxController {
  var isLoading = true.obs;
  var searchQuery = ''.obs;
  var filters = <String, dynamic>{}.obs;

  var isTestUser = false.obs;

  @override
  void onInit() {
    getUsers();
    super.onInit();
  }

  var users = <Map<String, dynamic>>[].obs;
  var filteredUsers = <Map<String, dynamic>>[].obs;

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      var result = await FirebaseFirestore.instance.collection('users').get();
      users.value = result.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data

        // //imprimir todos los datos del usuario con tipo de dato
        // for (var key in data.keys) {
        //   print('$key: ${data[key]} -> ${data[key].runtimeType}');
        // }
        // print('---------------------------------');

        return data;
      }).toList();
      filterUsers();
      isLoading.value = false;
      return users;
    } catch (e) {
      return [];
    }
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

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterUsers();
  }

  void updateFilter(String key, dynamic value) {
    filters[key] = value;
    filterUsers();
  }

  void clearFilters() {
    filters.clear();
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
    try {
      final random = Random();
      final nombres = [
        'Ana',
        'Juan',
        'María',
        'Pedro',
        'Luis',
        'Carmen',
        'José',
        'Patricia'
      ];
      final apellidos = [
        'García',
        'Hernández',
        'López',
        'Martínez',
        'Rodríguez',
        'González'
      ];
      final municipios = [
        'Tampico',
        'Madero',
        'Altamira',
        'Victoria',
        'Reynosa',
        'Matamoros'
      ];
      final escuelas = ['UAT', 'TecNM', 'UPN', 'ITCM', 'UPALT'];

      final userData = {
        'pr49': (random.nextInt(5) + 1).toString(),
        'num_integrantes': random.nextInt(6) + 1,
        'pr14': (random.nextInt(5) + 1).toString(),
        'aplicacion_libro': 'String',
        'pr7': (random.nextInt(5) + 1).toString(),
        'gender': random.nextBool() ? 'Mujer' : 'Hombre',
        'ap_cuestionarios': random.nextBool(),
        'pr39': (random.nextInt(5) + 1).toString(),
        'ap_resumen': random.nextBool(),
        'pr23': (random.nextInt(5) + 1).toString(),
        'pr20': (random.nextInt(5) + 1).toString(),
        'pr9': (random.nextInt(5) + 1).toString(),
        'ap_talleres': random.nextBool(),
        'pr4': (random.nextInt(5) + 1).toString(),
        'pr45': (random.nextInt(5) + 1).toString(),
        'sec_TamMad': 'String',
        'pr25': (random.nextInt(5) + 1).toString(),
        'pr28': (random.nextInt(5) + 1).toString(),
        'pr38': (random.nextInt(5) + 1).toString(),
        'nombre_libro': '',
        'tipo_escuela': random.nextBool() ? 'Pública' : 'Privada',
        'pr37': (random.nextInt(5) + 1).toString(),
        'mom_work': random.nextBool() ? 'Si' : 'No',
        'pr2': (random.nextInt(5) + 1).toString(),
        'integrantes_trabajando': (random.nextInt(4) + 1).toString(),
        'internet': random.nextBool() ? 'Si Tiene' : 'No Tiene',
        'pr18': (random.nextInt(5) + 1).toString(),
        'nivelEduFam': 'Primaria Completa',
        'pr47': (random.nextInt(5) + 1).toString(),
        'pr30': (random.nextInt(5) + 1).toString(),
        'ap_juegos': random.nextBool(),
        'pr27': (random.nextInt(5) + 1).toString(),
        'vida_saludable': 'String',
        'name':
            '${nombres[random.nextInt(nombres.length)]} ${apellidos[random.nextInt(apellidos.length)]} ${apellidos[random.nextInt(apellidos.length)]}',
        'pr42': (random.nextInt(5) + 1).toString(),
        'pr24': (random.nextInt(5) + 1).toString(),
        // 'age': random.nextInt(50) + 15,age
        //que la edad sea entre 10 y 20 años
        'age': random.nextInt(11) + 10,
        'pr8': (random.nextInt(5) + 1).toString(),
        'cadera': random.nextInt(41) + 80, // 80-120
        'ap_diapos': random.nextBool(),
        'pr13': (random.nextInt(5) + 1).toString(),
        'pr11': (random.nextInt(5) + 1).toString(),
        'num_dormitorios': (random.nextInt(4) + 1).toString(),
        'pr31': (random.nextInt(5) + 1).toString(),
        'ap_organigrama': random.nextBool(),
        'pr19': (random.nextInt(5) + 1).toString(),
        'num_autos': (random.nextInt(3) + 1).toString(),
        'peso': random.nextInt(51) + 50, // 50-100
        'estatura': (random.nextInt(41) + 150) / 100, // 1.50-1.90
        'pr34': (random.nextInt(5) + 1).toString(),
        'nombre_escuela': escuelas[random.nextInt(escuelas.length)],
        'pr32': (random.nextInt(5) + 1).toString(),
        'pr5': (random.nextInt(5) + 1).toString(),
        'pr12': (random.nextInt(5) + 1).toString(),
        'pr29': (random.nextInt(5) + 1).toString(),
        'pr22': (random.nextInt(5) + 1).toString(),
        'ap_proyectos': random.nextBool(),
        'municipio': municipios[random.nextInt(municipios.length)],
        'pr46': (random.nextInt(5) + 1).toString(),
        'pr50': (random.nextInt(5) + 1).toString(),
        'grado': '${random.nextInt(9) + 1}°',
        'pr1': (random.nextInt(5) + 1).toString(),
        'sistolica': random.nextInt(41) + 80, // 80-120
        'ap_videos': random.nextBool(),
        'enfermedades': random.nextBool() ? 'No' : 'Si',
        'pr6': (random.nextInt(5) + 1).toString(),
        'ap_mesaRedonda': random.nextBool(),
        'pr51': (random.nextInt(5) + 1).toString(),
        'pr17': (random.nextInt(5) + 1).toString(),
        'horario': 'String',
        'pr41': (random.nextInt(5) + 1).toString(),
        'ap_conceptuales': random.nextBool(),
        'pr21': (random.nextInt(5) + 1).toString(),
        'pr44': (random.nextInt(5) + 1).toString(),
        'pr3': (random.nextInt(5) + 1).toString(),
        'baths': (random.nextInt(3) + 1).toString(),
        'pr43': (random.nextInt(5) + 1).toString(),
        'diastolica': random.nextInt(21) + 60, // 60-80
        'pr35': (random.nextInt(5) + 1).toString(),
        'nivel_educativo': 'Universidad',
        'pr48': (random.nextInt(5) + 1).toString(),
        'pr10': (random.nextInt(5) + 1).toString(),
        'pr36': (random.nextInt(5) + 1).toString(),
        'pr33': (random.nextInt(5) + 1).toString(),
        'pr15': (random.nextInt(5) + 1).toString(),
        'ap_mentales': random.nextBool(),
        'cintura': random.nextInt(41) + 60, // 60-100
        'pr40': (random.nextInt(5) + 1).toString(),
        'pr16': (random.nextInt(5) + 1).toString(),
        'dad_work': random.nextBool() ? 'Si' : 'No',
        'pr26': (random.nextInt(5) + 1).toString(),
      };

      await FirebaseFirestore.instance.collection('users').add(userData);
      Get.snackbar('Éxito', 'Usuario de prueba generado',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo generar el usuario de prueba',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
