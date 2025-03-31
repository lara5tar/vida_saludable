import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vida_saludable/app/data/services/auth_service.dart';
import 'package:vida_saludable/app/routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  final authService = Get.find<AuthService>();

  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Si el usuario no está autenticado y la ruta no es la de login, redirigir al login
    if (authService.user.value == null && route != Routes.LOGIN) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    // Si el usuario está autenticado y la ruta es la de login, redirigir al home
    if (authService.user.value != null && route == Routes.LOGIN) {
      return const RouteSettings(name: Routes.HOME);
    }

    return null;
  }
}

class AdminMiddleware extends GetMiddleware {
  final authService = Get.find<AuthService>();

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    // Verificar primero si el usuario está autenticado
    if (authService.user.value == null) {
      return const RouteSettings(name: Routes.LOGIN);
    }

    // Si el usuario no es administrador, redirigir al home
    if (!authService.isAdmin.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Acceso denegado',
          'No tienes permisos para acceder a esta sección',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
      return const RouteSettings(name: Routes.HOME);
    }

    return null;
  }
}
