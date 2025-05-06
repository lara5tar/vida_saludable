import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget sexoRiskBarChartWidget(
    Map<String, Map<String, int>> estadisticasPorSexo) {
  // Si no hay datos, mostrar un mensaje
  if (estadisticasPorSexo.isEmpty ||
      !estadisticasPorSexo.containsKey('masculino') ||
      !estadisticasPorSexo.containsKey('femenino')) {
    return const Center(
      child: Text(
        'No hay datos suficientes para mostrar estadísticas de riesgo por sexo',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Calcular porcentajes para cada sexo
  final porcentajesPorSexo = <String, Map<String, double>>{};

  for (var entrada in estadisticasPorSexo.entries) {
    final sexo = entrada.key;
    final datos = entrada.value;
    final conRiesgo = datos['conRiesgo'] ?? 0;
    final sinRiesgo = datos['sinRiesgo'] ?? 0;
    final total = conRiesgo + sinRiesgo;

    if (total > 0) {
      // Calcular porcentajes
      final porcentajeConRiesgo = (conRiesgo / total) * 100;
      final porcentajeSinRiesgo = (sinRiesgo / total) * 100;

      porcentajesPorSexo[sexo] = {
        'conRiesgo': porcentajeConRiesgo,
        'sinRiesgo': porcentajeSinRiesgo,
      };
    } else {
      // Si no hay datos, asignar 0%
      porcentajesPorSexo[sexo] = {
        'conRiesgo': 0,
        'sinRiesgo': 0,
      };
    }
  }

  // Para garantizar que ambas claves existan
  if (!porcentajesPorSexo.containsKey('masculino')) {
    porcentajesPorSexo['masculino'] = {'conRiesgo': 0, 'sinRiesgo': 0};
  }
  if (!porcentajesPorSexo.containsKey('femenino')) {
    porcentajesPorSexo['femenino'] = {'conRiesgo': 0, 'sinRiesgo': 0};
  }

  // Para mostrar nombre más presentable en la gráfica
  String getNombreSexo(String sexo) {
    if (sexo == 'masculino') return 'Hombres';
    if (sexo == 'femenino') return 'Mujeres';
    return sexo;
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Porcentaje de Riesgo Cardiometabólico por Sexo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),

        // Contenedor de la gráfica
        LayoutBuilder(
          builder: (context, constraints) {
            // Asegurarse de que el ancho sea definido
            final chartWidth =
                constraints.maxWidth > 0 ? constraints.maxWidth : 300.0;

            return Container(
              height: 400,
              width: chartWidth,
              padding: const EdgeInsets.all(8),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: 100, // Escala fija para porcentajes (0-100%)
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String sexo;
                        String categoriaTexto;
                        double porcentaje;

                        switch (group.x) {
                          case 0:
                            sexo = 'Hombres';
                            categoriaTexto = 'Con Riesgo';
                            porcentaje =
                                porcentajesPorSexo['masculino']!['conRiesgo']!;
                            break;
                          case 1:
                            sexo = 'Hombres';
                            categoriaTexto = 'Sin Riesgo';
                            porcentaje =
                                porcentajesPorSexo['masculino']!['sinRiesgo']!;
                            break;
                          case 2:
                            sexo = 'Mujeres';
                            categoriaTexto = 'Con Riesgo';
                            porcentaje =
                                porcentajesPorSexo['femenino']!['conRiesgo']!;
                            break;
                          case 3:
                            sexo = 'Mujeres';
                            categoriaTexto = 'Sin Riesgo';
                            porcentaje =
                                porcentajesPorSexo['femenino']!['sinRiesgo']!;
                            break;
                          default:
                            return null;
                        }

                        return BarTooltipItem(
                          '$sexo $categoriaTexto\n${porcentaje.toStringAsFixed(1)}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          String texto = '';

                          // Crear etiquetas para cada barra (4 barras en total)
                          switch (value.toInt()) {
                            case 0:
                              texto = 'Hombres Con Riesgo';
                              break;
                            case 1:
                              texto = 'Hombres Sin Riesgo';
                              break;
                            case 2:
                              texto = 'Mujeres Con Riesgo';
                              break;
                            case 3:
                              texto = 'Mujeres Sin Riesgo';
                              break;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: 60,
                              child: Text(
                                texto,
                                style: TextStyle(
                                  color: value.toInt() % 2 == 0
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                maxLines: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text(
                        'Porcentaje (%)',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          // Mostrar valores en el eje Y (cada 20%)
                          if (value % 20 == 0) {
                            return Text(
                              '${value.toInt()}%',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    checkToShowHorizontalLine: (value) => value % 20 == 0,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  // Generar 4 barras con porcentajes - (Hombres/Mujeres) x (Con Riesgo/Sin Riesgo)
                  barGroups: [
                    // Hombres - Con Riesgo
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['masculino']!['conRiesgo']!,
                          color: Colors.red.shade400,
                          width: 22,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Hombres - Sin Riesgo
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['masculino']!['sinRiesgo']!,
                          color: Colors.green.shade400,
                          width: 22,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Mujeres - Con Riesgo
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['femenino']!['conRiesgo']!,
                          color: Colors.red.shade400,
                          width: 22,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Mujeres - Sin Riesgo
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['femenino']!['sinRiesgo']!,
                          color: Colors.green.shade400,
                          width: 22,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),
        // Leyenda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIndicador(
                color: Colors.red.shade400,
                texto: 'Con Riesgo',
              ),
              const SizedBox(width: 40),
              _buildIndicador(
                color: Colors.green.shade400,
                texto: 'Sin Riesgo',
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
        // Tabla de resumen - Aseguramos que está centrada y con ancho adecuado
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Column(
              children: [
                const Text(
                  'Resumen por Sexo:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth,
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth * 0.8,
                          ),
                          child: Table(
                            defaultColumnWidth: const IntrinsicColumnWidth(),
                            border:
                                TableBorder.all(color: Colors.grey.shade300),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: [
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
                                      'Sexo',
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
                                      'Con Riesgo',
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
                                      'Sin Riesgo',
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
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              ...estadisticasPorSexo.entries.map((entrada) {
                                final sexo = entrada.key;
                                final datos = entrada.value;
                                final conRiesgo = datos['conRiesgo'] ?? 0;
                                final sinRiesgo = datos['sinRiesgo'] ?? 0;
                                final total = conRiesgo + sinRiesgo;

                                // Calcular porcentajes para la tabla
                                final porcentajeConRiesgo =
                                    total > 0 ? (conRiesgo / total) * 100 : 0.0;
                                final porcentajeSinRiesgo =
                                    total > 0 ? (sinRiesgo / total) * 100 : 0.0;

                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: sexo == 'masculino'
                                        ? Colors.blue.shade50
                                        : Colors.pink.shade50,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        getNombreSexo(sexo),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        '$conRiesgo (${porcentajeConRiesgo.toStringAsFixed(1)}%)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        '$sinRiesgo (${porcentajeSinRiesgo.toStringAsFixed(1)}%)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        '$total (100%)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // const SizedBox(height: 20),
        // // Información sobre factores de riesgo
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
        //           'Factores de riesgo cardiometabólico:',
        //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        //         ),
        //         const SizedBox(height: 8),
        //         _buildFactorItem('IMC elevado (≥ 25)'),
        //         _buildFactorItem('Presión arterial alta (≥ 130/85 mmHg)'),
        //         _buildFactorItem('Glucosa en ayunas elevada (≥ 100 mg/dL)'),
        //         _buildFactorItem(
        //             'Perímetro de cintura elevado (≥ 102 cm en hombres, ≥ 88 cm en mujeres)'),
        //       ],
        //     ),
        //   ),
        // ),

        const SizedBox(height: 20),
      ],
    ),
  );
}

Widget _buildFactorItem(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 16)),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
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
