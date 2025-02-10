import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget educationChartWidget(List<Map<String, dynamic>> users) {
  // Conteo de usuarios por nivel educativo
  Map<String, int> educacionConteo = {};
  final nivelesEducativos = [
    'Kinder',
    'Primaria',
    'Secundaria',
    'Preparatoria',
    'Universidad'
  ];

  for (var user in users) {
    final nivel = user['nivel_educativo'] ?? 'No especificado';
    educacionConteo[nivel] = (educacionConteo[nivel] ?? 0) + 1;
  }

  // Asegurar que todos los niveles tengan un valor
  for (var nivel in nivelesEducativos) {
    educacionConteo[nivel] = educacionConteo[nivel] ?? 0;
  }

  final colors = [
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.orange.shade300,
    Colors.purple.shade300,
    Colors.red.shade300,
  ];

  return Column(
    children: [
      const Text(
        'Distribución por Nivel Educativo',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: List.generate(nivelesEducativos.length, (index) {
              final nivel = nivelesEducativos[index];
              final value = educacionConteo[nivel]!;
              final porcentaje =
                  users.isEmpty ? 0.0 : (value / users.length) * 100;

              return PieChartSectionData(
                color: colors[index],
                value: value.toDouble(),
                title: '${porcentaje.toStringAsFixed(1)}%',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 20,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: List.generate(nivelesEducativos.length, (index) {
          final nivel = nivelesEducativos[index];
          final value = educacionConteo[nivel]!;

          return _buildLegend(
            color: colors[index],
            text: '$nivel ($value)',
          );
        }),
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
          shape: BoxShape.circle,
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
