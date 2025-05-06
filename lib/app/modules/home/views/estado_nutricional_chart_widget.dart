import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget estadoNutricionalChartWidget(Map<String, int> estadisticas) {
  // Calcular el total (excluyendo 'sinDatos' para porcentajes más precisos)
  final totalConDatos = estadisticas['bajoPeso']! +
      estadisticas['normal']! +
      estadisticas['sobrepeso']! +
      estadisticas['obesidad']!;

  final totalGeneral = totalConDatos + estadisticas['sinDatos']!;

  // Si no hay datos con IMC, mostrar un mensaje
  if (totalConDatos == 0) {
    return const Center(
      child: Text(
        'No hay datos suficientes para mostrar estadísticas de estado nutricional',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Calcular porcentajes (sobre el total con datos)
  final porcentajeBajoPeso = (estadisticas['bajoPeso']! / totalConDatos) * 100;
  final porcentajeNormal = (estadisticas['normal']! / totalConDatos) * 100;
  final porcentajeSobrepeso =
      (estadisticas['sobrepeso']! / totalConDatos) * 100;
  final porcentajeObesidad = (estadisticas['obesidad']! / totalConDatos) * 100;

  // Porcentaje de datos faltantes sobre el total general (para información)
  final porcentajeSinDatos =
      totalGeneral > 0 ? (estadisticas['sinDatos']! / totalGeneral) * 100 : 0;

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Estado Nutricional',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Usar un LayoutBuilder para garantizar que Row tenga restricciones definidas
        LayoutBuilder(builder: (context, constraints) {
          // Si la pantalla es estrecha, apilar los elementos verticalmente
          if (constraints.maxWidth < 600) {
            return Column(
              children: [
                // Gráfica
                SizedBox(
                  height: 300,
                  width: constraints.maxWidth,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.blue.shade300,
                          value: estadisticas['bajoPeso']!.toDouble(),
                          title: '${porcentajeBajoPeso.toStringAsFixed(1)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.green.shade400,
                          value: estadisticas['normal']!.toDouble(),
                          title: '${porcentajeNormal.toStringAsFixed(1)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.orange.shade400,
                          value: estadisticas['sobrepeso']!.toDouble(),
                          title: '${porcentajeSobrepeso.toStringAsFixed(1)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.red.shade400,
                          value: estadisticas['obesidad']!.toDouble(),
                          title: '${porcentajeObesidad.toStringAsFixed(1)}%',
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
                // Leyenda
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator(
                        color: Colors.blue.shade300,
                        text: 'Bajo peso',
                        count: estadisticas['bajoPeso']!,
                        percentage: porcentajeBajoPeso,
                      ),
                      const SizedBox(height: 12),
                      _buildIndicator(
                        color: Colors.green.shade400,
                        text: 'Normal',
                        count: estadisticas['normal']!,
                        percentage: porcentajeNormal,
                      ),
                      const SizedBox(height: 12),
                      _buildIndicator(
                        color: Colors.orange.shade400,
                        text: 'Sobrepeso',
                        count: estadisticas['sobrepeso']!,
                        percentage: porcentajeSobrepeso,
                      ),
                      const SizedBox(height: 12),
                      _buildIndicator(
                        color: Colors.red.shade400,
                        text: 'Obesidad',
                        count: estadisticas['obesidad']!,
                        percentage: porcentajeObesidad,
                      ),
                      if (estadisticas['sinDatos']! > 0) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Sin datos de IMC: ${estadisticas['sinDatos']} (${porcentajeSinDatos.toStringAsFixed(1)}% del total)',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          } else {
            // En pantallas anchas, mostrar elementos en fila horizontal
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gráfica
                SizedBox(
                  height: 300,
                  width: constraints.maxWidth * 0.6,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.blue.shade300,
                          value: estadisticas['bajoPeso']!.toDouble(),
                          title: '${porcentajeBajoPeso.toStringAsFixed(1)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.green.shade400,
                          value: estadisticas['normal']!.toDouble(),
                          title: '${porcentajeNormal.toStringAsFixed(1)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.orange.shade400,
                          value: estadisticas['sobrepeso']!.toDouble(),
                          title: '${porcentajeSobrepeso.toStringAsFixed(1)}%',
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.red.shade400,
                          value: estadisticas['obesidad']!.toDouble(),
                          title: '${porcentajeObesidad.toStringAsFixed(1)}%',
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
                // Leyenda
                Container(
                  width: constraints.maxWidth * 0.4,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIndicator(
                        color: Colors.blue.shade300,
                        text: 'Bajo peso',
                        count: estadisticas['bajoPeso']!,
                        percentage: porcentajeBajoPeso,
                      ),
                      const SizedBox(height: 12),
                      _buildIndicator(
                        color: Colors.green.shade400,
                        text: 'Normal',
                        count: estadisticas['normal']!,
                        percentage: porcentajeNormal,
                      ),
                      const SizedBox(height: 12),
                      _buildIndicator(
                        color: Colors.orange.shade400,
                        text: 'Sobrepeso',
                        count: estadisticas['sobrepeso']!,
                        percentage: porcentajeSobrepeso,
                      ),
                      const SizedBox(height: 12),
                      _buildIndicator(
                        color: Colors.red.shade400,
                        text: 'Obesidad',
                        count: estadisticas['obesidad']!,
                        percentage: porcentajeObesidad,
                      ),
                      if (estadisticas['sinDatos']! > 0) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Sin datos de IMC: ${estadisticas['sinDatos']} (${porcentajeSinDatos.toStringAsFixed(1)}% del total)',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }
        }),
        const SizedBox(height: 30),
        // Tabla de resumen
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text(
                //   'Clasificación del estado nutricional según IMC:',
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 16),
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(
                        color: Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Clasificación',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Rango IMC',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Cantidad',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            'Porcentaje',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    _buildTableRow(
                      'Bajo Peso',
                      '< 18.5',
                      Colors.blue.shade400,
                      estadisticas['bajoPeso'] ?? 0,
                      porcentajeBajoPeso,
                    ),
                    _buildTableRow(
                      'Peso Normal',
                      '≥ 18.5 y < 25',
                      Colors.green.shade400,
                      estadisticas['normal'] ?? 0,
                      porcentajeNormal,
                    ),
                    _buildTableRow(
                      'Sobrepeso',
                      '≥ 25 y < 30',
                      Colors.orange.shade400,
                      estadisticas['sobrepeso'] ?? 0,
                      porcentajeSobrepeso,
                    ),
                    _buildTableRow(
                      'Obesidad',
                      '≥ 30.0',
                      Colors.red.shade400,
                      estadisticas['obesidad'] ?? 0,
                      porcentajeObesidad,
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
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            '',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            totalConDatos.toString(),
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
                const SizedBox(height: 12),
                const Text(
                  'Fuente: Organización Mundial de la Salud (OMS)',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

TableRow _buildTableRow(String clasificacion, String rangoImc, Color color,
    int cantidad, double porcentaje) {
  return TableRow(
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
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
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                clasificacion,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          rangoImc,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color.withOpacity(0.8),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          cantidad.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.8),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          '${porcentaje.toStringAsFixed(1)}%',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: color.withOpacity(0.8),
          ),
        ),
      ),
    ],
  );
}

Widget _buildIndicator({
  required Color color,
  required String text,
  required int count,
  required double percentage,
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
      Flexible(
        child: Text(
          '$text: $count (${percentage.toStringAsFixed(1)}%)',
          style: const TextStyle(fontSize: 14),
        ),
      ),
    ],
  );
}
