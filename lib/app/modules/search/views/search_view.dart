import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:vida_saludable/app/widgets/custom_scaffold.dart';
import 'package:vida_saludable/app/widgets/custom_dropdown.dart';

import '../../home/views/dashboard_widget.dart';
import '../controllers/search_controller.dart' as local;

class SearchView extends GetView<local.SearchController> {
  const SearchView({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Column(
              children: [
                dashboardWidget(controller.totalPersonas(),
                    controller.getTotalesPorGenero()),
                const SizedBox(height: 20),
                TextField(
                  onChanged: controller.updateSearchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Buscar por nombre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 20,
                    children: [
                      // Solo mostrar el filtro de escuela si el usuario es administrador
                      if (controller.authService.isAdmin.value)
                        CustomDropdown(
                          hint: 'Escuela',
                          value: controller.filters['escuela'],
                          items: controller.getEscuelasUnicas(),
                          onChanged: (value) =>
                              controller.updateFilter('escuela', value),
                        ),
                      CustomDropdown(
                        hint: 'Género',
                        value: controller.filters['gender'],
                        items: const ['Mujer', 'Hombre'],
                        onChanged: (value) =>
                            controller.updateFilter('gender', value),
                      ),
                      CustomDropdown(
                        hint: 'Edad',
                        value: controller.filters['age_range'],
                        items: [
                          'Menor a 10 años',
                          ...List.generate(
                              11, (index) => (10 + index).toString()),
                          'Mayor a 20 años'
                        ],
                        onChanged: (value) =>
                            controller.updateFilter('age_range', value),
                        addAge: true,
                      ),
                      CustomDropdown(
                        hint: 'Nivel Educativo',
                        value: controller.filters['nivel_educativo'],
                        items: const [
                          'Kinder',
                          'Primaria',
                          'Secundaria',
                          'Preparatoria',
                          'Universidad',
                        ],
                        onChanged: (value) =>
                            controller.updateFilter('nivel_educativo', value),
                      ),
                      CustomDropdown(
                        hint: 'Ciudad',
                        value: controller.filters['municipio'],
                        items: controller.getCiudadesUnicas(),
                        // const
                        // [
                        //   'Abasolo',
                        //   'Aldama',
                        //   'Altamira',
                        //   'Antiguo Morelos',
                        //   'Burgos',
                        //   'Bustamante',
                        //   'Camargo',
                        //   'Casas',
                        //   'Cruillas',
                        //   'Guemez',
                        //   'Gomez Farias',
                        //   'Gonzalez',
                        //   'Guerrero',
                        //   'Gustavo Diaz Ordaz',
                        //   'Hidalgo',
                        //   'Jaumave',
                        //   'Jimenez',
                        //   'Llera',
                        //   'Cd. Madero',
                        //   'Mainero',
                        //   'Mante',
                        //   'Matamoros',
                        //   'Mendez',
                        //   'Mier',
                        //   'Miguel Aleman',
                        //   'Miquihuana',
                        //   'Nuevo Laredo',
                        //   'Nuevo Morelos',
                        //   'Ocampo',
                        //   'Padilla',
                        //   'Palmillas',
                        //   'Reynosa',
                        //   'Rio Bravo',
                        //   'San Carlos',
                        //   'San Fernando',
                        //   'San Nicolas',
                        //   'Soto la Marina',
                        //   'Tampico',
                        //   'Tula',
                        //   'Valle Hermoso',
                        //   'Victoria',
                        //   'Villagran',
                        //   'Xicotecatl',
                        // ],
                        onChanged: (value) =>
                            controller.updateFilter('municipio', value),
                      ),
                      CustomDropdown(
                        hint: 'Tipo de Escuela',
                        value: controller.filters['tipo_escuela'],
                        items: const ['Pública', 'Privada'],
                        onChanged: (value) =>
                            controller.updateFilter('tipo_escuela', value),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: controller.clearFilters,
                        icon: const Icon(Icons.clear, color: Colors.white),
                        label: const Text('Limpiar filtros',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 10),
                      if (controller.isTestUser.value)
                        ElevatedButton.icon(
                          onPressed: controller.generateTestUser,
                          icon: const Icon(Icons.science),
                          label: const Text('Generar Usuario de Prueba'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: controller.filteredUsers.isEmpty
                      ? const Center(
                          child: Text('No hay usuarios'),
                        )
                      : ListView(
                          children: [
                            for (final user in controller.paginatedUsers)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.shade600,
                                    child: Text(
                                      user['name'].toString().isEmpty
                                          ? '?'
                                          : user['name']
                                              .toString()[0]
                                              .toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    user['name'] ?? '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Edad: ${user['age'] ?? ''} años'),
                                      Text('Género: ${user['gender'] ?? '?'}'),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.green.shade600,
                                  ),
                                  onTap: () =>
                                      Get.toNamed('/user/${user['id']}'),
                                ),
                              ),
                            _buildPagination(),
                          ],
                        ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      // decoration: const BoxDecoration(
      //   color: Colors.white,
      //   // boxShadow: [
      //   //   BoxShadow(
      //   //     color: Colors.grey.withOpacity(0.2),
      //   //     spreadRadius: 1,
      //   //     blurRadius: 3,
      //   //     offset: const Offset(0, -1),
      //   //   ),
      //   // ],
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: controller.currentPage.value > 0
                ? controller.previousPage
                : null,
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.green,
            disabledColor: Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(
            'Página ${controller.currentPage.value + 1} de ${controller.totalPages > 0 ? controller.totalPages : 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: controller.currentPage.value < controller.totalPages - 1
                ? controller.nextPage
                : null,
            icon: const Icon(Icons.arrow_forward_ios),
            color: Colors.green,
            disabledColor: Colors.grey,
          ),
          const SizedBox(width: 20),
          DropdownButton<int>(
            value: controller.itemsPerPage.value,
            onChanged: (value) {
              if (value != null) {
                controller.itemsPerPage.value = value;
                controller.currentPage.value = 0; // Reset to first page
              }
            },
            items: [5, 10, 20, 50].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value por página'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
