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

  getUsers() async {
    var result = await FirebaseFirestore.instance.collection('users').get();

    for (var doc in result.docs) {
      users.add(doc.data());
    }

    return users;
  }

  String getIMC(user) {
    var peso = user['peso'];
    var estatura = user['estatura'];
    var imc = peso / (estatura * estatura);

    return CalculadoraIMC.calcular(
        imc, user['age'], user['gender'].toLowerCase());
  }

  String getIndiceCircunferenciaCintura(user) {
    var cintura = user['cintura'];
    var estatura = user['estatura'];
    var icc = cintura / estatura;

    return '';
  }
}
