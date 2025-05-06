import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget gradoRiskBarChartWidget(
    Map<String, Map<String, int>> estadisticasPorGrado) {
  // Si no hay datos, mostrar un mensaje
  if (estadisticasPorGrado.isEmpty) {
    return const Center(
      child: Text(
        'No hay datos suficientes para mostrar estadísticas de riesgo por grado',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Lista de grados en el orden deseado
  final grados = ['1', '2', '3'];

  // Calcular porcentajes para cada grado
  final porcentajesPorGrado = <String, Map<String, double>>{};

  for (var grado in grados) {
    final conRiesgo = estadisticasPorGrado[grado]!['conRiesgo']!;
    final sinRiesgo = estadisticasPorGrado[grado]!['sinRiesgo']!;
    final total = conRiesgo + sinRiesgo;

    if (total > 0) {
      // Calcular porcentajes
      final porcentajeConRiesgo = (conRiesgo / total) * 100;
      final porcentajeSinRiesgo = (sinRiesgo / total) * 100;

      porcentajesPorGrado[grado] = {
        'conRiesgo': porcentajeConRiesgo,
        'sinRiesgo': porcentajeSinRiesgo,
      };
    } else {
      // Si no hay datos, asignar 0%
      porcentajesPorGrado[grado] = {
        'conRiesgo': 0,
        'sinRiesgo': 0,
      };
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Center(
        child: Text(
          'Porcentaje de Riesgo Cardiometabólico por Grado',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 40),
      Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY: 100, // Escala fija para porcentajes (0-100%)
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                // tooltipBgColor: Colors.grey.shade800,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String gradoTexto;
                  String categoriaTexto;
                  double porcentaje;

                  switch (group.x) {
                    case 0:
                      gradoTexto = '1°';
                      categoriaTexto = 'Con Riesgo';
                      porcentaje = porcentajesPorGrado['1']!['conRiesgo']!;
                      break;
                    case 1:
                      gradoTexto = '1°';
                      categoriaTexto = 'Sin Riesgo';
                      porcentaje = porcentajesPorGrado['1']!['sinRiesgo']!;
                      break;
                    case 2:
                      gradoTexto = '2°';
                      categoriaTexto = 'Con Riesgo';
                      porcentaje = porcentajesPorGrado['2']!['conRiesgo']!;
                      break;
                    case 3:
                      gradoTexto = '2°';
                      categoriaTexto = 'Sin Riesgo';
                      porcentaje = porcentajesPorGrado['2']!['sinRiesgo']!;
                      break;
                    case 4:
                      gradoTexto = '3°';
                      categoriaTexto = 'Con Riesgo';
                      porcentaje = porcentajesPorGrado['3']!['conRiesgo']!;
                      break;
                    case 5:
                      gradoTexto = '3°';
                      categoriaTexto = 'Sin Riesgo';
                      porcentaje = porcentajesPorGrado['3']!['sinRiesgo']!;
                      break;
                    default:
                      return null;
                  }

                  return BarTooltipItem(
                    '$gradoTexto $categoriaTexto\n${porcentaje.toStringAsFixed(1)}%',
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

                    // Crear etiquetas para cada barra (6 barras en total)
                    switch (value.toInt()) {
                      case 0:
                        texto = '1° Con Riesgo';
                        break;
                      case 1:
                        texto = '1° Sin Riesgo';
                        break;
                      case 2:
                        texto = '2° Con Riesgo';
                        break;
                      case 3:
                        texto = '2° Sin Riesgo';
                        break;
                      case 4:
                        texto = '3° Con Riesgo';
                        break;
                      case 5:
                        texto = '3° Sin Riesgo';
                        break;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        texto,
                        style: TextStyle(
                          color: value.toInt() % 2 == 0
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
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
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            // Generar 6 barras con porcentajes - una para "Con Riesgo" y una para "Sin Riesgo" para cada grado
            barGroups: [
              // 1° Grado - Con Riesgo
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: porcentajesPorGrado['1']!['conRiesgo']!,
                    color: Colors.red.shade400,
                    width: 22,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
              // 1° Grado - Sin Riesgo
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: porcentajesPorGrado['1']!['sinRiesgo']!,
                    color: Colors.green.shade400,
                    width: 22,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
              // 2° Grado - Con Riesgo
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(
                    toY: porcentajesPorGrado['2']!['conRiesgo']!,
                    color: Colors.red.shade400,
                    width: 22,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
              // 2° Grado - Sin Riesgo
              BarChartGroupData(
                x: 3,
                barRods: [
                  BarChartRodData(
                    toY: porcentajesPorGrado['2']!['sinRiesgo']!,
                    color: Colors.green.shade400,
                    width: 22,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
              // 3° Grado - Con Riesgo
              BarChartGroupData(
                x: 4,
                barRods: [
                  BarChartRodData(
                    toY: porcentajesPorGrado['3']!['conRiesgo']!,
                    color: Colors.red.shade400,
                    width: 22,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
              // 3° Grado - Sin Riesgo
              BarChartGroupData(
                x: 5,
                barRods: [
                  BarChartRodData(
                    toY: porcentajesPorGrado['3']!['sinRiesgo']!,
                    color: Colors.green.shade400,
                    width: 22,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      // Tabla de resumen
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen por Grado:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Colors.black12),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Grado',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Con Riesgo',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Sin Riesgo',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...grados.map((grado) {
                  final conRiesgo = estadisticasPorGrado[grado]!['conRiesgo']!;
                  final sinRiesgo = estadisticasPorGrado[grado]!['sinRiesgo']!;
                  final total = conRiesgo + sinRiesgo;

                  // Calcular porcentajes para la tabla
                  final porcentajeConRiesgo =
                      total > 0 ? (conRiesgo / total) * 100 : 0.0;
                  final porcentajeSinRiesgo =
                      total > 0 ? (sinRiesgo / total) * 100 : 0.0;

                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('$grado° Grado'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$conRiesgo (${porcentajeConRiesgo.toStringAsFixed(1)}%)',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$sinRiesgo (${porcentajeSinRiesgo.toStringAsFixed(1)}%)',
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('$total (100%)'),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      // Información sobre factores de riesgo
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
    ],
  );
}

Widget _buildFactorItem(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 16)),
        Expanded(
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
