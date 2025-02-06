import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/widgets/custom_button.dart';

class CustomScaffold extends StatelessWidget {
  final Widget? body;

  const CustomScaffold({
    super.key,
    this.body,
  });

  Color isCurrentRoute(String route) {
    return Get.currentRoute == route
        ? Colors.green.shade900
        : Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.width < 600;

    Widget buildNavigationButtons() {
      return Column(
        children: [
          CustomButton(
            icon: Icons.home,
            text: 'Inicio',
            onPressed: () => Get.toNamed('/home'),
            backgroundColor: isCurrentRoute('/home'),
          ),
          CustomButton(
            icon: Icons.search,
            text: 'Buscar',
            onPressed: () => Get.toNamed('/search'),
            backgroundColor: isCurrentRoute('/search'),
          ),
        ],
      );
    }

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: Container(
                color: Colors.grey.shade200,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Center(
                        child: Image.asset(
                          'assets/logo.webp',
                          width: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    buildNavigationButtons(),
                  ],
                ),
              ),
            )
          : null,
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.grey.shade200,
              iconTheme: IconThemeData(color: Colors.grey.shade800),
            )
          : null,
      body: isMobile
          ? body ?? Container()
          : Row(
              children: [
                Container(
                  color: Colors.grey.shade200,
                  width: 200,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Center(
                          child: Image.asset(
                            'assets/logo.webp',
                            width: 150,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      buildNavigationButtons(),
                    ],
                  ),
                ),
                Expanded(
                  child: body ?? Container(),
                ),
              ],
            ),
    );
  }
}
