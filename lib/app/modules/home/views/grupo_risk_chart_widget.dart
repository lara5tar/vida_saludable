import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget grupoRiskChartWidget(
    Map<String, Map<String, int>> estadisticasPorGrupo) {
  // Si no hay datos, mostrar un mensaje
  if (estadisticasPorGrupo.isEmpty) {
    return const Center(
      child: Text(
        'No hay datos suficientes para mostrar estadísticas de riesgo por grupo',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Center(
        child: Text(
          'Riesgo Cardiometabólico por Grupo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 20),
      // Crear una gráfica para cada grupo
      ...estadisticasPorGrupo.entries.map((entry) {
        final grupo = entry.key;
        final estadisticas = entry.value;
        final totalGrupo =
            estadisticas['conRiesgo']! + estadisticas['sinRiesgo']!;

        // Si no hay datos para este grupo, mostrar mensaje
        if (totalGrupo == 0) {
          return const SizedBox.shrink();
        }

        final porcentajeConRiesgo =
            (estadisticas['conRiesgo']! / totalGrupo) * 100;
        final porcentajeSinRiesgo =
            (estadisticas['sinRiesgo']! / totalGrupo) * 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grupo: $grupo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total personas: $totalGrupo',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.red.shade400,
                                  value: porcentajeConRiesgo,
                                  title:
                                      '${porcentajeConRiesgo.toStringAsFixed(1)}%',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: Colors.green.shade400,
                                  value: porcentajeSinRiesgo,
                                  title:
                                      '${porcentajeSinRiesgo.toStringAsFixed(1)}%',
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
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIndicator(
                            color: Colors.red.shade400,
                            text: 'Con Riesgo: ${estadisticas['conRiesgo']}',
                          ),
                          const SizedBox(height: 8),
                          _buildIndicator(
                            color: Colors.green.shade400,
                            text: 'Sin Riesgo: ${estadisticas['sinRiesgo']}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      const SizedBox(height: 16),
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
        style: const TextStyle(fontSize: 14),
      ),
    ],
  );
}
