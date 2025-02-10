import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget ageChartWidget(List<Map<String, dynamic>> users) {
  // Contadores para cada categoría de edad
  final menores10 = users.where((user) => (user['age'] as num) < 10).length;
  final mayores20 = users.where((user) => (user['age'] as num) > 20).length;

  // Mapa para contar usuarios por edad específica (10-20)
  Map<int, int> edadesConteo = {};
  for (int edad = 10; edad <= 20; edad++) {
    edadesConteo[edad] =
        users.where((user) => (user['age'] as num) == edad).length;
  }

  return Column(
    children: [
      const Text(
        'Distribución por Edad',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: users.length.toDouble(),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const Text('<10');
                    if (value == 12) return const Text('>20');
                    return Text('${value + 9}');
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300),
            ),
            barGroups: [
              // Menores de 10
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: menores10.toDouble(),
                    color: Colors.blue.shade300,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              // Edades de 10 a 20
              for (int edad = 10; edad <= 20; edad++)
                BarChartGroupData(
                  x: edad - 9,
                  barRods: [
                    BarChartRodData(
                      toY: edadesConteo[edad]!.toDouble(),
                      color: Colors.green.shade500,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              // Mayores de 20
              BarChartGroupData(
                x: 12,
                barRods: [
                  BarChartRodData(
                    toY: mayores20.toDouble(),
                    color: Colors.orange.shade300,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 20,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _buildLegend(
            color: Colors.blue.shade300,
            text: 'Menores de 10 ($menores10)',
          ),
          _buildLegend(
            color: Colors.green.shade500,
            text:
                'Entre 10 y 20 (${edadesConteo.values.reduce((a, b) => a + b)})',
          ),
          _buildLegend(
            color: Colors.orange.shade300,
            text: 'Mayores de 20 ($mayores20)',
          ),
        ],
      ),
    ],
  );
}

Widget _buildLegend({
  required Color color,
  required String text,
}) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(4),
          color: color,
        ),
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    ],
  );
}
