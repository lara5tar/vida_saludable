import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:flutter/material.dart';

import '../../../data/services/calculadora_imc_service.dart';
import '../../../data/services/nivel_socioeconomico.dart';
import '../../../data/services/presion_arterial_service.dart';

class UserController extends GetxController {
  var user = <String, dynamic>{}.obs;
  Map<String, dynamic> userEditInfo = {};

  @override
  void onInit() {
    super.onInit();
    final userId = Get.parameters['id'];
    if (userId != null && userId.isNotEmpty) {
      getUser(userId);
      // userEditInfo = Map<String, dynamic>.from(user);
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

        userEditInfo.clear();
        userEditInfo = Map<String, dynamic>.from(user);
      }
    } catch (e) {
      print('Error getting user data: $e');
      user.clear();
    } finally {
      // isLoading.value = false;
    }
  }

  saveUser() async {
    print(userEditInfo);
    //pasa a int los valores de edad, peso, estatura, cintura, cadera, sistolica y diastolica
    userEditInfo['age'] = int.tryParse(userEditInfo['age'].toString()) ?? 0;
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

    try {
      // isLoading.value = true;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user['id'])
          .update(userEditInfo);

      user.value = Map<String, dynamic>.from(userEditInfo);

      Get.snackbar(
        'Datos actualizados',
        'Los datos del usuario han sido actualizados correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error saving user data: $e');
    } finally {
      // isLoading.value = false;
    }
  }

  updateField(String field, dynamic value) {
    userEditInfo[field] = value;
  }

  deleteUser() async {}

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
}
