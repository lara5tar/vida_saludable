import 'package:get/get.dart';
import '../controllers/estadisticas_controller.dart';

class EstadisticasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EstadisticasController>(
      () => EstadisticasController(),
    );
  }
}
