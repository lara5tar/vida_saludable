import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/estadisticas_controller.dart';

class EstadisticasView extends GetView<EstadisticasController> {
  const EstadisticasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Riesgos Cardiometabólicos'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título para la sección
              Text(
                'Análisis de Riesgos Cardiometabólicos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta sección muestra estadísticas detalladas sobre los riesgos cardiometabólicos de los estudiantes.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // 1. Gráfica General
              _buildSectionTitle('Distribución General de Riesgos'),
              const SizedBox(height: 8),
              _buildGeneralRiskChart(),
              const SizedBox(height: 24),

              // 2. Gráfica por Grado Escolar
              _buildSectionTitle('Riesgos por Grado Escolar'),
              const SizedBox(height: 8),
              _buildGradeLevelChart(),
              const SizedBox(height: 24),

              // 3. Gráfica por Sexo
              _buildSectionTitle('Riesgos por Sexo'),
              const SizedBox(height: 8),
              _buildGenderChart(),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  // Widget para títulos de sección
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.green.shade700,
      ),
    );
  }

  // 1. Gráfica General de Riesgos (Pie Chart)
  Widget _buildGeneralRiskChart() {
    final int conRiesgo = controller.datosGenerales.value['conRiesgo'] ?? 0;
    final int sinRiesgo = controller.datosGenerales.value['sinRiesgo'] ?? 0;
    final int total = controller.datosGenerales.value['total'] ?? 0;

    // Si no hay datos, mostrar mensaje
    if (total == 0) {
      return _buildNoDataCard();
    }

    // Calcular porcentajes
    final double porcentajeConRiesgo =
        controller.calcularPorcentaje(conRiesgo, total);
    final double porcentajeSinRiesgo =
        controller.calcularPorcentaje(sinRiesgo, total);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Gráfica de Pastel
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: conRiesgo.toDouble(),
                      title: '${porcentajeConRiesgo.toStringAsFixed(1)}%',
                      color: Colors.red,
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: sinRiesgo.toDouble(),
                      title: '${porcentajeSinRiesgo.toStringAsFixed(1)}%',
                      color: Colors.green,
                      radius: 100,
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

            const SizedBox(height: 16),

            // Leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Con Riesgo', Colors.red),
                const SizedBox(width: 20),
                _buildLegendItem('Sin Riesgo', Colors.green),
              ],
            ),

            const SizedBox(height: 16),

            // Detalles numéricos
            Text(
              'Total de estudiantes: $total',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
                'Con riesgo: $conRiesgo (${porcentajeConRiesgo.toStringAsFixed(1)}%)'),
            const SizedBox(height: 4),
            Text(
                'Sin riesgo: $sinRiesgo (${porcentajeSinRiesgo.toStringAsFixed(1)}%)'),
          ],
        ),
      ),
    );
  }

  // 2. Gráficas por Grado Escolar
  Widget _buildGradeLevelChart() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Si no hay datos por grado
            if (controller.datosPorGrado.isEmpty)
              _buildNoDataCard()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gráficas para cada grado
                  ...controller.datosPorGrado.map((gradoData) {
                    final String grado = gradoData['grado'] ?? '';
                    final int conRiesgo = gradoData['conRiesgo'] ?? 0;
                    final int sinRiesgo = gradoData['sinRiesgo'] ?? 0;
                    final int total = gradoData['total'] ?? 0;

                    if (total == 0) return Container();

                    // Calcular porcentajes
                    final double porcentajeConRiesgo =
                        controller.calcularPorcentaje(conRiesgo, total);
                    final double porcentajeSinRiesgo =
                        controller.calcularPorcentaje(sinRiesgo, total);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 8.0, top: 16.0),
                          child: Text(
                            'Grado: $grado° (Total: $total estudiantes)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        // Gráfica de barras horizontal
                        SizedBox(
                          height: 80,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.center,
                              maxY: 100,
                              minY: 0,
                              groupsSpace: 12,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      String text = '';
                                      if (value == 0) {
                                        text = 'Con Riesgo';
                                      } else if (value == 1) {
                                        text = 'Sin Riesgo';
                                      }
                                      return Text(text,
                                          style: const TextStyle(fontSize: 12));
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      if (value % 25 == 0) {
                                        return Text('${value.toInt()}%',
                                            style:
                                                const TextStyle(fontSize: 12));
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 25,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: porcentajeConRiesgo,
                                      color: Colors.red,
                                      width: 20,
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: porcentajeSinRiesgo,
                                      color: Colors.green,
                                      width: 20,
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Detalles numéricos
                        const SizedBox(height: 8),
                        Text(
                            'Con riesgo: $conRiesgo (${porcentajeConRiesgo.toStringAsFixed(1)}%)'),
                        const SizedBox(height: 4),
                        Text(
                            'Sin riesgo: $sinRiesgo (${porcentajeSinRiesgo.toStringAsFixed(1)}%)'),

                        if (grado != controller.datosPorGrado.last['grado'])
                          const Divider(height: 30),
                      ],
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // 3. Gráficas por Sexo
  Widget _buildGenderChart() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Si no hay datos por sexo
            if (controller.datosPorSexo.isEmpty)
              _buildNoDataCard()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gráficas para cada sexo
                  ...controller.datosPorSexo.map((sexoData) {
                    final String sexo = sexoData['sexo'] ?? '';
                    final int conRiesgo = sexoData['conRiesgo'] ?? 0;
                    final int sinRiesgo = sexoData['sinRiesgo'] ?? 0;
                    final int total = sexoData['total'] ?? 0;

                    if (total == 0) return Container();

                    // Calcular porcentajes
                    final double porcentajeConRiesgo =
                        controller.calcularPorcentaje(conRiesgo, total);
                    final double porcentajeSinRiesgo =
                        controller.calcularPorcentaje(sinRiesgo, total);

                    // Definir color según sexo
                    final Color colorSexo =
                        sexo == 'Hombre' ? Colors.blue : Colors.pink;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 8.0, top: 16.0),
                          child: Row(
                            children: [
                              Icon(
                                sexo == 'Hombre' ? Icons.male : Icons.female,
                                color: colorSexo,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$sexo (Total: $total estudiantes)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Gráfica de tipo donut chart
                        SizedBox(
                          height: 180,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              sections: [
                                PieChartSectionData(
                                  value: conRiesgo.toDouble(),
                                  title:
                                      '${porcentajeConRiesgo.toStringAsFixed(1)}%',
                                  color: Colors.red,
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                PieChartSectionData(
                                  value: sinRiesgo.toDouble(),
                                  title:
                                      '${porcentajeSinRiesgo.toStringAsFixed(1)}%',
                                  color: Colors.green,
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Leyenda
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem('Con Riesgo', Colors.red),
                            const SizedBox(width: 20),
                            _buildLegendItem('Sin Riesgo', Colors.green),
                          ],
                        ),

                        // Detalles numéricos
                        const SizedBox(height: 8),
                        Text(
                            'Con riesgo: $conRiesgo (${porcentajeConRiesgo.toStringAsFixed(1)}%)'),
                        const SizedBox(height: 4),
                        Text(
                            'Sin riesgo: $sinRiesgo (${porcentajeSinRiesgo.toStringAsFixed(1)}%)'),

                        if (sexo != controller.datosPorSexo.last['sexo'])
                          const Divider(height: 30),
                      ],
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Widget para leyenda de gráficos
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  // Widget para mostrar cuando no hay datos
  Widget _buildNoDataCard() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No hay datos disponibles',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
