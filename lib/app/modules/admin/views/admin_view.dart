import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_scaffold.dart';
import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Administración de Usuarios',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),

            const SizedBox(height: 30),

            // Formulario de creación de usuarios
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crear Nuevo Usuario',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Formulario
                    TextField(
                      controller: controller.nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Reemplazamos el TextField por un DropdownButton
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedEscuela.value.isNotEmpty
                                  ? controller.selectedEscuela.value
                                  : null,
                              hint: const Text('Selecciona una escuela'),
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  controller.selectedEscuela.value = newValue;
                                }
                              },
                              items: controller.escuelas
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )),

                    const SizedBox(height: 15),

                    Obx(() => TextField(
                          controller: controller.passwordController,
                          obscureText: controller.obscurePassword.value,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: controller.toggleObscurePassword,
                            ),
                          ),
                        )),

                    const SizedBox(height: 15),

                    Obx(() => TextField(
                          controller: controller.confirmPasswordController,
                          obscureText: controller.obscureConfirmPassword.value,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscureConfirmPassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  controller.toggleObscureConfirmPassword,
                            ),
                          ),
                        )),

                    const SizedBox(height: 15),

                    // Checkbox para establecer permisos de administrador
                    Obx(() => CheckboxListTile(
                          title:
                              const Text('Otorgar permisos de administrador'),
                          value: controller.isAdmin.value,
                          onChanged: (value) {
                            controller.isAdmin.value = value ?? false;
                          },
                          activeColor: Colors.green.shade700,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        )),

                    const SizedBox(height: 20),

                    // Botón para crear usuario
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.createUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Crear Usuario',
                                  style: TextStyle(
                                    fontSize: 16,
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Lista de usuarios
            Text(
              'Usuarios Registrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),

            const SizedBox(height: 15),

            // Tabla de usuarios
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.users.isEmpty) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text('No hay usuarios registrados'),
                    ),
                  ),
                );
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Correo')),
                      DataColumn(label: Text('Escuela')),
                      DataColumn(label: Text('Administrador')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: controller.users.map((user) {
                      final userId = user['id'] as String;
                      final isEditing =
                          controller.editingUserId.value == userId;
                      final String currentEscuela =
                          user['nombre_escuela'] ?? '';

                      return DataRow(cells: [
                        DataCell(Text(user['name'] ?? 'Sin nombre')),
                        DataCell(Text(user['email'] ?? '')),
                        // Celda para la escuela
                        DataCell(
                          Obx(() {
                            if (controller.editingUserId.value == userId) {
                              // Modo edición: muestra el dropdown
                              return Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 200),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: controller
                                                .editingEscuela.value.isNotEmpty
                                            ? controller.editingEscuela.value
                                            : null,
                                        hint: const Text('Selecciona'),
                                        isExpanded: true,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            controller.editingEscuela.value =
                                                newValue;
                                          }
                                        },
                                        items: controller.escuelas
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () =>
                                          controller.saveUserEscuela(
                                        userId,
                                        controller.editingEscuela.value,
                                      ),
                                      tooltip: 'Guardar',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () =>
                                          controller.cancelEditingEscuela(),
                                      tooltip: 'Cancelar',
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Modo visualización: muestra el texto con botón de editar
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Text(
                                      currentEscuela.isEmpty
                                          ? 'No asignada'
                                          : currentEscuela,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () =>
                                        controller.startEditingEscuela(
                                      userId,
                                      currentEscuela,
                                    ),
                                    tooltip: 'Editar escuela',
                                  ),
                                ],
                              );
                            }
                          }),
                        ),
                        DataCell(
                          Switch(
                            value: user['isAdmin'] == true,
                            activeColor: Colors.green.shade700,
                            onChanged: (value) {
                              controller.changeUserAdminStatus(
                                  user['id'], value);
                            },
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Botón para restablecer contraseña
                              IconButton(
                                icon: const Icon(Icons.key),
                                tooltip: 'Restablecer contraseña',
                                onPressed: () {
                                  _showResetPasswordConfirmation(
                                      user['id'], user['email']);
                                },
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showResetPasswordConfirmation(String userId, String email) {
    Get.dialog(
      AlertDialog(
        title: const Text('Restablecer contraseña'),
        content:
            Text('¿Enviar un correo a $email para restablecer la contraseña?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.resetUserPassword(userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
