import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget estiloVidaChartWidget(Map<String, int> estadisticas) {
  // Si no hay datos o todos están en 'sinDatos', mostrar un mensaje
  if (estadisticas.isEmpty ||
      (estadisticas['saludable'] == 0 &&
          estadisticas['regular'] == 0 &&
          estadisticas['malo'] == 0)) {
    return const Center(
      child: Text(
        'No hay datos suficientes para mostrar estadísticas de estilo de vida',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Calcular el total de personas con datos válidos
  final totalConDatos = estadisticas['saludable']! +
      estadisticas['regular']! +
      estadisticas['malo']!;
  final totalGeneral = totalConDatos + estadisticas['sinDatos']!;

  // Calcular porcentajes
  final porcentajes = <String, double>{};
  estadisticas.forEach((key, value) {
    porcentajes[key] = totalGeneral > 0 ? (value / totalGeneral) * 100 : 0;
  });

  // Definir colores para cada categoría
  final colores = {
    'saludable': Colors.green.shade400,
    'regular': Colors.amber.shade400,
    'malo': Colors.red.shade400,
    'sinDatos': Colors.grey.shade300,
  };

  // Nombres descriptivos para las categorías
  final nombresEstados = {
    'saludable': 'Estilo de Vida Saludable',
    'regular': 'Estilo de Vida Regular',
    'malo': 'Mal Estilo de Vida',
    'sinDatos': 'Sin Datos Suficientes',
  };

  // Mapeo para criterios
  final criterios = {
    'saludable': '≥ 204 puntos',
    'regular': '≥ 170 y < 204 puntos',
    'malo': '< 170 puntos',
    'sinDatos': 'No completó cuestionarios',
  };

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Distribución por Estilo de Vida',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 10),

        // Leyenda general en la parte superior
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20.0,
            runSpacing: 10.0,
            children: [
              for (var categoria in [
                'saludable',
                'regular',
                'malo',
                'sinDatos'
              ])
                _buildIndicadorLeyenda(
                  color: colores[categoria]!,
                  texto: nombresEstados[categoria]!,
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Wrap para contener tanto la gráfica como la tabla lado a lado
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 24.0,
            runSpacing: 24.0,
            children: [
              // Gráfico de pastel
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 300,
                  maxWidth: 450,
                ),
                child: SizedBox(
                  height: 350,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        for (var categoria in [
                          'saludable',
                          'regular',
                          'malo',
                          'sinDatos'
                        ])
                          PieChartSectionData(
                            value: estadisticas[categoria]!.toDouble(),
                            title:
                                '${porcentajes[categoria]!.toStringAsFixed(1)}%',
                            color: colores[categoria],
                            radius: 115,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      centerSpaceColor: Colors.white,
                      pieTouchData: PieTouchData(
                        touchCallback:
                            (FlTouchEvent event, pieTouchResponse) {},
                      ),
                    ),
                  ),
                ),
              ),

              // Tabla de resultados
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 400,
                  maxWidth: 550,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 480,
                      ),
                      child: DataTable(
                        horizontalMargin: 16,
                        columnSpacing: 24,
                        border: TableBorder.all(color: Colors.grey.shade300),
                        headingRowColor:
                            WidgetStateProperty.all(Colors.grey.shade100),
                        dataRowMinHeight: 48,
                        dataRowMaxHeight: 64,
                        columns: const [
                          DataColumn(
                            label: Text('Categoría',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Criterio',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Cantidad',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          DataColumn(
                            label: Text('Porcentaje',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                        rows: [
                          for (var categoria in [
                            'saludable',
                            'regular',
                            'malo',
                            'sinDatos'
                          ])
                            DataRow(
                              cells: [
                                DataCell(
                                  Container(
                                    width: 140,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      nombresEstados[categoria]!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: 120,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(criterios[categoria]!),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: 80,
                                    padding: const EdgeInsets.all(4.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      estadisticas[categoria].toString(),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    width: 80,
                                    padding: const EdgeInsets.all(4.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${porcentajes[categoria]!.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              color: WidgetStateProperty.resolveWith<Color?>(
                                (states) {
                                  return colores[categoria]!.withOpacity(0.1);
                                },
                              ),
                            ),
                          // Fila para el total
                          DataRow(
                            cells: [
                              const DataCell(
                                Text('Total',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const DataCell(Text('')),
                              DataCell(
                                Text(
                                  totalGeneral.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const DataCell(
                                Text('100%',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // // Descripción de categorías
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //   child: Container(
        //     padding: const EdgeInsets.all(16),
        //     decoration: BoxDecoration(
        //       color: Colors.grey.shade100,
        //       borderRadius: BorderRadius.circular(10),
        //       border: Border.all(color: Colors.grey.shade300),
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         const Text(
        //           'Clasificación del Estilo de Vida:',
        //           style: TextStyle(
        //             fontSize: 16,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //         const SizedBox(height: 10),
        //         _buildFactorItem(
        //           'Estilo de Vida Saludable (≥ 204 puntos): Persona con hábitos que favorecen su salud y bienestar.',
        //           Colors.green.shade700,
        //         ),
        //         _buildFactorItem(
        //           'Estilo de Vida Regular (≥ 170 y < 204 puntos): Persona con hábitos que requieren mejoras.',
        //           Colors.amber.shade700,
        //         ),
        //         _buildFactorItem(
        //           'Mal Estilo de Vida (< 170 puntos): Persona con hábitos perjudiciales para su salud.',
        //           Colors.red.shade700,
        //         ),
        //         const SizedBox(height: 5),
        //         const Text(
        //           'El puntaje se obtiene de sumar los resultados de 51 preguntas relacionadas con hábitos de vida.',
        //           style: TextStyle(
        //             fontSize: 12,
        //             fontStyle: FontStyle.italic,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

        // const SizedBox(height: 20),
      ],
    ),
  );
}

Widget _buildFactorItem(String text, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: TextStyle(fontSize: 16, color: color)),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildIndicadorLeyenda({
  required Color color,
  required String texto,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: color,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        texto,
        style: const TextStyle(fontSize: 14),
      ),
    ],
  );
}
