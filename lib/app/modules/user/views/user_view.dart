import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_scaffold.dart';
import '../controllers/user_controller.dart';
import '../../../data/services/habitos_alimenticios_service.dart';
import '../../../data/services/actividad_fisica_service.dart';
import '../../../data/services/personalidad_service.dart';

class UserView extends GetView<UserController> {
  const UserView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.getUser(Get.parameters['id'] ?? '');
    return CustomScaffold(
      body: Obx(() {
        if (controller.user.isEmpty) {
          return const Center(child: Text('No hay datos disponibles'));
        }

        return ListView(
          padding: const EdgeInsets.all(40),
          children: [
            // Datos básicos
            _buildBasicInfoCard(controller.user),
            const SizedBox(height: 20),
            // Nueva tarjeta de índices
            _buildIndicesCard(controller.user),
            const SizedBox(height: 20),
            // Hábitos alimenticios
            _buildEvaluationCard(
              title: 'Evaluación de Hábitos Alimenticios (Preguntas 1-26)',
              evaluation: HabitosAlimenticiosService.evaluar(controller.user),
              color: HabitosAlimenticiosService.getColor(controller.user),
              items: List.generate(26, (index) {
                final pregunta = 'pr${index + 1}';
                return '${index + 1}: ${controller.user[pregunta] ?? "N/A"}';
              }),
            ),
            const SizedBox(height: 20),
            // Actividad física
            _buildEvaluationCard(
              title: 'Evaluación de Actividad Física (Preguntas 27-36)',
              evaluation: ActividadFisicaService.evaluar(controller.user),
              color: ActividadFisicaService.getColor(controller.user),
              items: List.generate(10, (index) {
                final pregunta = 'pr${index + 27}';
                return '${index + 27}: ${controller.user[pregunta] ?? "N/A"}';
              }),
            ),
            const SizedBox(height: 20),
            _buildPersonalityCard(controller.user),
            const SizedBox(height: 20),
            // Resto de la información del usuario
            // ...existing user details...
          ],
        );
      }),
    );
  }

  Widget _buildBasicInfoCard(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Personal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 40,
            runSpacing: 16,
            children: [
              _buildInfoItem('Nombre', user['name'] ?? 'N/A'),
              _buildInfoItem('Edad', '${user['age'] ?? 'N/A'} años'),
              _buildInfoItem('Género', user['gender'] ?? 'N/A'),
              _buildInfoItem('Ciudad', user['municipio'] ?? 'N/A'),
              _buildInfoItem('Escuela', user['nombre_escuela'] ?? 'N/A'),
              _buildInfoItem(
                  'Nivel Educativo', user['nivel_educativo'] ?? 'N/A'),
              _buildInfoItem('Peso', '${user['peso'] ?? 'N/A'} kg'),
              _buildInfoItem('Estatura', '${user['estatura'] ?? 'N/A'} m'),
              _buildInfoItem('Cintura', '${user['cintura'] ?? 'N/A'} cm'),
              _buildInfoItem('Cadera', '${user['cadera'] ?? 'N/A'} cm'),
              if (user['enfermedades'] != null && user['enfermedades'] != 'No')
                _buildInfoItem('Enfermedades', user['enfermedades']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard({
    required String title,
    required String evaluation,
    required String color,
    required List<String> items,
  }) {
    final esSaludable = evaluation.toLowerCase().contains('saludable') ||
        evaluation.toLowerCase().contains('activo');
    final esAdvertencia = color == 'yellow' ||
        evaluation.toLowerCase().contains('semi-activo') ||
        evaluation.toLowerCase().contains('suficientes');

    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.grey.shade200,
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  esSaludable
                      ? Icons.check_circle
                      : esAdvertencia
                          ? Icons.warning_amber_rounded
                          : Icons.dangerous,
                  color: color == 'red'
                      ? Colors.red
                      : color == 'yellow'
                          ? Colors.orange
                          : Colors.green,
                  size: 40, // Actualizado a 40
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    evaluation,
                    style: TextStyle(
                      fontSize: 16,
                      color: color == 'red'
                          ? Colors.red
                          : color == 'yellow'
                              ? Colors.orange
                              : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityCard(Map<String, dynamic> user) {
    final resultado = PersonalidadService.evaluar(user);
    final color = PersonalidadService.getColor(resultado);

    return Container(
      // decoration: BoxDecoration(
      //   color: Colors.grey.shade200,
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evaluación de Tipo de Personalidad (Preguntas 37-51)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Diagnóstico: ${resultado['diagnostico']}',
              style: TextStyle(
                fontSize: 16,
                color: color == 'red'
                    ? Colors.red
                    : color == 'yellow'
                        ? Colors.orange
                        : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  resultado['tiene_ansiedad']
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
                  size: 40,
                  color:
                      resultado['tiene_ansiedad'] ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subescala de Ansiedad (37-44):',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                    Text('Puntaje: ${resultado['puntaje_ansiedad']} / 40'),
                    Text(
                      resultado['tiene_ansiedad']
                          ? 'Sugestivo de trastorno de ansiedad'
                          : 'Sin riesgo de trastorno de ansiedad',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  resultado['tiene_depresion']
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
                  size: 40,
                  color:
                      resultado['tiene_depresion'] ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subescala de Depresión (45-51):',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                    Text('Puntaje: ${resultado['puntaje_depresion']} / 35'),
                    Text(
                      resultado['tiene_depresion']
                          ? 'Sugestivo de trastorno de depresión'
                          : 'Sin riesgo de trastorno de depresión',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicesCard(Map<String, dynamic> user) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Índices Corporales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 40,
              runSpacing: 16,
              children: [
                _buildIndicador(
                  'IMC',
                  controller.getIMC(user),
                ),
                _buildIndicador(
                  'Índice Cintura/Estatura',
                  controller.getIndiceCircunferenciaCintura(),
                ),
                _buildIndicador(
                  'Índice Cintura/Cadera',
                  controller.getIndiceCircunferenciaCadera(),
                ),
                _buildPresionArterial(
                  'Presión Arterial',
                  controller.getPresionArterial(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicador(String titulo, String valor) {
    final esSaludable = valor.toLowerCase().contains('saludable');
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                esSaludable ? Icons.check_circle : Icons.warning_rounded,
                color: esSaludable ? Colors.green : Colors.red,
                size: 40, // Actualizado a 40
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  valor,
                  style: TextStyle(
                    fontSize: 14,
                    color: esSaludable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresionArterial(String titulo, String evaluacion) {
    final esNormal = evaluacion.toLowerCase().contains('normal');
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                esNormal ? Icons.check_circle : Icons.warning_rounded,
                color: esNormal ? Colors.green : Colors.red,
                size: 40, // Actualizado a 40
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  evaluacion,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: esNormal ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
