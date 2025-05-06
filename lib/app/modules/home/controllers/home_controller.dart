import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/data/services/auth_service.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var users = <Map<String, dynamic>>[].obs;
  final authService = Get.find<AuthService>();

  @override
  void onInit() {
    getUsers();
    super.onInit();
  }

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
        // Verificar si los datos de escuela están en nombre_escuela o sec_TamMad
        // Primero intentamos filtrar por sec_TamMad
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
        data['id'] = doc.id; // Añadir ID del documento a los datos
        return data;
      }).toList();

      return users;
    } catch (e) {
      print('❌ Error al obtener usuarios: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
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

  Map<String, int> getEstadisticasRiesgoCardiometabolico() {
    // Inicializar mapa con contadores para con riesgo y sin riesgo
    final estadisticas = {
      'conRiesgo': 0,
      'sinRiesgo': 0,
    };

    // Iterar sobre los usuarios para determinar riesgos cardiometabólicos
    for (var user in users) {
      bool tieneRiesgo = false;

      // Calcular IMC a partir de peso y estatura
      final peso = user['peso'] is num
          ? user['peso'] as num
          : user['peso'] is String
              ? double.tryParse(user['peso']?.toString() ?? '')
              : null;

      final estatura = user['estatura'] is num
          ? user['estatura'] as num
          : user['estatura'] is String
              ? double.tryParse(user['estatura']?.toString() ?? '')
              : null;

      // Calcular IMC solo si tenemos ambos valores
      if (peso != null && estatura != null && estatura > 0) {
        // IMC elevado (>= 25 para sobrepeso, >= 30 para obesidad)
        final imc = peso / (estatura * estatura);
        if (imc >= 25) {
          tieneRiesgo = true;
        }
      }

      // Presión arterial alta (sistólica >= 130 o diastólica >= 85)
      final sistolica = user['sistolica'] is num
          ? user['sistolica'] as num
          : user['sistolica'] is String
              ? double.tryParse(user['sistolica']?.toString() ?? '')
              : null;
      final diastolica = user['diastolica'] is num
          ? user['diastolica'] as num
          : user['diastolica'] is String
              ? double.tryParse(user['diastolica']?.toString() ?? '')
              : null;

      if ((sistolica != null && sistolica >= 130) ||
          (diastolica != null && diastolica >= 85)) {
        tieneRiesgo = true;
      }

      // Glucosa en ayunas elevada (>= 100 mg/dL)
      final glucosa = user['glucosa'] is num
          ? user['glucosa'] as num
          : user['glucosa'] is String
              ? double.tryParse(user['glucosa']?.toString() ?? '')
              : null;
      if (glucosa != null && glucosa >= 100) {
        tieneRiesgo = true;
      }

      // Perímetro de cintura elevado (>= 102 cm para hombres, >= 88 cm para mujeres)
      final perimetroCintura = user['cintura'] is num
          ? user['cintura'] as num
          : user['cintura'] is String
              ? double.tryParse(user['cintura']?.toString() ?? '')
              : null;
      final gender = user['gender']?.toString().toLowerCase() ?? '';

      if (perimetroCintura != null) {
        if ((gender == 'masculino' || gender == 'hombre') &&
            perimetroCintura >= 102) {
          tieneRiesgo = true;
        } else if ((gender == 'femenino' || gender == 'mujer') &&
            perimetroCintura >= 88) {
          tieneRiesgo = true;
        }
      }

      // Campo específico de riesgo cardiometabólico si existe
      final riesgoExplicito = user['riesgo_cardiometabolico'];
      if (riesgoExplicito != null &&
          (riesgoExplicito == true ||
              riesgoExplicito.toString().toLowerCase() == 'true')) {
        tieneRiesgo = true;
      }

      // Incrementar el contador correspondiente
      if (tieneRiesgo) {
        estadisticas['conRiesgo'] = estadisticas['conRiesgo']! + 1;
      } else {
        estadisticas['sinRiesgo'] = estadisticas['sinRiesgo']! + 1;
      }
    }

    return estadisticas;
  }

  Map<String, Map<String, int>>
      getEstadisticasRiesgoCardiometabolicoPorGrupo() {
    // Mapa para almacenar las estadísticas por grupo
    final estadisticasPorGrupo = <String, Map<String, int>>{};

    // Iterar sobre los usuarios
    for (var user in users) {
      // Obtener el grupo del usuario (o asignar 'Sin grupo' si no tiene)
      final grupo = user['grupo']?.toString() ?? 'Sin grupo';

      // Inicializar contadores si no existen para este grupo
      if (!estadisticasPorGrupo.containsKey(grupo)) {
        estadisticasPorGrupo[grupo] = {
          'conRiesgo': 0,
          'sinRiesgo': 0,
        };
      }

      // Verificar si el usuario tiene riesgo cardiometabólico
      bool tieneRiesgo = false;

      // Calcular IMC a partir de peso y estatura
      final peso = user['peso'] is num
          ? user['peso'] as num
          : user['peso'] is String
              ? double.tryParse(user['peso']?.toString() ?? '')
              : null;

      final estatura = user['estatura'] is num
          ? user['estatura'] as num
          : user['estatura'] is String
              ? double.tryParse(user['estatura']?.toString() ?? '')
              : null;

      // Calcular IMC solo si tenemos ambos valores
      if (peso != null && estatura != null && estatura > 0) {
        // IMC elevado (>= 25 para sobrepeso, >= 30 para obesidad)
        final imc = peso / (estatura * estatura);
        if (imc >= 25) {
          tieneRiesgo = true;
        }
      }

      // Presión arterial alta (sistólica >= 130 o diastólica >= 85)
      final sistolica = user['sistolica'] is num
          ? user['sistolica'] as num
          : user['sistolica'] is String
              ? double.tryParse(user['sistolica']?.toString() ?? '')
              : null;
      final diastolica = user['diastolica'] is num
          ? user['diastolica'] as num
          : user['diastolica'] is String
              ? double.tryParse(user['diastolica']?.toString() ?? '')
              : null;

      if ((sistolica != null && sistolica >= 130) ||
          (diastolica != null && diastolica >= 85)) {
        tieneRiesgo = true;
      }

      // Glucosa en ayunas elevada (>= 100 mg/dL)
      final glucosa = user['glucosa'] is num
          ? user['glucosa'] as num
          : user['glucosa'] is String
              ? double.tryParse(user['glucosa']?.toString() ?? '')
              : null;
      if (glucosa != null && glucosa >= 100) {
        tieneRiesgo = true;
      }

      // Perímetro de cintura elevado (>= 102 cm para hombres, >= 88 cm para mujeres)
      final perimetroCintura = user['cintura'] is num
          ? user['cintura'] as num
          : user['cintura'] is String
              ? double.tryParse(user['cintura']?.toString() ?? '')
              : null;
      final gender = user['gender']?.toString().toLowerCase() ?? '';

      if (perimetroCintura != null) {
        if ((gender == 'masculino' || gender == 'hombre') &&
            perimetroCintura >= 102) {
          tieneRiesgo = true;
        } else if ((gender == 'femenino' || gender == 'mujer') &&
            perimetroCintura >= 88) {
          tieneRiesgo = true;
        }
      }

      // Campo específico de riesgo cardiometabólico si existe
      final riesgoExplicito = user['riesgo_cardiometabolico'];
      if (riesgoExplicito != null &&
          (riesgoExplicito == true ||
              riesgoExplicito.toString().toLowerCase() == 'true')) {
        tieneRiesgo = true;
      }

      // Incrementar el contador correspondiente para este grupo
      if (tieneRiesgo) {
        estadisticasPorGrupo[grupo]!['conRiesgo'] =
            estadisticasPorGrupo[grupo]!['conRiesgo']! + 1;
      } else {
        estadisticasPorGrupo[grupo]!['sinRiesgo'] =
            estadisticasPorGrupo[grupo]!['sinRiesgo']! + 1;
      }
    }

    return estadisticasPorGrupo;
  }

  Map<String, Map<String, int>>
      getEstadisticasRiesgoCardiometabolicoPorGrado() {
    // Mapa para almacenar las estadísticas por grado (solo 1°, 2° y 3°)
    final estadisticasPorGrado = <String, Map<String, int>>{
      '1': {'conRiesgo': 0, 'sinRiesgo': 0},
      '2': {'conRiesgo': 0, 'sinRiesgo': 0},
      '3': {'conRiesgo': 0, 'sinRiesgo': 0},
    };

    // Iterar sobre los usuarios
    for (var user in users) {
      // Obtener el grado del usuario
      String? grado = user['grado']?.toString();

      // Solo procesar si el grado es 1, 2 o 3
      if (grado == null || !['1', '2', '3'].contains(grado)) {
        continue;
      }

      // Verificar si el usuario tiene riesgo cardiometabólico
      bool tieneRiesgo = false;

      // Calcular IMC a partir de peso y estatura
      final peso = user['peso'] is num
          ? user['peso'] as num
          : user['peso'] is String
              ? double.tryParse(user['peso']?.toString() ?? '')
              : null;

      final estatura = user['estatura'] is num
          ? user['estatura'] as num
          : user['estatura'] is String
              ? double.tryParse(user['estatura']?.toString() ?? '')
              : null;

      // Calcular IMC solo si tenemos ambos valores
      if (peso != null && estatura != null && estatura > 0) {
        // IMC elevado (>= 25 para sobrepeso, >= 30 para obesidad)
        final imc = peso / (estatura * estatura);
        if (imc >= 25) {
          tieneRiesgo = true;
        }
      }

      // Presión arterial alta (sistólica >= 130 o diastólica >= 85)
      final sistolica = user['sistolica'] is num
          ? user['sistolica'] as num
          : user['sistolica'] is String
              ? double.tryParse(user['sistolica']?.toString() ?? '')
              : null;
      final diastolica = user['diastolica'] is num
          ? user['diastolica'] as num
          : user['diastolica'] is String
              ? double.tryParse(user['diastolica']?.toString() ?? '')
              : null;

      if ((sistolica != null && sistolica >= 130) ||
          (diastolica != null && diastolica >= 85)) {
        tieneRiesgo = true;
      }

      // Glucosa en ayunas elevada (>= 100 mg/dL)
      final glucosa = user['glucosa'] is num
          ? user['glucosa'] as num
          : user['glucosa'] is String
              ? double.tryParse(user['glucosa']?.toString() ?? '')
              : null;
      if (glucosa != null && glucosa >= 100) {
        tieneRiesgo = true;
      }

      // Perímetro de cintura elevado (>= 102 cm para hombres, >= 88 cm para mujeres)
      final perimetroCintura = user['cintura'] is num
          ? user['cintura'] as num
          : user['cintura'] is String
              ? double.tryParse(user['cintura']?.toString() ?? '')
              : null;
      final gender = user['gender']?.toString().toLowerCase() ?? '';

      if (perimetroCintura != null) {
        if ((gender == 'masculino' || gender == 'hombre') &&
            perimetroCintura >= 102) {
          tieneRiesgo = true;
        } else if ((gender == 'femenino' || gender == 'mujer') &&
            perimetroCintura >= 88) {
          tieneRiesgo = true;
        }
      }

      // Campo específico de riesgo cardiometabólico si existe
      final riesgoExplicito = user['riesgo_cardiometabolico'];
      if (riesgoExplicito != null &&
          (riesgoExplicito == true ||
              riesgoExplicito.toString().toLowerCase() == 'true')) {
        tieneRiesgo = true;
      }

      // Incrementar el contador correspondiente para este grado
      if (tieneRiesgo) {
        estadisticasPorGrado[grado]!['conRiesgo'] =
            estadisticasPorGrado[grado]!['conRiesgo']! + 1;
      } else {
        estadisticasPorGrado[grado]!['sinRiesgo'] =
            estadisticasPorGrado[grado]!['sinRiesgo']! + 1;
      }
    }

    return estadisticasPorGrado;
  }

  Map<String, Map<String, int>> getEstadisticasRiesgoCardiometabolicoPorSexo() {
    // Mapa para almacenar las estadísticas por sexo
    final estadisticasPorSexo = <String, Map<String, int>>{
      'masculino': {'conRiesgo': 0, 'sinRiesgo': 0},
      'femenino': {'conRiesgo': 0, 'sinRiesgo': 0},
    };

    // Iterar sobre los usuarios
    for (var user in users) {
      // Obtener el género del usuario (normalizado)
      String genero = 'no_especificado';
      final gender = user['gender']?.toString().toLowerCase() ?? '';

      // Normalizar el género a 'masculino' o 'femenino'
      if (gender == 'masculino' ||
          gender == 'hombre' ||
          gender == 'm' ||
          gender == 'male') {
        genero = 'masculino';
      } else if (gender == 'femenino' ||
          gender == 'mujer' ||
          gender == 'f' ||
          gender == 'female') {
        genero = 'femenino';
      } else {
        // Si no se especifica el género, continuamos al siguiente usuario
        continue;
      }

      // Verificar si el usuario tiene riesgo cardiometabólico
      bool tieneRiesgo = false;

      // Calcular IMC a partir de peso y estatura
      final peso = user['peso'] is num
          ? user['peso'] as num
          : user['peso'] is String
              ? double.tryParse(user['peso']?.toString() ?? '')
              : null;

      final estatura = user['estatura'] is num
          ? user['estatura'] as num
          : user['estatura'] is String
              ? double.tryParse(user['estatura']?.toString() ?? '')
              : null;

      // Calcular IMC solo si tenemos ambos valores
      if (peso != null && estatura != null && estatura > 0) {
        // IMC elevado (>= 25 para sobrepeso, >= 30 para obesidad)
        final imc = peso / (estatura * estatura);
        if (imc >= 25) {
          tieneRiesgo = true;
        }
      }

      // Presión arterial alta (sistólica >= 130 o diastólica >= 85)
      final sistolica = user['sistolica'] is num
          ? user['sistolica'] as num
          : user['sistolica'] is String
              ? double.tryParse(user['sistolica']?.toString() ?? '')
              : null;
      final diastolica = user['diastolica'] is num
          ? user['diastolica'] as num
          : user['diastolica'] is String
              ? double.tryParse(user['diastolica']?.toString() ?? '')
              : null;

      if ((sistolica != null && sistolica >= 130) ||
          (diastolica != null && diastolica >= 85)) {
        tieneRiesgo = true;
      }

      // Glucosa en ayunas elevada (>= 100 mg/dL)
      final glucosa = user['glucosa'] is num
          ? user['glucosa'] as num
          : user['glucosa'] is String
              ? double.tryParse(user['glucosa']?.toString() ?? '')
              : null;
      if (glucosa != null && glucosa >= 100) {
        tieneRiesgo = true;
      }

      // Perímetro de cintura elevado (>= 102 cm para hombres, >= 88 cm para mujeres)
      final perimetroCintura = user['cintura'] is num
          ? user['cintura'] as num
          : user['cintura'] is String
              ? double.tryParse(user['cintura']?.toString() ?? '')
              : null;

      if (perimetroCintura != null) {
        if (genero == 'masculino' && perimetroCintura >= 102) {
          tieneRiesgo = true;
        } else if (genero == 'femenino' && perimetroCintura >= 88) {
          tieneRiesgo = true;
        }
      }

      // Campo específico de riesgo cardiometabólico si existe
      final riesgoExplicito = user['riesgo_cardiometabolico'];
      if (riesgoExplicito != null &&
          (riesgoExplicito == true ||
              riesgoExplicito.toString().toLowerCase() == 'true')) {
        tieneRiesgo = true;
      }

      // Incrementar el contador correspondiente para este género
      if (tieneRiesgo) {
        estadisticasPorSexo[genero]!['conRiesgo'] =
            estadisticasPorSexo[genero]!['conRiesgo']! + 1;
      } else {
        estadisticasPorSexo[genero]!['sinRiesgo'] =
            estadisticasPorSexo[genero]!['sinRiesgo']! + 1;
      }
    }

    return estadisticasPorSexo;
  }

  Map<String, int> getEstadisticasEstadoNutricional() {
    // Mapa para almacenar las estadísticas de estado nutricional basado en IMC
    final estadisticas = {
      'bajoPeso': 0, // IMC < 18.5
      'normal': 0, // IMC >= 18.5 y < 25
      'sobrepeso': 0, // IMC >= 25 y < 30
      'obesidad': 0, // IMC >= 30
      'sinDatos': 0, // No hay datos suficientes para calcular IMC
    };

    // Iterar sobre los usuarios
    for (var user in users) {
      // Obtener peso y estatura del usuario
      final peso = user['peso'] is num
          ? user['peso'] as num
          : user['peso'] is String
              ? double.tryParse(user['peso']?.toString() ?? '')
              : null;

      final estatura = user['estatura'] is num
          ? user['estatura'] as num
          : user['estatura'] is String
              ? double.tryParse(user['estatura']?.toString() ?? '')
              : null;

      // Calcular IMC solo si tenemos ambos valores
      if (peso != null && estatura != null && estatura > 0) {
        // Fórmula del IMC: peso (kg) / (estatura (m))²
        final imc = peso / (estatura * estatura);

        if (imc < 18.5) {
          estadisticas['bajoPeso'] = estadisticas['bajoPeso']! + 1;
        } else if (imc < 25) {
          estadisticas['normal'] = estadisticas['normal']! + 1;
        } else if (imc < 30) {
          estadisticas['sobrepeso'] = estadisticas['sobrepeso']! + 1;
        } else {
          estadisticas['obesidad'] = estadisticas['obesidad']! + 1;
        }
      } else {
        // No tenemos suficiente información para calcular el IMC
        estadisticas['sinDatos'] = estadisticas['sinDatos']! + 1;
      }
    }

    return estadisticas;
  }

  Map<String, Map<String, int>> getEstadisticasEstadoNutricionalPorSexo() {
    // Mapa para almacenar las estadísticas de estado nutricional por sexo
    final estadisticasPorSexo = <String, Map<String, int>>{
      'masculino': {
        'bajoPeso': 0,
        'normal': 0,
        'sobrepeso': 0,
        'obesidad': 0,
        'sinDatos': 0,
      },
      'femenino': {
        'bajoPeso': 0,
        'normal': 0,
        'sobrepeso': 0,
        'obesidad': 0,
        'sinDatos': 0,
      },
    };

    // Iterar sobre los usuarios
    for (var user in users) {
      // Obtener el género del usuario (normalizado)
      String genero = 'no_especificado';
      final gender = user['gender']?.toString().toLowerCase() ?? '';

      // Normalizar el género a 'masculino' o 'femenino'
      if (gender == 'masculino' ||
          gender == 'hombre' ||
          gender == 'm' ||
          gender == 'male') {
        genero = 'masculino';
      } else if (gender == 'femenino' ||
          gender == 'mujer' ||
          gender == 'f' ||
          gender == 'female') {
        genero = 'femenino';
      } else {
        // Si no se especifica el género, continuamos al siguiente usuario
        continue;
      }

      // Obtener peso y estatura del usuario
      final peso = user['peso'] is num
          ? user['peso'] as num
          : user['peso'] is String
              ? double.tryParse(user['peso']?.toString() ?? '')
              : null;

      final estatura = user['estatura'] is num
          ? user['estatura'] as num
          : user['estatura'] is String
              ? double.tryParse(user['estatura']?.toString() ?? '')
              : null;

      // Calcular IMC solo si tenemos ambos valores
      if (peso != null && estatura != null && estatura > 0) {
        // Fórmula del IMC: peso (kg) / (estatura (m))²
        final imc = peso / (estatura * estatura);

        if (imc < 18.5) {
          estadisticasPorSexo[genero]!['bajoPeso'] =
              estadisticasPorSexo[genero]!['bajoPeso']! + 1;
        } else if (imc < 25) {
          estadisticasPorSexo[genero]!['normal'] =
              estadisticasPorSexo[genero]!['normal']! + 1;
        } else if (imc < 30) {
          estadisticasPorSexo[genero]!['sobrepeso'] =
              estadisticasPorSexo[genero]!['sobrepeso']! + 1;
        } else {
          estadisticasPorSexo[genero]!['obesidad'] =
              estadisticasPorSexo[genero]!['obesidad']! + 1;
        }
      } else {
        // No tenemos suficiente información para calcular el IMC
        estadisticasPorSexo[genero]!['sinDatos'] =
            estadisticasPorSexo[genero]!['sinDatos']! + 1;
      }
    }

    return estadisticasPorSexo;
  }

  Map<String, Map<String, int>> getEstadisticasEstadoNutricionalPorGrado() {
    // Mapa para almacenar las estadísticas por grado (solo 1°, 2° y 3°)
    final estadisticasPorGrado = <String, Map<String, int>>{
      '1': {
        'bajoPeso': 0,
        'normal': 0,
        'sobrepeso': 0,
        'obesidad': 0,
        'sinDatos': 0,
      },
      '2': {
        'bajoPeso': 0,
        'normal': 0,
        'sobrepeso': 0,
        'obesidad': 0,
        'sinDatos': 0,
      },
      '3': {
        'bajoPeso': 0,
        'normal': 0,
        'sobrepeso': 0,
        'obesidad': 0,
        'sinDatos': 0,
      },
    };

    // Iterar sobre los usuarios
    for (var user in users) {
      // Obtener el grado del usuario
      String? grado = user['grado']?.toString();

      // Solo procesar si el grado es 1, 2 o 3
      if (grado == null || !['1', '2', '3'].contains(grado)) {
        continue;
      }

      // Obtener peso y estatura del usuario
      final peso = user['peso'] is num
          ? user['peso'] as num
          : user['peso'] is String
              ? double.tryParse(user['peso']?.toString() ?? '')
              : null;

      final estatura = user['estatura'] is num
          ? user['estatura'] as num
          : user['estatura'] is String
              ? double.tryParse(user['estatura']?.toString() ?? '')
              : null;

      // Calcular IMC solo si tenemos ambos valores
      if (peso != null && estatura != null && estatura > 0) {
        // Fórmula del IMC: peso (kg) / (estatura (m))²
        final imc = peso / (estatura * estatura);

        if (imc < 18.5) {
          estadisticasPorGrado[grado]!['bajoPeso'] =
              estadisticasPorGrado[grado]!['bajoPeso']! + 1;
        } else if (imc < 25) {
          estadisticasPorGrado[grado]!['normal'] =
              estadisticasPorGrado[grado]!['normal']! + 1;
        } else if (imc < 30) {
          estadisticasPorGrado[grado]!['sobrepeso'] =
              estadisticasPorGrado[grado]!['sobrepeso']! + 1;
        } else {
          estadisticasPorGrado[grado]!['obesidad'] =
              estadisticasPorGrado[grado]!['obesidad']! + 1;
        }
      } else {
        // No tenemos suficiente información para calcular el IMC
        estadisticasPorGrado[grado]!['sinDatos'] =
            estadisticasPorGrado[grado]!['sinDatos']! + 1;
      }
    }

    return estadisticasPorGrado;
  }

  Map<String, int> getEstadisticasEstiloVida() {
    // Mapa para almacenar las estadísticas de estilo de vida
    final estadisticas = {
      'saludable': 0, // >= 204 puntos
      'regular': 0, // >= 170 y < 204 puntos
      'malo': 0, // < 170 puntos
      'sinDatos': 0, // No hay suficientes datos para calcular
    };

    // Iterar sobre los usuarios
    for (var user in users) {
      int puntajeTotal = 0;
      bool datosCompletos = true;

      // Sumar todas las preguntas de pr1 a pr51
      for (int i = 1; i <= 51; i++) {
        String key = 'pr$i';
        if (user.containsKey(key) && user[key] != null) {
          int valor = int.tryParse(user[key].toString()) ?? 0;
          puntajeTotal += valor;
        } else {
          datosCompletos = false;
          break;
        }
      }

      // Clasificar según el puntaje total
      if (datosCompletos) {
        if (puntajeTotal >= 204) {
          estadisticas['saludable'] = estadisticas['saludable']! + 1;
        } else if (puntajeTotal >= 170) {
          estadisticas['regular'] = estadisticas['regular']! + 1;
        } else {
          estadisticas['malo'] = estadisticas['malo']! + 1;
        }
      } else {
        estadisticas['sinDatos'] = estadisticas['sinDatos']! + 1;
      }
    }

    return estadisticas;
  }

  Map<String, Map<String, int>> getEstadisticasEstiloVidaPorSexo() {
    // Mapa para almacenar las estadísticas de estilo de vida por sexo
    final estadisticasPorSexo = <String, Map<String, int>>{
      'masculino': {
        'saludable': 0, // >= 204 puntos
        'regular': 0, // >= 170 y < 204 puntos
        'malo': 0, // < 170 puntos
        'sinDatos': 0, // No hay suficientes datos para calcular
      },
      'femenino': {
        'saludable': 0, // >= 204 puntos
        'regular': 0, // >= 170 y < 204 puntos
        'malo': 0, // < 170 puntos
        'sinDatos': 0, // No hay suficientes datos para calcular
      },
    };

    // Iterar sobre los usuarios
    for (var user in users) {
      // Obtener el género del usuario (normalizado)
      String genero = 'no_especificado';
      final gender = user['gender']?.toString().toLowerCase() ?? '';

      // Normalizar el género a 'masculino' o 'femenino'
      if (gender == 'masculino' ||
          gender == 'hombre' ||
          gender == 'm' ||
          gender == 'male') {
        genero = 'masculino';
      } else if (gender == 'femenino' ||
          gender == 'mujer' ||
          gender == 'f' ||
          gender == 'female') {
        genero = 'femenino';
      } else {
        // Si no se especifica el género, continuamos al siguiente usuario
        continue;
      }

      int puntajeTotal = 0;
      bool datosCompletos = true;

      // Sumar todas las preguntas de pr1 a pr51
      for (int i = 1; i <= 51; i++) {
        String key = 'pr$i';
        if (user.containsKey(key) && user[key] != null) {
          int valor = int.tryParse(user[key].toString()) ?? 0;
          puntajeTotal += valor;
        } else {
          datosCompletos = false;
          break;
        }
      }

      // Clasificar según el puntaje total
      if (datosCompletos) {
        if (puntajeTotal >= 204) {
          estadisticasPorSexo[genero]!['saludable'] =
              estadisticasPorSexo[genero]!['saludable']! + 1;
        } else if (puntajeTotal >= 170) {
          estadisticasPorSexo[genero]!['regular'] =
              estadisticasPorSexo[genero]!['regular']! + 1;
        } else {
          estadisticasPorSexo[genero]!['malo'] =
              estadisticasPorSexo[genero]!['malo']! + 1;
        }
      } else {
        estadisticasPorSexo[genero]!['sinDatos'] =
            estadisticasPorSexo[genero]!['sinDatos']! + 1;
      }
    }

    return estadisticasPorSexo;
  }

  Map<String, Map<String, int>> getEstadisticasEstiloVidaPorGrado() {
    // Mapa para almacenar las estadísticas de estilo de vida por grado
    final estadisticasPorGrado = <String, Map<String, int>>{
      '1': {
        'saludable': 0, // >= 204 puntos
        'regular': 0, // >= 170 y < 204 puntos
        'malo': 0, // < 170 puntos
        'sinDatos': 0, // No hay suficientes datos para calcular
      },
      '2': {
        'saludable': 0, // >= 204 puntos
        'regular': 0, // >= 170 y < 204 puntos
        'malo': 0, // < 170 puntos
        'sinDatos': 0, // No hay suficientes datos para calcular
      },
      '3': {
        'saludable': 0, // >= 204 puntos
        'regular': 0, // >= 170 y < 204 puntos
        'malo': 0, // < 170 puntos
        'sinDatos': 0, // No hay suficientes datos para calcular
      },
    };

    // Iterar sobre los usuarios
    for (var user in users) {
      // Obtener el grado del usuario
      String? grado = user['grado']?.toString();

      // Solo procesar si el grado es 1, 2 o 3
      if (grado == null || !['1', '2', '3'].contains(grado)) {
        continue;
      }

      int puntajeTotal = 0;
      bool datosCompletos = true;

      // Sumar todas las preguntas de pr1 a pr51
      for (int i = 1; i <= 51; i++) {
        String key = 'pr$i';
        if (user.containsKey(key) && user[key] != null) {
          int valor = int.tryParse(user[key].toString()) ?? 0;
          puntajeTotal += valor;
        } else {
          datosCompletos = false;
          break;
        }
      }

      // Clasificar según el puntaje total
      if (datosCompletos) {
        if (puntajeTotal >= 204) {
          estadisticasPorGrado[grado]!['saludable'] =
              estadisticasPorGrado[grado]!['saludable']! + 1;
        } else if (puntajeTotal >= 170) {
          estadisticasPorGrado[grado]!['regular'] =
              estadisticasPorGrado[grado]!['regular']! + 1;
        } else {
          estadisticasPorGrado[grado]!['malo'] =
              estadisticasPorGrado[grado]!['malo']! + 1;
        }
      } else {
        estadisticasPorGrado[grado]!['sinDatos'] =
            estadisticasPorGrado[grado]!['sinDatos']! + 1;
      }
    }

    return estadisticasPorGrado;
  }
}
