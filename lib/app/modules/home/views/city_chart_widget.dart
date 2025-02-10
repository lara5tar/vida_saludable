import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget cityChartWidget(List<Map<String, dynamic>> users) {
  // Conteo de usuarios por ciudad
  Map<String, int> ciudadesConteo = {};
  for (var user in users) {
    final ciudad = user['municipio'] ?? 'No especificado';
    ciudadesConteo[ciudad] = (ciudadesConteo[ciudad] ?? 0) + 1;
  }

  // Ordenar ciudades por cantidad de usuarios (descendente)
  var ciudadesOrdenadas = ciudadesConteo.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return Column(
    children: [
      const Text(
        'Distribución por Ciudad',
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
            maxY: ciudadesConteo.values
                .reduce((a, b) => a > b ? a : b)
                .toDouble(),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value >= ciudadesOrdenadas.length) {
                      return const Text('');
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          ciudadesOrdenadas[value.toInt()].key,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  },
                  reservedSize: 60,
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
            barGroups: List.generate(
              ciudadesOrdenadas.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: ciudadesOrdenadas[index].value.toDouble(),
                    color: Colors.green.shade400,
                    width: 20,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      // Leyenda con totales
      Wrap(
        spacing: 20,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: ciudadesOrdenadas
            .take(5) // Mostrar solo las 5 ciudades con más usuarios
            .map(
              (entry) => _buildLegend(
                color: Colors.green.shade400,
                text: '${entry.key} (${entry.value})',
              ),
            )
            .toList(),
      ),
    ],
  );
}

Widget _buildLegend({
  required Color color,
  required String text,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
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
