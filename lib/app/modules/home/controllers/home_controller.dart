import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/data/services/calculadora_imc_service.dart';

class HomeController extends GetxController {
  @override
  void onInit() {
    getUsers();
    super.onInit();
  }

  var users = <Map<String, dynamic>>[].obs;

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      var result = await FirebaseFirestore.instance.collection('users').get();
      users.value = result.docs.map((doc) => doc.data()).toList();
      return users;
    } catch (e) {
      return [];
    }
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
}
