import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/data/services/auth_service.dart';
import 'package:vida_saludable/app/routes/app_pages.dart';
import 'package:vida_saludable/app/widgets/custom_button.dart';

class CustomScaffold extends StatelessWidget {
  final Widget? body;
  final AuthService _authService = Get.find<AuthService>();

  CustomScaffold({
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
            onPressed: () => Get.toNamed(Routes.HOME),
            backgroundColor: isCurrentRoute(Routes.HOME),
            isMobile: isMobile,
          ),
          CustomButton(
            icon: Icons.search,
            text: 'Buscar',
            onPressed: () => Get.toNamed(Routes.SEARCH),
            backgroundColor: isCurrentRoute(Routes.SEARCH),
            isMobile: isMobile,
          ),
          // Mostrar botón de administración solo si el usuario es administrador
          Obx(() {
            if (_authService.isAdmin.value) {
              return CustomButton(
                icon: Icons.admin_panel_settings,
                text: 'Administrar Usuarios',
                onPressed: () => Get.toNamed(Routes.ADMIN),
                backgroundColor: isCurrentRoute(Routes.ADMIN),
                isMobile: isMobile,
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          const SizedBox(height: 20),
          // Botón para cerrar sesión
          CustomButton(
            icon: Icons.logout,
            text: 'Cerrar Sesión',
            onPressed: () {
              _showLogoutDialog(context);
            },
            backgroundColor: Colors.grey.shade700,
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
                  width: 250,
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

  // Diálogo para confirmar cierre de sesión
  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _authService.logout();
              Get.offAllNamed(Routes.LOGIN);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
