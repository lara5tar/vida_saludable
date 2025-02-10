import 'package:flutter/material.dart';
import 'package:vida_saludable/app/widgets/custom_card.dart';

Widget dashboardWidget(String numPersonas, Map totales) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 600;
      final cardWidth = constraints.maxWidth > 900
          ? constraints.maxWidth / 3 - 20 // 3 cards in a row
          : constraints.maxWidth > 600
              ? constraints.maxWidth / 2 - 20 // 2 cards in a row
              : constraints.maxWidth - 20; // 1 card in a row

      if (isSmallScreen) {
        // Vista compacta para móviles
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompactStat(
                  Icons.emoji_people_rounded, numPersonas, 'Total'),
              _buildCompactStat(Icons.woman, totales['mujeres'], 'M'),
              _buildCompactStat(Icons.man, totales['hombres'], 'H'),
            ],
          ),
        );
      }

      // Vista expandida para pantallas más grandes
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 20,
        children: [
          SizedBox(
            width: cardWidth,
            child: CustomCard(
              title: 'Total de Personas',
              icon: Icons.emoji_people_rounded,
              value: numPersonas,
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: CustomCard(
              title: 'Total de Mujeres',
              icon: Icons.woman,
              value: totales['mujeres'],
            ),
          ),
          SizedBox(
            width: cardWidth,
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
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 20, color: Colors.green.shade700),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade700,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.green.shade700,
        ),
      ),
    ],
  );
}
