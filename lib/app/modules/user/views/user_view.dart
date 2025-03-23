import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/nivel_socioeconomico.dart';
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
          children: [
            // Datos básicos
            _buildBasicInfoCard(controller.user),
            const SizedBox(height: 20),
            _buildEstiloVidaTotal(), // Agregamos este widget
            const SizedBox(height: 20),
            // Nueva tarjeta de índices
            _buildIndicesCard(controller.user),
            const SizedBox(height: 20),
            // Hábitos alimenticios
            Column(
              children: [
                _buildEvaluationCard(
                  title: 'Evaluación de Hábitos Alimenticios',
                  evaluation:
                      HabitosAlimenticiosService.evaluar(controller.user),
                  color: HabitosAlimenticiosService.getColor(controller.user),
                  items: List.generate(26, (index) {
                    final pregunta = 'pr${index + 1}';
                    return '${index + 1}: ${controller.user[pregunta] ?? "N/A"}';
                  }),
                ),
                const SizedBox(height: 20),
                // Actividad física
                _buildEvaluationCard(
                  title: 'Evaluación de Actividad Física',
                  evaluation: ActividadFisicaService.evaluar(controller.user),
                  color: ActividadFisicaService.getColor(controller.user),
                  items: List.generate(10, (index) {
                    final pregunta = 'pr${index + 27}';
                    return '${index + 27}: ${controller.user[pregunta] ?? "N/A"}';
                  }),
                ),
              ],
            ),
            _buildPersonalityCard(controller.user),
            nivelSocioEconomico()
            // Resto de la información del usuario
            // ...existing user details...
          ],
        );
      }),
    );
  }

  Container nivelSocioEconomico() {
    final nivel = controller.getNivelSE();
    final colorStr = SocioEconomicCalculator.getColor(controller.user);

    IconData getIcon() {
      switch (colorStr) {
        case 'green':
          return Icons.verified; // A/B - Máximo nivel
        case 'lightgreen':
          return Icons.check_circle; // C+ - Muy bueno
        case 'blue':
          return Icons.thumb_up; // C - Bueno
        case 'yellow':
          return Icons.warning_amber_rounded; // C- - Regular alto
        case 'orange':
          return Icons.warning; // D+ - Regular bajo
        case 'red':
          return Icons.error; // D - Bajo
        case 'darkred':
          return Icons.dangerous; // E - Muy bajo
        default:
          return Icons.help_outline;
      }
    }

    Color getColor() {
      switch (colorStr) {
        case 'green':
          return Colors.green;
        case 'lightgreen':
          return Colors.green.shade400;
        case 'blue':
          return Colors.blue;
        case 'yellow':
          return Colors.orange.shade700;
        case 'orange':
          return Colors.orange;
        case 'red':
          return Colors.red;
        case 'darkred':
          return Colors.red.shade900;
        default:
          return Colors.grey.shade700;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Evaluación de Nivel Socioeconómico',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                getIcon(),
                color: getColor(),
                size: 40,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  nivel,
                  style: TextStyle(
                    fontSize: 16,
                    color: getColor(),
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

  Widget _buildBasicInfoCard(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green, size: 20),
                  onPressed: () {
                    controller.saveUser();
                  },
                  tooltip: 'Editar información',
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    // Mostrar diálogo de confirmación
                    controller.deleteUser();
                  },
                  tooltip: 'Eliminar usuario',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 40,
            runSpacing: 20,
            children: [
              _buildInfoItem('Nombre', user['name'] ?? '', 'name'),
              _buildInfoItem('Edad', '${user['age'] ?? ''}', 'age',
                  suffix: 'años'),
              _buildInfoItem('Género', user['gender'] ?? '', 'gender'),
              _buildInfoItem('Ciudad', user['municipio'] ?? '', 'municipio'),
              _buildInfoItem(
                  'Escuela',
                  user['nombre_escuela'].toString().isNotEmpty
                      ? user['nombre_escuela']
                      : user['sec_TamMad'],
                  user['nombre_escuela'].toString().isNotEmpty
                      ? 'nombre_escuela'
                      : 'sec_TamMad'),
              _buildInfoItem('Horario', user['horario'] ?? '', 'horario'),
              _buildInfoItem('Nivel Educativo', user['nivel_educativo'] ?? '',
                  'nivel_educativo'),
              _buildInfoItem('Peso', '${user['peso'] ?? ''}', 'peso',
                  suffix: 'kg'),
              _buildInfoItem(
                  'Estatura', '${user['estatura'] ?? ''}', 'estatura',
                  suffix: 'm'),
              _buildInfoItem('Cintura', '${user['cintura'] ?? ''}', 'cintura',
                  suffix: 'cm'),
              _buildInfoItem('Cadera', '${user['cadera'] ?? ''}', 'cadera',
                  suffix: 'cm'),
              _buildInfoItem(
                  'Sistólica', '${user['sistolica'] ?? ''}', 'sistolica',
                  suffix: 'mmHg'),
              _buildInfoItem(
                  'Diastólica', '${user['diastolica'] ?? ''}', 'diastolica',
                  suffix: 'mmHg'),
              if (user['enfermedades'] != null)
                _buildInfoItem(
                    'Enfermedades', user['enfermedades'], 'enfermedades'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, String index,
      {String? suffix}) {
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
          TextField(
            controller: TextEditingController(text: value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
            onChanged: (value) => controller.updateField(index, value),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              border: InputBorder.none,
              suffixIcon: Text(
                suffix ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                // minWidth: 20,
                minHeight: 20,
              ),
              // suffixText: suffix,
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey.shade300,
            // margin: const EdgeInsets.symmetric(vertical: 8),
          )
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
    final esSaludable = evaluation.toLowerCase().contains('activo');
    final esAdvertencia = evaluation.toLowerCase().contains('semi-activo');
    final mostrarRecomendaciones = title.contains('Actividad Física') &&
        (evaluation.toLowerCase().contains('semi-activo') ||
            evaluation.toLowerCase().contains('sedentario'));

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  mainAxisSize: MainAxisSize.min,
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
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (mostrarRecomendaciones) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recomendaciones de la OMS (5-17 años)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ActividadFisicaService.getRecomendaciones(),
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalityCard(Map<String, dynamic> user) {
    final resultado = PersonalidadService.evaluar(user);
    final color = PersonalidadService.getColor(resultado);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evaluación de Tipo de Personalidad',
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
              mainAxisSize: MainAxisSize.min,
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
                Expanded(
                  child: Text(
                    'Subescala de Ansiedad - Puntaje: ${resultado['puntaje_ansiedad']}/40: ${resultado['tiene_ansiedad'] ? 'Sugestivo de trastorno de ansiedad' : 'Sin riesgo de trastorno de ansiedad'}',
                    style: TextStyle(
                      color: resultado['tiene_ansiedad']
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
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
                Expanded(
                  child: Text(
                    'Subescala de Depresión - Puntaje: ${resultado['puntaje_depresion']}/35: ${resultado['tiene_depresion'] ? 'Sugestivo de trastorno de depresión' : 'Sin riesgo de trastorno de depresión'}',
                    style: TextStyle(
                      color: resultado['tiene_depresion']
                          ? Colors.red
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

  Widget _buildIndicesCard(Map<String, dynamic> user) {
    final peso = double.tryParse(user['peso'].toString()) ?? 0;
    final pesoAPerder = (peso * 0.10).toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
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
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      _buildIndicador('IMC', controller.getIMC(user)),
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
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¡ERES LO QUE COMES!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Las personas con sobrepeso y obesidad tienen mayor riesgo de desarrollar diabetes, hipertensión y otros problemas de salud.',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Plan de Acción Diario',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '• Dieta basada en el Plato del Bien Comer (verduras, frutas, cereales, proteínas)\n'
                          '• 60 minutos de actividad física\n'
                          '• 6-8 vasos de agua simple',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '¿Cuánto peso debo bajar?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Meta recomendada: $pesoAPerder kg en 6 meses (10% de tu peso actual)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicador(String titulo, String valor) {
    final esSaludable = valor.toLowerCase().contains('saludable');
    return SizedBox(
      width: 250,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            esSaludable ? Icons.check_circle : Icons.warning_rounded,
            color: esSaludable ? Colors.green : Colors.red,
            size: 40,
          ),
          const SizedBox(width: 15), // Changed from height to width
          Expanded(
            // Added Expanded
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
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 16,
                    color: esSaludable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.visible, // Added overflow
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresionArterial(String titulo, String evaluacion) {
    final esNormal = evaluacion.toLowerCase().contains('normal');
    return SizedBox(
      width: 300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            esNormal ? Icons.check_circle : Icons.warning_rounded,
            color: esNormal ? Colors.green : Colors.red,
            size: 40,
          ),
          const SizedBox(width: 15),
          Expanded(
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
                Text(
                  evaluacion,
                  style: TextStyle(
                    fontSize: 16,
                    color: esNormal ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstiloVidaTotal() {
    final resultado = controller.getEstiloVidaTotal();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(
            resultado['color'] == 'green'
                ? Icons.check_circle
                : resultado['color'] == 'yellow'
                    ? Icons.warning_amber_rounded
                    : Icons.dangerous,
            color: resultado['color'] == 'green'
                ? Colors.green
                : resultado['color'] == 'yellow'
                    ? Colors.orange
                    : Colors.red,
            size: 40,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evaluación General del Estilo de Vida',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${resultado['evaluacion']} (${resultado['puntaje']} puntos)',
                  style: TextStyle(
                    fontSize: 16,
                    color: resultado['color'] == 'green'
                        ? Colors.green
                        : resultado['color'] == 'yellow'
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
