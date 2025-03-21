import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget genderChartWidget(Map<String, String> totales) {
  final total = int.parse(totales['hombres']!) + int.parse(totales['mujeres']!);
  final porcentajeHombres = (int.parse(totales['hombres']!) / total) * 100;
  final porcentajeMujeres = (int.parse(totales['mujeres']!) / total) * 100;

  final bool isMobile = Get.context!.width < 600;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Text(
        'Distribución por Género',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      // if (isMobile)
      //   Column(
      //     children: [
      //       _grafica(porcentajeHombres, porcentajeMujeres),
      //       _buildIndicator(
      //         color: Colors.blue.shade300,
      //         text: 'Hombres (${totales['hombres']})',
      //       ),
      //       _buildIndicator(
      //         color: Colors.pink.shade300,
      //         text: 'Mujeres (${totales['mujeres']})',
      //       ),
      //     ],
      //   )
      // else
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          _buildIndicator(
            color: Colors.pink.shade300,
            text: 'Mujeres (${totales['mujeres']})',
          ),
          _grafica(porcentajeHombres, porcentajeMujeres),
          _buildIndicator(
            color: Colors.blue.shade300,
            text: 'Hombres (${totales['hombres']})',
          ),
        ],
      ),
    ],
  );
}

SizedBox _grafica(double porcentajeHombres, double porcentajeMujeres) {
  return SizedBox(
    height: 200,
    width: 300,
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
  );
}

Widget _buildIndicator({
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
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}
