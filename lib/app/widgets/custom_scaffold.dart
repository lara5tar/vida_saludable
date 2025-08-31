import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/data/services/auth_service.dart';
import 'package:vida_saludable/app/routes/app_pages.dart';
import 'package:vida_saludable/app/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomScaffold extends StatelessWidget {
  final Widget? body;
  final AuthService _authService = Get.find<AuthService>();

  // Variables reactivas para almacenar información del superuser
  final RxMap<String, dynamic> superUserData = RxMap<String, dynamic>({});
  final RxBool isLoadingSuperUser = RxBool(false);

  CustomScaffold({
    super.key,
    this.body,
  }) {
    // Cargar datos del superuser al crear el widget
    _loadSuperUserData();
  }

  // Método para cargar datos del superuser desde Firestore
  Future<void> _loadSuperUserData() async {
    if (_authService.user.value == null) return;

    try {
      isLoadingSuperUser.value = true;

      // Obtener el documento del superuser desde Firestore
      final docRef = FirebaseFirestore.instance
          .collection('superUsers')
          .doc(_authService.user.value!.uid);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        // Actualizar el mapa reactivo con los datos del superuser
        superUserData.assignAll(docSnapshot.data()!);
        superUserData['email'] = _authService.user.value!.email;
      }
    } catch (e) {
      print('Error al cargar datos del superuser: $e');
    } finally {
      isLoadingSuperUser.value = false;
    }
  }

  Color isCurrentRoute(String route) {
    return Get.currentRoute == route
        ? Colors.green.shade900
        : Colors.green.shade700;
  }

  // Widget para mostrar una fila de información del superuser
  Widget buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.green.shade700,
          size: 16,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = context.width < 600;

    // Widget para mostrar información básica del superuser
    Widget buildSuperUserInfoCard() {
      return Obx(() {
        if (isLoadingSuperUser.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        if (superUserData.isEmpty || !_authService.isInitialized.value) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _authService.isAdmin.value
                        ? Colors.amber.shade100
                        : Colors.green.shade100,
                    radius: 25,
                    child: Icon(
                      _authService.isAdmin.value
                          ? Icons.admin_panel_settings
                          : Icons.person,
                      color: _authService.isAdmin.value
                          ? Colors.amber.shade700
                          : Colors.green.shade700,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          superUserData['name']?.toString() ?? 'Usuario',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        Text(
                          _authService.isAdmin.value
                              ? 'Administrador'
                              : 'Usuario Regular',
                          style: TextStyle(
                            color: _authService.isAdmin.value
                                ? Colors.amber.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.email,
                    color: Colors.green.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Email: ${superUserData['email']?.toString() ?? 'No disponible'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
              if (_authService.assignedSchoolId.value.isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.school,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Escuela asignada: ${_authService.assignedSchoolId.value}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              if (superUserData['createdAt'] != null)
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Cuenta creada: ${_formatTimestamp(superUserData['createdAt'])}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        );
      });
    }

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
              return Column(
                children: [
                  CustomButton(
                    icon: Icons.admin_panel_settings,
                    text: 'Administrar Usuarios',
                    onPressed: () => Get.toNamed(Routes.ADMIN),
                    backgroundColor: isCurrentRoute(Routes.ADMIN),
                    isMobile: isMobile,
                  ),
                  // CustomButton(
                  //   icon: Icons.bar_chart,
                  //   text: 'Estadísticas de Riesgos',
                  //   onPressed: () => Get.toNamed(Routes.ESTADISTICAS),
                  //   backgroundColor: isCurrentRoute(Routes.ESTADISTICAS),
                  //   isMobile: isMobile,
                  // ),
                ],
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
                  // Mover tarjeta de información del superuser al final
                  Expanded(child: Container()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: buildSuperUserInfoCard(),
                  ),
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
                      // Mover tarjeta de información del superuser al final
                      Expanded(child: Container()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: buildSuperUserInfoCard(),
                      ),
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

  // Formatear timestamp para mostrar fecha
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final DateTime dateTime = timestamp.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    return 'Fecha desconocida';
  }

  Padding logo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
        child: Image.asset(
          'assets/logo.jpeg',
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
