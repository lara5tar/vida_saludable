import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget estadoNutricionalSexoChartWidget(
    Map<String, Map<String, int>> estadisticasPorSexo) {
  // Si no hay datos, mostrar un mensaje
  if (estadisticasPorSexo.isEmpty ||
      !estadisticasPorSexo.containsKey('masculino') ||
      !estadisticasPorSexo.containsKey('femenino')) {
    return const Center(
      child: Text(
        'No hay datos suficientes para mostrar estadísticas de estado nutricional por sexo',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Colores para cada categoría de estado nutricional
  final colores = {
    'bajoPeso': Colors.blue.shade400,
    'normal': Colors.green.shade400,
    'sobrepeso': Colors.orange.shade400,
    'obesidad': Colors.red.shade400,
    'sinDatos': Colors.grey.shade400,
  };

  // Nombres descriptivos para las categorías
  final nombresEstados = {
    'bajoPeso': 'Bajo Peso',
    'normal': 'Peso Normal',
    'sobrepeso': 'Sobrepeso',
    'obesidad': 'Obesidad',
    'sinDatos': 'Sin Datos',
  };

  // Para mostrar nombre más presentable en la gráfica
  String getNombreSexo(String sexo) {
    if (sexo == 'masculino') return 'Hombres';
    if (sexo == 'femenino') return 'Mujeres';
    return sexo;
  }

  // Calcular totales por sexo para los porcentajes
  final totalesPorSexo = {
    'masculino': 0,
    'femenino': 0,
  };

  for (var sexo in ['masculino', 'femenino']) {
    final datos = estadisticasPorSexo[sexo]!;
    for (var categoria in [
      'bajoPeso',
      'normal',
      'sobrepeso',
      'obesidad',
      'sinDatos'
    ]) {
      totalesPorSexo[sexo] = totalesPorSexo[sexo]! + (datos[categoria] ?? 0);
    }
  }

  // Calcular porcentajes por categoría y sexo
  final porcentajesPorSexo = <String, Map<String, double>>{
    'masculino': {},
    'femenino': {},
  };

  for (var sexo in ['masculino', 'femenino']) {
    final datos = estadisticasPorSexo[sexo]!;
    final total = totalesPorSexo[sexo]!;

    if (total > 0) {
      for (var categoria in [
        'bajoPeso',
        'normal',
        'sobrepeso',
        'obesidad',
        'sinDatos'
      ]) {
        porcentajesPorSexo[sexo]![categoria] =
            (datos[categoria] ?? 0) / total * 100;
      }
    } else {
      for (var categoria in [
        'bajoPeso',
        'normal',
        'sobrepeso',
        'obesidad',
        'sinDatos'
      ]) {
        porcentajesPorSexo[sexo]![categoria] = 0.0;
      }
    }
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Estado Nutricional por Sexo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 20),

        // Contenedor de la gráfica
        LayoutBuilder(
          builder: (context, constraints) {
            // Asegurarse de que el ancho sea definido
            final chartWidth =
                constraints.maxWidth > 0 ? constraints.maxWidth : 300.0;

            return Container(
              height: 400,
              width: chartWidth,
              padding: const EdgeInsets.all(8),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: 100, // Escala fija para porcentajes (0-100%)
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        // Determinar sexo y categoría según el índice de la barra
                        String sexo = group.x < 5 ? 'masculino' : 'femenino';
                        String categoria = '';

                        // Determinar categoría según el índice en cada grupo
                        switch (group.x % 5) {
                          case 0:
                            categoria = 'bajoPeso';
                            break;
                          case 1:
                            categoria = 'normal';
                            break;
                          case 2:
                            categoria = 'sobrepeso';
                            break;
                          case 3:
                            categoria = 'obesidad';
                            break;
                          case 4:
                            categoria = 'sinDatos';
                            break;
                        }

                        double porcentaje =
                            porcentajesPorSexo[sexo]![categoria]!;
                        int cantidad =
                            estadisticasPorSexo[sexo]![categoria] ?? 0;

                        return BarTooltipItem(
                          '${getNombreSexo(sexo)}\n${nombresEstados[categoria]}\n$cantidad (${porcentaje.toStringAsFixed(1)}%)',
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
                        reservedSize: 40,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          String texto = '';
                          Color? color;

                          // Definir etiquetas para cada barra
                          switch (value.toInt()) {
                            case 0:
                              texto = 'Bajo Peso (H)';
                              color = colores['bajoPeso'];
                              break;
                            case 1:
                              texto = 'Normal (H)';
                              color = colores['normal'];
                              break;
                            case 2:
                              texto = 'Sobrepeso (H)';
                              color = colores['sobrepeso'];
                              break;
                            case 3:
                              texto = 'Obesidad (H)';
                              color = colores['obesidad'];
                              break;
                            case 4:
                              texto = 'Sin Datos (H)';
                              color = colores['sinDatos'];
                              break;
                            case 5:
                              texto = 'Bajo Peso (M)';
                              color = colores['bajoPeso'];
                              break;
                            case 6:
                              texto = 'Normal (M)';
                              color = colores['normal'];
                              break;
                            case 7:
                              texto = 'Sobrepeso (M)';
                              color = colores['sobrepeso'];
                              break;
                            case 8:
                              texto = 'Obesidad (M)';
                              color = colores['obesidad'];
                              break;
                            case 9:
                              texto = 'Sin Datos (M)';
                              color = colores['sinDatos'];
                              break;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              width: 60,
                              child: Text(
                                texto,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                maxLines: 2,
                              ),
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
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
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
                  // Generar barras por categoría y sexo
                  barGroups: [
                    // HOMBRES
                    // Bajo peso
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['masculino']!['bajoPeso']!,
                          color: colores['bajoPeso'],
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Normal
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['masculino']!['normal']!,
                          color: colores['normal'],
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Sobrepeso
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['masculino']!['sobrepeso']!,
                          color: colores['sobrepeso'],
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Obesidad
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['masculino']!['obesidad']!,
                          color: colores['obesidad'],
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Sin datos
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['masculino']!['sinDatos']!,
                          color: colores['sinDatos'],
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),

                    // MUJERES
                    // Bajo peso
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['femenino']!['bajoPeso']!,
                          color: colores['bajoPeso'],
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Normal
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['femenino']!['normal']!,
                          color: colores['normal'],
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Sobrepeso
                    BarChartGroupData(
                      x: 7,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['femenino']!['sobrepeso']!,
                          color: colores['sobrepeso'],
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Obesidad
                    BarChartGroupData(
                      x: 8,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['femenino']!['obesidad']!,
                          color: colores['obesidad'],
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    // Sin datos
                    BarChartGroupData(
                      x: 9,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorSexo['femenino']!['sinDatos']!,
                          color: colores['sinDatos'],
                          width: 15,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 30),

        // Leyenda
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16.0,
            runSpacing: 8.0,
            children: [
              _buildIndicador(
                color: colores['bajoPeso']!,
                texto: nombresEstados['bajoPeso']!,
              ),
              _buildIndicador(
                color: colores['normal']!,
                texto: nombresEstados['normal']!,
              ),
              _buildIndicador(
                color: colores['sobrepeso']!,
                texto: nombresEstados['sobrepeso']!,
              ),
              _buildIndicador(
                color: colores['obesidad']!,
                texto: nombresEstados['obesidad']!,
              ),
              _buildIndicador(
                color: colores['sinDatos']!,
                texto: nombresEstados['sinDatos']!,
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Tablas de resumen mejoradas según la imagen proporcionada
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20.0,
          runSpacing: 30.0,
          children: [
            // Tabla para Hombres
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Resumen Hombres:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildNuevoEstiloTabla(
                    'masculino',
                    estadisticasPorSexo,
                    porcentajesPorSexo,
                    totalesPorSexo,
                    colores,
                    nombresEstados),
              ],
            ),

            // Tabla para Mujeres
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Resumen Mujeres:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildNuevoEstiloTabla(
                    'femenino',
                    estadisticasPorSexo,
                    porcentajesPorSexo,
                    totalesPorSexo,
                    colores,
                    nombresEstados),
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),
      ],
    ),
  );
}

// Nueva función para construir las tablas con el estilo mejorado
Widget _buildNuevoEstiloTabla(
  String sexo,
  Map<String, Map<String, int>> estadisticasPorSexo,
  Map<String, Map<String, double>> porcentajesPorSexo,
  Map<String, int> totalesPorSexo,
  Map<String, Color> colores,
  Map<String, String> nombresEstados,
) {
  // Lista de categorías ordenadas como en la imagen
  final categorias = [
    'bajoPeso',
    'normal',
    'sobrepeso',
    'obesidad',
    'sinDatos'
  ];

  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey.shade300),
        verticalInside: BorderSide(color: Colors.grey.shade300),
      ),
      children: [
        // Encabezados de la tabla
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
          children: [
            for (var categoria in categorias)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 12.0),
                child: Text(
                  nombresEstados[categoria]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              child: Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),

        // Fila con valores y porcentajes
        TableRow(
          children: [
            for (var categoria in categorias)
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 12.0),
                color: colores[categoria]!.withOpacity(0.1),
                child: Text(
                  '${estadisticasPorSexo[sexo]![categoria]} (${porcentajesPorSexo[sexo]![categoria]!.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: sexo == 'masculino'
                        ? Colors.blue.shade800
                        : Colors.pink.shade800,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              color: Colors.grey.shade50,
              child: Text(
                '${totalesPorSexo[sexo]} (100%)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: sexo == 'masculino'
                      ? Colors.blue.shade800
                      : Colors.pink.shade800,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFactorItem(String text, [Color? color]) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 16)),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
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
