import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Obx(() => controller.isCreatingAdmin.value
              ? _buildCreateAdminForm()
              : _buildLoginForm()),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Image.asset(
              'assets/logo.webp',
              height: 120,
            ),
          ),

          // Título
          // Text(
          //   'Vida Saludable',
          //   style: TextStyle(
          //     fontSize: 28,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.green.shade800,
          //   ),
          // ),

          const SizedBox(height: 10),

          // Subtítulo
          Text(
            'Inicia sesión para continuar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 40),

          // Formulario de login
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                // Campo de correo
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email, color: Colors.green.shade700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: Colors.green.shade700, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Campo de contraseña
                Obx(() => TextField(
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon:
                            Icon(Icons.lock, color: Colors.green.shade700),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: controller.toggleObscurePassword,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.green.shade700, width: 2),
                        ),
                      ),
                    )),

                const SizedBox(height: 30),

                // Botón de inicio de sesión
                Obx(() => ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 50)),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),

                const SizedBox(height: 20),

                // Texto de ayuda
                Text(
                  'Solo usuarios autorizados pueden acceder',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Contacta al administrador si necesitas acceso',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 30),

                // Link para crear primer administrador
                // TextButton(
                //   onPressed: controller.toggleCreatingAdmin,
                //   child: Text(
                //     '¿Primera vez usando la app? Crear administrador',
                //     style: TextStyle(
                //       color: Colors.green.shade700,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAdminForm() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Image.asset(
              'assets/logo.webp',
              height: 100,
            ),
          ),

          // Título
          Text(
            'Crear Primer Administrador',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),

          const SizedBox(height: 10),

          // Subtítulo
          Text(
            'Configura el primer usuario con acceso de administrador',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 30),

          // Formulario de creación de administrador
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                // Campo de correo
                TextField(
                  controller: controller.adminEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email, color: Colors.green.shade700),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Campo de contraseña
                Obx(() => TextField(
                      controller: controller.adminPasswordController,
                      obscureText: controller.obscureAdminPassword.value,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon:
                            Icon(Icons.lock, color: Colors.green.shade700),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscureAdminPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: controller.toggleObscureAdminPassword,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )),

                const SizedBox(height: 15),

                // Campo de confirmar contraseña
                Obx(() => TextField(
                      controller: controller.confirmAdminPasswordController,
                      obscureText: controller.obscureConfirmAdminPassword.value,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        prefixIcon: Icon(Icons.lock_reset,
                            color: Colors.green.shade700),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscureConfirmAdminPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed:
                              controller.toggleObscureConfirmAdminPassword,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )),

                const SizedBox(height: 25),

                // Botón para crear administrador
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.createInitialAdmin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Crear Administrador',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),

                const SizedBox(height: 20),

                // Botón para volver a login
                TextButton(
                  onPressed: controller.toggleCreatingAdmin,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back),
                      const SizedBox(width: 8),
                      Text(
                        'Volver a Iniciar Sesión',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
