import 'package:flutter/material.dart';
import 'package:vida_saludable/app/widgets/custom_card.dart';

Widget dashboardWidget(String numPersonas, Map totales) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 600;

      if (isSmallScreen) {
        // Vista compacta para móviles
        return Container(
          // padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompactStat(Icons.diversity_3, numPersonas, 'Total'),
              _buildCompactStat(Icons.woman, totales['mujeres'], 'M'),
              _buildCompactStat(Icons.man, totales['hombres'], 'H'),
            ],
          ),
        );
      }

      // Vista expandida para pantallas más grandes
      return Row(
        spacing: 20,
        children: [
          Expanded(
            child: CustomCard(
              title: 'Total de Personas',
              icon: Icons.diversity_3,
              value: numPersonas,
            ),
          ),
          Expanded(
            child: CustomCard(
              title: 'Total de Mujeres',
              icon: Icons.woman,
              value: totales['mujeres'],
            ),
          ),
          Expanded(
            child: CustomCard(
              title: 'Total de Hombres',
              icon: Icons.man,
              value: totales['hombres'],
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildCompactStat(IconData icon, String value, String label) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade900,
          ),
        ),
      ],
    ),
  );
}
