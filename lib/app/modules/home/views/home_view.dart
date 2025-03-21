import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/modules/home/views/dashboard_widget.dart';
import 'package:vida_saludable/app/modules/home/views/gender_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/age_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/city_chart_widget.dart';
import 'package:vida_saludable/app/modules/home/views/education_chart_widget.dart';
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
                const SizedBox(height: 40),
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
              ],
            );
          }
        },
      ),
    );
  }
}
