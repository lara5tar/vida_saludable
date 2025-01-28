import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeView'),
        centerTitle: true,
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(controller.users[index]['name']),
              subtitle: Text(
                  '${controller.getIMC(controller.users[index])} ${controller.getIndiceCircunferenciaCintura(controller.users[index])}'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
