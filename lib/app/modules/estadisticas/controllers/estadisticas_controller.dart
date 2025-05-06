import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EstadisticasController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variables reactivas para los datos de las gráficas
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> datosRiesgos =
      <Map<String, dynamic>>[].obs;

  // Datos procesados para las gráficas
  final Rx<Map<String, dynamic>> datosGenerales =
      Rx<Map<String, dynamic>>({'conRiesgo': 0, 'sinRiesgo': 0, 'total': 0});

  final RxList<Map<String, dynamic>> datosPorGrado =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> datosPorSexo =
      <Map<String, dynamic>>[].obs;

  // Colores para las gráficas
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  // Colores para PieChart
  final List<Color> coloresPie = [
    Colors.red, // Con riesgo
    Colors.green, // Sin riesgo
  ];

  // Colores para grados
  final List<Color> coloresGrado = [
    Colors.blue, // Primer grado
    Colors.orange, // Segundo grado
    Colors.purple, // Tercer grado
  ];

  // Colores para sexos
  final List<Color> coloresSexo = [
    Colors.blue, // Hombre
    Colors.pink, // Mujer
  ];

  @override
  void onInit() {
    super.onInit();
    cargarDatosRiesgos();
  }

  Future<void> cargarDatosRiesgos() async {
    isLoading.value = true;
    try {
      // Obtener datos de Firestore
      final QuerySnapshot snapshot =
          await _firestore.collection('estudiantes').get();

      // Procesar los documentos
      datosRiesgos.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Procesar datos para las gráficas
      procesarDatosGenerales();
      procesarDatosPorGrado();
      procesarDatosPorSexo();
    } catch (e) {
      print('Error al cargar datos de riesgos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Procesa datos para la gráfica general de riesgos
  void procesarDatosGenerales() {
    int conRiesgo = 0;
    int sinRiesgo = 0;

    for (var estudiante in datosRiesgos) {
      // Verifica si el estudiante tiene riesgo cardiometabólico
      bool tieneRiesgo = estudiante['tieneRiesgoCardiometabolico'] ?? false;
      if (tieneRiesgo) {
        conRiesgo++;
      } else {
        sinRiesgo++;
      }
    }

    datosGenerales.value = {
      'conRiesgo': conRiesgo,
      'sinRiesgo': sinRiesgo,
      'total': conRiesgo + sinRiesgo
    };
  }

  // Procesa datos agrupados por grado
  void procesarDatosPorGrado() {
    // Mapa para almacenar datos por grado
    Map<String, Map<String, int>> porGrado = {
      '1': {'conRiesgo': 0, 'sinRiesgo': 0},
      '2': {'conRiesgo': 0, 'sinRiesgo': 0},
      '3': {'conRiesgo': 0, 'sinRiesgo': 0},
    };

    for (var estudiante in datosRiesgos) {
      String grado = estudiante['grado'] ?? '';
      bool tieneRiesgo = estudiante['tieneRiesgoCardiometabolico'] ?? false;

      if (porGrado.containsKey(grado)) {
        if (tieneRiesgo) {
          porGrado[grado]!['conRiesgo'] =
              (porGrado[grado]!['conRiesgo'] ?? 0) + 1;
        } else {
          porGrado[grado]!['sinRiesgo'] =
              (porGrado[grado]!['sinRiesgo'] ?? 0) + 1;
        }
      }
    }

    // Convertir a lista de mapas para facilitar su uso en la vista
    datosPorGrado.value = porGrado.entries.map((entry) {
      return {
        'grado': entry.key,
        'conRiesgo': entry.value['conRiesgo'],
        'sinRiesgo': entry.value['sinRiesgo'],
        'total':
            (entry.value['conRiesgo'] ?? 0) + (entry.value['sinRiesgo'] ?? 0)
      };
    }).toList();
  }

  // Procesa datos agrupados por sexo
  void procesarDatosPorSexo() {
    Map<String, Map<String, int>> porSexo = {
      'Hombre': {'conRiesgo': 0, 'sinRiesgo': 0},
      'Mujer': {'conRiesgo': 0, 'sinRiesgo': 0},
    };

    for (var estudiante in datosRiesgos) {
      String sexo = estudiante['sexo'] ?? '';
      bool tieneRiesgo = estudiante['tieneRiesgoCardiometabolico'] ?? false;

      if (porSexo.containsKey(sexo)) {
        if (tieneRiesgo) {
          porSexo[sexo]!['conRiesgo'] = (porSexo[sexo]!['conRiesgo'] ?? 0) + 1;
        } else {
          porSexo[sexo]!['sinRiesgo'] = (porSexo[sexo]!['sinRiesgo'] ?? 0) + 1;
        }
      }
    }

    datosPorSexo.value = porSexo.entries.map((entry) {
      return {
        'sexo': entry.key,
        'conRiesgo': entry.value['conRiesgo'],
        'sinRiesgo': entry.value['sinRiesgo'],
        'total':
            (entry.value['conRiesgo'] ?? 0) + (entry.value['sinRiesgo'] ?? 0)
      };
    }).toList();
  }

  // Calcular porcentaje
  double calcularPorcentaje(int valor, int total) {
    if (total == 0) return 0;
    return (valor / total) * 100;
  }
}
