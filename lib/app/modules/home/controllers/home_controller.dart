import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/data/services/calculadora_imc_service.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var users = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    getUsers();
    super.onInit();
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      var result = await FirebaseFirestore.instance.collection('users').get();
      users.value = result.docs.map((doc) => doc.data()).toList();
      isLoading.value = false;
      return users;
    } catch (e) {
      isLoading.value = false;
      return [];
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
}
