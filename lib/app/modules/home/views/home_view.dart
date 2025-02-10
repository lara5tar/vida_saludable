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
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(40.0),
                child: ListView(
                  children: [
                    dashboardWidget(
                      controller.totalPersonas(),
                      controller.getTotalesPorGenero(),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 40,
                      runSpacing: 40,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 400,
                          child: genderChartWidget(
                              controller.getTotalesPorGenero()),
                        ),
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
                ),
              ),
      ),
    );
  }
}
