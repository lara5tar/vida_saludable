import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:vida_saludable/app/modules/home/views/dashboard_widget.dart';

import '../../../widgets/custom_scaffold.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(40.0),
          child: ListView(
            children: [
              dashboardWidget(
                  controller.totalPersonas(), controller.getTotalesPorGenero()),
              for (int index = 0; index < controller.users.length; index++)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.users[index]['name']),
                      Text(controller.getIMC(controller.users[index])),
                      Text(controller.getIndiceCircunferenciaCintura(
                          controller.users[index])),
                      Text(controller.getIndiceCircunferenciaCadera(
                          controller.users[index])),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
