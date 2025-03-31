import 'package:get/get.dart';
import 'package:vida_saludable/app/middlewares/auth_middleware.dart';
import 'package:vida_saludable/app/modules/admin/bindings/admin_binding.dart';
import 'package:vida_saludable/app/modules/admin/views/admin_view.dart';
import 'package:vida_saludable/app/modules/login/bindings/login_binding.dart';
import 'package:vida_saludable/app/modules/login/views/login_view.dart';
import 'package:vida_saludable/app/modules/user/views/user_view.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/user/bindings/user_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.USER,
      page: () => const UserView(),
      binding: UserBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN,
      page: () => const AdminView(),
      binding: AdminBinding(),
      middlewares: [AuthMiddleware(), AdminMiddleware()],
    ),
  ];
}
