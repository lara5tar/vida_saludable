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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: controller.updateSearchQuery,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
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
                      items: const [
                        'Abasolo',
                        'Aldama',
                        'Altamira',
                        'Antiguo Morelos',
                        'Burgos',
                        'Bustamante',
                        'Camargo',
                        'Casas',
                        'Cruillas',
                        'Guemez',
                        'Gomez Farias',
                        'Gonzalez',
                        'Guerrero',
                        'Gustavo Diaz Ordaz',
                        'Hidalgo',
                        'Jaumave',
                        'Jimenez',
                        'Llera',
                        'Cd. Madero',
                        'Mainero',
                        'Mante',
                        'Matamoros',
                        'Mendez',
                        'Mier',
                        'Miguel Aleman',
                        'Miquihuana',
                        'Nuevo Laredo',
                        'Nuevo Morelos',
                        'Ocampo',
                        'Padilla',
                        'Palmillas',
                        'Reynosa',
                        'Rio Bravo',
                        'San Carlos',
                        'San Fernando',
                        'San Nicolas',
                        'Soto la Marina',
                        'Tampico',
                        'Tula',
                        'Valle Hermoso',
                        'Victoria',
                        'Villagran',
                        'Xicotecatl',
                      ],
                      onChanged: (value) =>
                          controller.updateFilter('municipio', value),
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
                const SizedBox(height: 20),
                Expanded(
                  child: controller.filteredUsers.isEmpty
                      ? const Center(
                          child: Text('No hay usuarios'),
                        )
                      : ListView(
                          children: [
                            dashboardWidget(controller.totalPersonas(),
                                controller.getTotalesPorGenero()),
                            const SizedBox(height: 20),
                            for (final user in controller.filteredUsers)
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
                                      user['name'][0].toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    user['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Edad: ${user['age']} años'),
                                      Text('Género: ${user['gender']}'),
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
                          ],
                        ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
