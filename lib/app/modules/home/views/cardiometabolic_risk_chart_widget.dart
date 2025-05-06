import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget cardiometabolicRiskChartWidget(Map<String, int> estadisticas) {
  final total = estadisticas['conRiesgo']! + estadisticas['sinRiesgo']!;

  // Si no hay datos, mostrar un mensaje
  if (total == 0) {
    return const Center(
      child: Text(
        'No hay datos suficientes para mostrar estadísticas de riesgo cardiometabólico',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  final porcentajeConRiesgo = (estadisticas['conRiesgo']! / total) * 100;
  final porcentajeSinRiesgo = (estadisticas['sinRiesgo']! / total) * 100;

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Estadísticas de Riesgo Cardiometabólico',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            _buildIndicator(
              color: Colors.red.shade400,
              text: 'Con Riesgo (${estadisticas['conRiesgo']})',
            ),
            _grafica(porcentajeConRiesgo, porcentajeSinRiesgo),
            _buildIndicator(
              color: Colors.green.shade400,
              text: 'Sin Riesgo (${estadisticas['sinRiesgo']})',
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Tabla de datos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.all(color: Colors.grey.shade300),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.red.shade400.withOpacity(0.1),
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
                              color: Colors.red.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Con Riesgo',
                              style: TextStyle(
                                color: Colors.red.shade700,
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
                        '${estadisticas['conRiesgo']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        '${porcentajeConRiesgo.toStringAsFixed(1)}%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.green.shade400.withOpacity(0.1),
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
                              color: Colors.green.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sin Riesgo',
                              style: TextStyle(
                                color: Colors.green.shade700,
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
                        '${estadisticas['sinRiesgo']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        '${porcentajeSinRiesgo.toStringAsFixed(1)}%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
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
                        '$total',
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
        ),

        const SizedBox(height: 30),
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   decoration: BoxDecoration(
        //     color: Colors.grey.shade100,
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       const Text(
        //         'Factores de riesgo cardiometabólico:',
        //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        //       ),
        //       const SizedBox(height: 8),
        //       _buildFactorItem('IMC elevado (≥ 25)'),
        //       _buildFactorItem('Presión arterial alta (≥ 130/85 mmHg)'),
        //       _buildFactorItem('Glucosa en ayunas elevada (≥ 100 mg/dL)'),
        //       _buildFactorItem(
        //           'Perímetro de cintura elevado (≥ 102 cm en hombres, ≥ 88 cm en mujeres)'),
        //     ],
        //   ),
        // ),
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

SizedBox _grafica(double porcentajeConRiesgo, double porcentajeSinRiesgo) {
  return SizedBox(
    height: 200,
    width: 300,
    child: PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Colors.red.shade400,
            value: porcentajeConRiesgo,
            title: '${porcentajeConRiesgo.toStringAsFixed(1)}%',
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
            title: '${porcentajeSinRiesgo.toStringAsFixed(1)}%',
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
