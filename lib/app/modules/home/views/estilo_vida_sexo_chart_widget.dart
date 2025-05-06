import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget estiloVidaSexoChartWidget(
    Map<String, Map<String, int>> estadisticasPorSexo) {
  // Si no hay datos, mostrar un mensaje
  if (estadisticasPorSexo.isEmpty ||
      !estadisticasPorSexo.containsKey('masculino') ||
      !estadisticasPorSexo.containsKey('femenino')) {
    return const Center(
      child: Text(
        'No hay datos suficientes para mostrar estadísticas de estilo de vida por sexo',
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
  String getNombreSexo(String sexo) {
    if (sexo == 'masculino') return 'Hombres';
    if (sexo == 'femenino') return 'Mujeres';
    return sexo;
  }

  // Calcular totales por sexo para los porcentajes
  final totalesPorSexo = {
    'masculino': 0,
    'femenino': 0,
  };

  for (var sexo in ['masculino', 'femenino']) {
    final datos = estadisticasPorSexo[sexo]!;
    for (var categoria in ['saludable', 'regular', 'malo', 'sinDatos']) {
      totalesPorSexo[sexo] = totalesPorSexo[sexo]! + (datos[categoria] ?? 0);
    }
  }

  // Calcular porcentajes por categoría y sexo
  final porcentajesPorSexo = <String, Map<String, double>>{
    'masculino': {},
    'femenino': {},
  };

  for (var sexo in ['masculino', 'femenino']) {
    final datos = estadisticasPorSexo[sexo]!;
    final total = totalesPorSexo[sexo]!;

    if (total > 0) {
      for (var categoria in ['saludable', 'regular', 'malo', 'sinDatos']) {
        porcentajesPorSexo[sexo]![categoria] =
            (datos[categoria] ?? 0) / total * 100;
      }
    } else {
      for (var categoria in ['saludable', 'regular', 'malo', 'sinDatos']) {
        porcentajesPorSexo[sexo]![categoria] = 0.0;
      }
    }
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Estilo de Vida por Sexo',
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

        // Mostrar los gráficos de pastel para ambos sexos usando Wrap
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 20.0,
            runSpacing: 20.0,
            children: [
              for (var sexo in ['masculino', 'femenino'])
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 280,
                    maxWidth: 400,
                  ),
                  child: Column(
                    children: [
                      Text(
                        getNombreSexo(sexo),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Gráfico de pastel para el sexo actual
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
                                if (estadisticasPorSexo[sexo]![categoria]! > 0)
                                  PieChartSectionData(
                                    value:
                                        estadisticasPorSexo[sexo]![categoria]!
                                            .toDouble(),
                                    title:
                                        '${porcentajesPorSexo[sexo]![categoria]!.toStringAsFixed(1)}%',
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

                      // Indicadores de colores específicos para este sexo
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
                              if (estadisticasPorSexo[sexo]![categoria]! > 0)
                                _buildIndicador(
                                  color: colores[categoria]!,
                                  texto:
                                      '${nombresEstilos[categoria]!}: ${estadisticasPorSexo[sexo]![categoria]} (${porcentajesPorSexo[sexo]![categoria]!.toStringAsFixed(1)}%)',
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

        // Tablas de datos con nuevo diseño
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20.0,
          runSpacing: 30.0,
          children: [
            // Tabla para Hombres
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Resumen Hombres:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildNuevoEstiloTabla(
                    'masculino',
                    estadisticasPorSexo,
                    porcentajesPorSexo,
                    totalesPorSexo,
                    colores,
                    nombresEstilos),
              ],
            ),

            // Tabla para Mujeres
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Resumen Mujeres:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildNuevoEstiloTabla(
                    'femenino',
                    estadisticasPorSexo,
                    porcentajesPorSexo,
                    totalesPorSexo,
                    colores,
                    nombresEstilos),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),
      ],
    ),
  );
}

// Nueva función para construir las tablas con el estilo mejorado
Widget _buildNuevoEstiloTabla(
  String sexo,
  Map<String, Map<String, int>> estadisticasPorSexo,
  Map<String, Map<String, double>> porcentajesPorSexo,
  Map<String, int> totalesPorSexo,
  Map<String, Color> colores,
  Map<String, String> nombresEstilos,
) {
  // Lista de categorías ordenadas como en la imagen
  final categorias = ['saludable', 'regular', 'malo', 'sinDatos'];

  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade300),
        verticalInside: BorderSide(color: Colors.grey.shade300),
      ),
      children: [
        // Encabezados de la tabla
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
          children: [
            for (var categoria in categorias)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 12.0),
                child: Text(
                  nombresEstilos[categoria]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              child: Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        // Fila con valores y porcentajes
        TableRow(
          children: [
            for (var categoria in categorias)
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 12.0),
                color: colores[categoria]!.withOpacity(0.1),
                child: Text(
                  '${estadisticasPorSexo[sexo]![categoria]} (${porcentajesPorSexo[sexo]![categoria]!.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: sexo == 'masculino'
                        ? Colors.blue.shade800
                        : Colors.pink.shade800,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              color: Colors.grey.shade50,
              child: Text(
                '${totalesPorSexo[sexo]} (100%)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: sexo == 'masculino'
                      ? Colors.blue.shade800
                      : Colors.pink.shade800,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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
