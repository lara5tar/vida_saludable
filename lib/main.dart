import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:vida_saludable/app/data/services/auth_service.dart';
import 'package:vida_saludable/firebase_options.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar el servicio de autenticación
  await Get.putAsync(() => AuthService().init());

  runApp(
    GetMaterialApp(
      title: "Vida Saludable",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.noTransition,
    ),
  );
}


// las edades
// las advertencias
// la evaluacion socioeconomica