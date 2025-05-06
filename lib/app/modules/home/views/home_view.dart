import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/modules/home/views/dashboard_widget.dart';
import 'package:vida_saludable/app/modules/home/views/gender_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/age_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/city_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/education_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/cardiometabolic_risk_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/grado_risk_barchart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/sexo_risk_barchart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/estado_nutricional_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/estado_nutricional_sexo_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/estado_nutricional_grado_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/estilo_vida_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/estilo_vida_sexo_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/estilo_vida_grado_chart_widget.dart';
import '../../../widgets/custom_scaffold.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.users.isEmpty) {
            return const Center(child: Text('Aun no hay datos'));
          } else {
            return ListView(
              children: [
                dashboardWidget(
                  controller.totalPersonas(),
                  controller.getTotalesPorGenero(),
                ),
                Wrap(
                  spacing: 40,
                  runSpacing: 40,
                  alignment: WrapAlignment.spaceAround,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    genderChartWidget(controller.getTotalesPorGenero()),
                    SizedBox(
                      width: 400,
                      child: educationChartWidget(controller.users),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ageChartWidget(controller.users),
                const SizedBox(height: 40),
                cityChartWidget(controller.users),
                const SizedBox(height: 40),
                //linea
                Container(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 40),
                // Gráfica de estilo de vida (general)
                estiloVidaChartWidget(controller.getEstadisticasEstiloVida()),
                const SizedBox(height: 40),
                // Gráfica de estilo de vida por sexo (nueva)
                estiloVidaSexoChartWidget(
                    controller.getEstadisticasEstiloVidaPorSexo()),
                const SizedBox(height: 40),
                // Gráfica de estilo de vida por grado (nueva)
                estiloVidaGradoChartWidget(
                    controller.getEstadisticasEstiloVidaPorGrado()),
                const SizedBox(height: 40),
                Container(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 40),
                // Gráfica de estado nutricional (general)
                estadoNutricionalChartWidget(
                    controller.getEstadisticasEstadoNutricional()),
                const SizedBox(height: 40),
                // Gráfica de estado nutricional por sexo
                estadoNutricionalSexoChartWidget(
                    controller.getEstadisticasEstadoNutricionalPorSexo()),
                const SizedBox(height: 40),
                // Gráfica de estado nutricional por grado
                estadoNutricionalGradoChartWidget(
                    controller.getEstadisticasEstadoNutricionalPorGrado()),
                const SizedBox(height: 40),
                Container(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 40),

                const SizedBox(height: 40),
                // Gráfica general de riesgo cardiometabólico
                cardiometabolicRiskChartWidget(
                    controller.getEstadisticasRiesgoCardiometabolico()),
                const SizedBox(height: 40),
                // Gráfica de barras de riesgo cardiometabólico por grado
                gradoRiskBarChartWidget(
                    controller.getEstadisticasRiesgoCardiometabolicoPorGrado()),
                const SizedBox(height: 40),
                // Gráfica de barras de riesgo cardiometabólico por sexo
                sexoRiskBarChartWidget(
                    controller.getEstadisticasRiesgoCardiometabolicoPorSexo()),
                const SizedBox(height: 40),
              ],
            );
          }
        },
      ),
    );
  }
}
