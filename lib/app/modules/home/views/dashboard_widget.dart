import 'package:flutter/material.dart';
import 'package:vida_saludable/app/widgets/custom_card.dart';

Widget dashboardWidget(String numPersonas, Map totales) {
  return Wrap(
    alignment: WrapAlignment.center,
    spacing: 20,
    runSpacing: 20,
    children: [
      CustomCard(
        title: 'Total de Personas',
        icon: Icons.emoji_people_rounded,
        value: numPersonas,
      ),
      CustomCard(
        title: 'Total de Mujeres',
        icon: Icons.woman,
        value: totales['mujeres'],
      ),
      CustomCard(
        title: 'Total de Hombres',
        icon: Icons.man,
        value: totales['hombres'],
      ),
    ],
  );
}
