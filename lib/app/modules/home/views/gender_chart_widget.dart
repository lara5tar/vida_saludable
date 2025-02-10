import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget genderChartWidget(Map<String, String> totales) {
  final total = int.parse(totales['hombres']!) + int.parse(totales['mujeres']!);
  final porcentajeHombres = (int.parse(totales['hombres']!) / total) * 100;
  final porcentajeMujeres = (int.parse(totales['mujeres']!) / total) * 100;

  return Column(
    children: [
      const Text(
        'Distribución por Género',
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
            sectionsSpace: 0,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                color: Colors.blue.shade300,
                value: porcentajeHombres,
                title: '${porcentajeHombres.toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: Colors.pink.shade300,
                value: porcentajeMujeres,
                title: '${porcentajeMujeres.toStringAsFixed(1)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIndicator(
            color: Colors.blue.shade300,
            text: 'Hombres (${totales['hombres']})',
          ),
          const SizedBox(width: 20),
          _buildIndicator(
            color: Colors.pink.shade300,
            text: 'Mujeres (${totales['mujeres']})',
          ),
        ],
      ),
    ],
  );
}

Widget _buildIndicator({
  required Color color,
  required String text,
}) {
  return Row(
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
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}
