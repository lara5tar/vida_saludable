import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../data/services/calculadora_imc_service.dart';
import '../../../data/services/presion_arterial_service.dart';

class UserController extends GetxController {
  var user = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final userId = Get.parameters['id'];
    if (userId != null && userId.isNotEmpty) {
      getUser(userId);
    } else {
      // isLoading.value = false;
    }
  }

  Future<void> getUser(String userId) async {
    try {
      // isLoading.value = true;
      // user.clear();

      var result = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (result.exists) {
        user.value = Map<String, dynamic>.from(result.data() ?? {});
        user['id'] = userId;
      }
    } catch (e) {
      print('Error getting user data: $e');
      user.clear();
    } finally {
      // isLoading.value = false;
    }
  }

  String getIMC(Map<String, dynamic> userData) {
    final peso = double.tryParse(userData['peso'].toString());
    final estatura = double.tryParse(userData['estatura'].toString());

    if (peso == null || estatura == null || estatura == 0) {
      return 'Datos inválidos';
    }

    final imc = peso / (estatura * estatura);
    return CalculadoraIMC.calcular(
      imc,
      userData['age'],
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

    return '$ratio - ${icc >= 0.50 ? 'Incrementa riesgos cardio-metabólicos' : 'Saludable'}';
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
      return '$ratio - ${icc <= 0.90 ? 'Saludable' : 'Con riesgos cardio-metabólicos'}';
    } else if (gender == 'femenino' || gender == 'mujer') {
      return '$ratio - ${icc <= 0.85 ? 'Saludable' : 'Con riesgos cardio-metabólicos'}';
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
}
