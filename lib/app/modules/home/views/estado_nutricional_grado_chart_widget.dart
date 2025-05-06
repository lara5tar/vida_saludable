import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget estadoNutricionalGradoChartWidget(
    Map<String, Map<String, int>> estadisticasPorGrado) {
  // Si no hay datos, mostrar un mensaje
  if (estadisticasPorGrado.isEmpty ||
      !estadisticasPorGrado.containsKey('1') ||
      !estadisticasPorGrado.containsKey('2') ||
      !estadisticasPorGrado.containsKey('3')) {
    return const Center(
      child: Text(
        'No hay datos suficientes para mostrar estadísticas de estado nutricional por grado',
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
  String getNombreGrado(String grado) {
    if (grado == '1') return '1° Grado';
    if (grado == '2') return '2° Grado';
    if (grado == '3') return '3° Grado';
    return grado;
  }

  // Calcular totales por grado para los porcentajes
  final totalesPorGrado = {
    '1': 0,
    '2': 0,
    '3': 0,
  };

  for (var grado in ['1', '2', '3']) {
    final datos = estadisticasPorGrado[grado]!;
    for (var categoria in [
      'bajoPeso',
      'normal',
      'sobrepeso',
      'obesidad',
      'sinDatos'
    ]) {
      totalesPorGrado[grado] =
          totalesPorGrado[grado]! + (datos[categoria] ?? 0);
    }
  }

  // Calcular porcentajes por categoría y grado
  final porcentajesPorGrado = <String, Map<String, double>>{
    '1': {},
    '2': {},
    '3': {},
  };

  for (var grado in ['1', '2', '3']) {
    final datos = estadisticasPorGrado[grado]!;
    final total = totalesPorGrado[grado]!;

    if (total > 0) {
      for (var categoria in [
        'bajoPeso',
        'normal',
        'sobrepeso',
        'obesidad',
        'sinDatos'
      ]) {
        porcentajesPorGrado[grado]![categoria] =
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
        porcentajesPorGrado[grado]![categoria] = 0.0;
      }
    }
  }

  // Calcula cuántas barras tendremos en total (5 categorías x 3 grados = 15 barras)
  const totalBarras = 15;

  // Función para calcular el índice x de cada barra en la gráfica
  int calcularIndiceX(String grado, String categoria) {
    final indiceGrado = int.parse(grado) - 1; // 0 para 1°, 1 para 2°, 2 para 3°
    final indiceCategoria = [
      'bajoPeso',
      'normal',
      'sobrepeso',
      'obesidad',
      'sinDatos'
    ].indexOf(categoria);
    return indiceGrado * 5 + indiceCategoria; // 5 categorías por grado
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Estado Nutricional por Grado Escolar',
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
                        // Determinar grado y categoría según el índice de la barra
                        final indiceGrado = group.x ~/
                            5; // División entera para obtener 0, 1 o 2
                        final indiceCategoria =
                            group.x % 5; // Resto para obtener 0, 1, 2, 3 o 4

                        final grado = ['1', '2', '3'][indiceGrado];
                        final categoria = [
                          'bajoPeso',
                          'normal',
                          'sobrepeso',
                          'obesidad',
                          'sinDatos'
                        ][indiceCategoria];

                        final double porcentaje =
                            porcentajesPorGrado[grado]![categoria]!;
                        final int cantidad =
                            estadisticasPorGrado[grado]![categoria] ?? 0;

                        return BarTooltipItem(
                          '${getNombreGrado(grado)}\n${nombresEstados[categoria]}\n$cantidad (${porcentaje.toStringAsFixed(1)}%)',
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
                        reservedSize: 50,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final int indice = value.toInt();
                          final int indiceGrado = indice ~/ 5;
                          final int indiceCategoria = indice % 5;

                          // Solo mostrar etiquetas para la primera categoría de cada grado
                          if (indiceCategoria == 0) {
                            final grado = ['1', '2', '3'][indiceGrado];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                getNombreGrado(grado),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else if (indice == 7) {
                            // Posición central para explicación
                            return const Padding(
                              padding: EdgeInsets.only(top: 30.0),
                              child: Text(
                                'Estado Nutricional por Grado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox();
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
                  // Generar barras para todas las categorías y grados
                  barGroups: List.generate(totalBarras, (index) {
                    final indiceGrado = index ~/ 5;
                    final indiceCategoria = index % 5;

                    final grado = ['1', '2', '3'][indiceGrado];
                    final categoria = [
                      'bajoPeso',
                      'normal',
                      'sobrepeso',
                      'obesidad',
                      'sinDatos'
                    ][indiceCategoria];

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: porcentajesPorGrado[grado]![categoria]!,
                          color: colores[categoria],
                          width: 12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    );
                  }),
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

        // Tablas de resumen mejoradas
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20.0,
          runSpacing: 30.0,
          children: [
            for (var grado in ['1', '2', '3'])
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      'Resumen ${getNombreGrado(grado)}:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _buildNuevoEstiloTabla(
                    grado,
                    estadisticasPorGrado,
                    porcentajesPorGrado,
                    totalesPorGrado,
                    colores,
                    nombresEstados,
                  ),
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
  String grado,
  Map<String, Map<String, int>> estadisticasPorGrado,
  Map<String, Map<String, double>> porcentajesPorGrado,
  Map<String, int> totalesPorGrado,
  Map<String, Color> colores,
  Map<String, String> nombresEstados,
) {
  // Lista de categorías en el orden de visualización
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
                  '${estadisticasPorGrado[grado]![categoria]} (${porcentajesPorGrado[grado]![categoria]!.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: colores[categoria]!.withOpacity(0.8),
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
                '${totalesPorGrado[grado]} (100%)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
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
