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
            isMobile: isMobile,
          ),
          CustomButton(
            icon: Icons.search,
            text: 'Buscar',
            onPressed: () => Get.toNamed('/search'),
            backgroundColor: isCurrentRoute('/search'),
            isMobile: isMobile,
          ),
        ],
      );
    }

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              backgroundColor: Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
            )
          : null,
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.grey.shade200,
              leading: Container(),
              leadingWidth: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.menu),
                        color: Colors.white,
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),
                  logo(),
                ],
              ),
              toolbarHeight: 100,
            )
          : null,
      body: isMobile
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: body ?? Container(),
            )
          : Row(
              children: [
                Container(
                  color: Colors.grey.shade200,
                  width: 200,
                  child: Column(
                    children: [
                      logo(),
                      buildNavigationButtons(),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: body ?? Container(),
                  ),
                ),
              ],
            ),
    );
  }

  Padding logo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
        child: Image.asset(
          'assets/logo.webp',
          height: 80,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
