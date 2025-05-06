// filepath: /home/lara5tar/Escritorio/vida_saludable/lib/app/modules/home/views/estilo_vida_grado_chart_widget.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget estiloVidaGradoChartWidget(
    Map<String, Map<String, int>> estadisticasPorGrado) {
  // Si no hay datos, mostrar un mensaje
  if (estadisticasPorGrado.isEmpty) {
    return const Center(
      child: Text(
        'No hay datos suficientes para mostrar estadísticas de estilo de vida por grado',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Definir colores para cada categoría de estilo de vida
  final colores = {
    'saludable': Colors.green.shade400,
    'regular': Colors.amber.shade400,
    'malo': Colors.red.shade400,
    'sinDatos': Colors.grey.shade300,
  };

  // Nombres descriptivos para las categorías
  final nombresEstilos = {
    'saludable': 'Saludable',
    'regular': 'Regular',
    'malo': 'Malo',
    'sinDatos': 'Sin Datos',
  };

  // Para mostrar nombre más presentable en la gráfica
  String getNombreGrado(String grado) {
    if (grado == 'otro') return 'Otros Grados';
    return 'Grado $grado';
  }

  // Calcular totales por grado para los porcentajes
  final totalesPorGrado = <String, int>{};

  for (var grado in estadisticasPorGrado.keys) {
    final datos = estadisticasPorGrado[grado]!;
    totalesPorGrado[grado] = 0;
    for (var categoria in ['saludable', 'regular', 'malo', 'sinDatos']) {
      totalesPorGrado[grado] =
          totalesPorGrado[grado]! + (datos[categoria] ?? 0);
    }
  }

  // Calcular porcentajes por categoría y grado
  final porcentajesPorGrado = <String, Map<String, double>>{};

  for (var grado in estadisticasPorGrado.keys) {
    final datos = estadisticasPorGrado[grado]!;
    final total = totalesPorGrado[grado]!;
    porcentajesPorGrado[grado] = {};

    if (total > 0) {
      for (var categoria in ['saludable', 'regular', 'malo', 'sinDatos']) {
        porcentajesPorGrado[grado]![categoria] =
            (datos[categoria] ?? 0) / total * 100;
      }
    } else {
      for (var categoria in ['saludable', 'regular', 'malo', 'sinDatos']) {
        porcentajesPorGrado[grado]![categoria] = 0.0;
      }
    }
  }

  // Ordenar los grados para mostrarlos en orden
  final gradosOrdenados = estadisticasPorGrado.keys.toList();
  gradosOrdenados.sort((a, b) {
    if (a == 'otro') return 1;
    if (b == 'otro') return -1;
    return a.compareTo(b);
  });

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Estilo de Vida por Grado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Leyenda general (movida arriba para toda la visualización)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.0,
            runSpacing: 8.0,
            children: [
              for (var categoria in [
                'saludable',
                'regular',
                'malo',
                'sinDatos'
              ])
                _buildIndicador(
                  color: colores[categoria]!,
                  texto: nombresEstilos[categoria]!,
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Mostrar los gráficos de pastel para todos los grados usando Wrap
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20.0,
            runSpacing: 30.0,
            children: [
              for (var grado in gradosOrdenados)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 280,
                    maxWidth: 400,
                  ),
                  child: Column(
                    children: [
                      Text(
                        getNombreGrado(grado),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Gráfico de pastel para el grado actual
                      SizedBox(
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              for (var categoria in [
                                'saludable',
                                'regular',
                                'malo',
                                'sinDatos'
                              ])
                                if (estadisticasPorGrado[grado]![categoria]! >
                                    0)
                                  PieChartSectionData(
                                    value:
                                        estadisticasPorGrado[grado]![categoria]!
                                            .toDouble(),
                                    title:
                                        '${porcentajesPorGrado[grado]![categoria]!.toStringAsFixed(1)}%',
                                    color: colores[categoria],
                                    radius: 90,
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                            centerSpaceColor: Colors.white,
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {},
                            ),
                          ),
                        ),
                      ),

                      // Indicadores de colores específicos para este grado
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8.0,
                          runSpacing: 6.0,
                          children: [
                            for (var categoria in [
                              'saludable',
                              'regular',
                              'malo',
                              'sinDatos'
                            ])
                              if (estadisticasPorGrado[grado]![categoria]! > 0)
                                _buildIndicador(
                                  color: colores[categoria]!,
                                  texto:
                                      '${nombresEstilos[categoria]!}: ${estadisticasPorGrado[grado]![categoria]} (${porcentajesPorGrado[grado]![categoria]!.toStringAsFixed(1)}%)',
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Tablas de datos al final
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Text(
            'Tablas de Datos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Wrap para las tablas de datos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20.0, // Espacio horizontal entre tablas
            runSpacing: 30.0, // Espacio vertical cuando las tablas se envuelven
            children: [
              for (var grado in gradosOrdenados)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 280,
                    maxWidth: 400,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          getNombreGrado(grado),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Tabla de datos en formato tradicional
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Table(
                          border: TableBorder(
                            horizontalInside:
                                BorderSide(color: Colors.grey.shade300),
                            verticalInside:
                                BorderSide(color: Colors.grey.shade300),
                            bottom: BorderSide(color: Colors.grey.shade300),
                            left: BorderSide(color: Colors.grey.shade300),
                            right: BorderSide(color: Colors.grey.shade300),
                            top: BorderSide(color: Colors.grey.shade300),
                          ),
                          defaultColumnWidth: const IntrinsicColumnWidth(),
                          children: [
                            // Encabezado de la tabla
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    'Categoría',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    'Cantidad',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    'Porcentaje',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            // Filas de datos
                            for (var categoria in [
                              'saludable',
                              'regular',
                              'malo',
                              'sinDatos'
                            ])
                              TableRow(
                                decoration: BoxDecoration(
                                  color: colores[categoria]!.withOpacity(0.1),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: colores[categoria],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            nombresEstilos[categoria]!,
                                            style: TextStyle(
                                              color: colores[categoria]!
                                                  .withOpacity(0.8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      '${estadisticasPorGrado[grado]![categoria]}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: colores[categoria]!
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      '${porcentajesPorGrado[grado]![categoria]!.toStringAsFixed(1)}%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: colores[categoria]!
                                            .withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            // Fila del total
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    '${totalesPorGrado[grado]}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    '100%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Descripción de categorías (comentada)
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //   child: Container(
        //     padding: const EdgeInsets.all(16),
        //     decoration: BoxDecoration(
        //       color: Colors.grey.shade100,
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         const Text(
        //           'Clasificación del Estilo de Vida:',
        //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        //         ),
        //         const SizedBox(height: 8),
        //         _buildFactorItem(
        //           'Estilo de Vida Saludable: ≥ 204 puntos',
        //           Colors.green.shade700,
        //         ),
        //         _buildFactorItem(
        //           'Estilo de Vida Regular: ≥ 170 y < 204 puntos',
        //           Colors.amber.shade700,
        //         ),
        //         _buildFactorItem(
        //           'Mal Estilo de Vida: < 170 puntos',
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

        const SizedBox(height: 20),
      ],
    ),
  );
}

Widget _buildFactorItem(String text, [Color? color]) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 16)),
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

Widget _buildIndicador({
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
