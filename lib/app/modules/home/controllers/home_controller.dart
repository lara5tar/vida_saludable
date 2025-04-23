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
}
