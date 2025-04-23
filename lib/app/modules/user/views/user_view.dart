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
    // Asegurarnos de que fetchUserData se llame cuando cambie la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchUserData();
    });

    return CustomScaffold(
      body: Obx(() {
        // Mostrar indicador de carga
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando datos del usuario...'),
              ],
            ),
          );
        }

        // Mostrar mensaje de error si hay problemas
        if (controller.hasErrors.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.fetchUserData(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Mostrar mensaje de acceso denegado
        if (controller.accessDenied.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, color: Colors.red.shade700, size: 48),
                const SizedBox(height: 16),
                Text(
                  'No tienes permisos para ver los datos de este usuario',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Volver'),
                ),
              ],
            ),
          );
        }

        // Verificar si hay datos
        if (controller.user.isEmpty) {
          return const Center(
            child: Text(
              'No hay datos disponibles para este usuario',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Contenido principal
        return Stack(
          children: [
            // Contenido principal
            ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                // Tarjeta de información personal
                _buildPersonalInfoCard(),
                const SizedBox(height: 20),

                // Mostrar preguntas no contestadas
                if (controller.authService.isAdmin.value &&
                    controller.unansweredQuestions.isNotEmpty) ...[
                  _buildUnansweredQuestionsCard(),
                  const SizedBox(height: 20),
                ] else if (controller.unansweredQuestions.isEmpty) ...[
                  // Mensaje para confirmar que todas las preguntas están contestadas
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Se han contestado todas las preguntas del cuestionario',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Evaluación general
                _buildEstiloVidaTotal(),
                const SizedBox(height: 20),

                // Índices corporales
                _buildIndicesCard(),
                const SizedBox(height: 20),

                // Hábitos alimenticios
                _buildEvaluationCard(
                  title: 'Evaluación de Hábitos Alimenticios',
                  evaluation:
                      HabitosAlimenticiosService.evaluar(controller.user),
                  color: HabitosAlimenticiosService.getColor(controller.user),
                  icon: Icons.restaurant,
                  items: _buildHabitosAlimenticiosItems(),
                  showItems: false, // Inicialmente colapsado
                ),
                const SizedBox(height: 20),

                // Actividad física
                _buildEvaluationCard(
                  title: 'Evaluación de Actividad Física',
                  evaluation: ActividadFisicaService.evaluar(controller.user),
                  color: ActividadFisicaService.getColor(controller.user),
                  icon: Icons.directions_run,
                  items: _buildActividadFisicaItems(),
                  showItems: false,
                  showRecommendations: true,
                ),
                const SizedBox(height: 20),

                // Personalidad
                _buildPersonalityCard(),
                const SizedBox(height: 20),

                // Nivel socioeconómico
                _buildNivelSocioeconomicoCard(),
                const SizedBox(height: 60), // Espacio adicional al final
              ],
            ),

            // Barra de acción flotante para modo edición
            if (controller.isEditing.value)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => controller.cancelEditing(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controller.isSaving.value
                                ? null
                                : () => controller.saveUser(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: controller.isSaving.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  // Widget para información personal
  Widget _buildPersonalInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con acciones
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
                // Botón de edición
                if (!controller.isEditing.value)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => controller.startEditing(),
                    tooltip: 'Editar información',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ),
                const SizedBox(width: 8),
                // Botón de eliminación (ahora disponible para todos los usuarios)
                if (!controller.isEditing.value)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(),
                    tooltip: 'Eliminar encuestado',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Campos de información personal
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _buildInfoField('Nombre', 'name'),
                _buildInfoField('Edad', 'age', suffix: 'años'),
                _buildInfoField('Género', 'gender'),
                _buildInfoField('Ciudad', 'municipio'),
                _buildInfoField(
                    'Escuela',
                    controller.user['nombre_escuela'].toString().isNotEmpty
                        ? 'nombre_escuela'
                        : 'sec_TamMad'),
                _buildInfoField('Horario', 'horario'),
                _buildInfoField('Nivel Educativo', 'nivel_educativo'),
                _buildInfoField('Peso', 'peso', suffix: 'kg'),
                _buildInfoField('Estatura', 'estatura', suffix: 'm'),
                _buildInfoField('Cintura', 'cintura', suffix: 'cm'),
                _buildInfoField('Cadera', 'cadera', suffix: 'cm'),
                _buildInfoField('Sistólica', 'sistolica', suffix: 'mmHg'),
                _buildInfoField('Diastólica', 'diastolica', suffix: 'mmHg'),
                if (controller.user['enfermedades'] != null &&
                    controller.user['enfermedades'].toString().isNotEmpty)
                  _buildInfoField('Enfermedades', 'enfermedades'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Campo de información con manejo de edición
  Widget _buildInfoField(String label, String fieldName, {String? suffix}) {
    final value = controller.isEditing.value
        ? controller.userEditInfo[fieldName]?.toString() ?? ''
        : controller.user[fieldName]?.toString() ?? '';

    final hasError = controller.fieldErrors.containsKey(fieldName);
    final errorText = controller.fieldErrors[fieldName] ?? '';

    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: hasError ? Colors.red : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          if (controller.isEditing.value) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: value,
                    onChanged: (newValue) =>
                        controller.updateField(fieldName, newValue),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: hasError ? Colors.red : Colors.grey.shade300,
                        ),
                      ),
                      errorText: hasError ? errorText : null,
                      suffixText: suffix,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? 'No especificado' : value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: value.isEmpty ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
                if (suffix != null)
                  Text(
                    suffix,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Divider(color: Colors.grey.shade300),
          ],
        ],
      ),
    );
  }

  // Widget para mostrar preguntas no contestadas
  Widget _buildUnansweredQuestionsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Preguntas No Contestadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Este usuario no ha contestado ${controller.unansweredQuestions.length} preguntas:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: controller.unansweredQuestions
                .map(
                  (question) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      question,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // Widget para evaluación general del estilo de vida
  Widget _buildEstiloVidaTotal() {
    final resultado = controller.getEstiloVidaTotal();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getIconForEvaluation(resultado['color']),
                const SizedBox(width: 16),
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
                          fontWeight: FontWeight.w500,
                          color: _getColorForStatus(resultado['color']),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget para índices corporales
  Widget _buildIndicesCard() {
    final peso = double.tryParse(controller.user['peso'].toString()) ?? 0;
    final pesoAPerder = (peso * 0.10).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Índices Corporales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 24),

            // Grid de indicadores
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 20,
              runSpacing: 24,
              children: [
                _buildIndicador(
                  'IMC',
                  controller.getIMC(controller.user),
                  Icons.monitor_weight,
                ),
                _buildIndicador(
                  'Índice Cintura/Estatura',
                  controller.getIndiceCircunferenciaCintura(),
                  Icons.height,
                ),
                _buildIndicador(
                  'Índice Cintura/Cadera',
                  controller.getIndiceCircunferenciaCadera(),
                  Icons.schema,
                ),
                _buildIndicador(
                  'Presión Arterial',
                  controller.getPresionArterial(),
                  Icons.favorite,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Recomendaciones de salud
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '¡ERES LO QUE COMES!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Las personas con sobrepeso y obesidad tienen mayor riesgo de desarrollar diabetes, hipertensión y otros problemas de salud.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Plan de Acción Diario',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Dieta basada en el Plato del Bien Comer (verduras, frutas, cereales, proteínas)\n'
                    '• 60 minutos de actividad física\n'
                    '• 6-8 vasos de agua simple',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¿Cuánto peso debo bajar?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
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
    );
  }

  // Widget para construir un indicador
  Widget _buildIndicador(String titulo, String valor, IconData iconData) {
    final esSaludable = valor.toLowerCase().contains('saludable') ||
        valor.toLowerCase().contains('normal');

    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esSaludable ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: esSaludable ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: esSaludable ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 13,
                    color: esSaludable
                        ? Colors.green.shade800
                        : Colors.red.shade800,
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

  // Widget para tarjetas de evaluación (con estado para expandir/colapsar)
  Widget _buildEvaluationCard({
    required String title,
    required String evaluation,
    required String color,
    required IconData icon,
    required List<String> items,
    bool showItems = false,
    bool showRecommendations = false,
  }) {
    final rxShowItems = showItems.obs;
    final esSaludable = evaluation.toLowerCase().contains('activo');
    final esAdvertencia = evaluation.toLowerCase().contains('semi-activo');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          color: _getColorForStatus(color),
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            rxShowItems.value
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () =>
                              rxShowItems.value = !rxShowItems.value,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          esSaludable
                              ? Icons.check_circle
                              : esAdvertencia
                                  ? Icons.warning_amber_rounded
                                  : Icons.dangerous,
                          color: _getColorForStatus(color),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            evaluation,
                            style: TextStyle(
                              fontSize: 16,
                              color: _getColorForStatus(color),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Detalles expandibles
              if (rxShowItems.value) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Respuestas del Cuestionario',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: items
                            .map((item) => Chip(
                                  label: Text(item),
                                  backgroundColor: Colors.grey.shade100,
                                  side: BorderSide(color: Colors.grey.shade300),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],

              // Recomendaciones (si corresponde)
              if (showRecommendations &&
                  (evaluation.toLowerCase().contains('semi-activo') ||
                      evaluation.toLowerCase().contains('sedentario'))) ...[
                const Divider(height: 1),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Recomendaciones de la OMS (5-17 años)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ActividadFisicaService.getRecomendaciones(),
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          )),
    );
  }

  // Construir items para hábitos alimenticios
  List<String> _buildHabitosAlimenticiosItems() {
    return List.generate(26, (index) {
      final pregunta = 'pr${index + 1}';
      return '${index + 1}: ${controller.user[pregunta] ?? "N/A"}';
    });
  }

  // Construir items para actividad física
  List<String> _buildActividadFisicaItems() {
    return List.generate(10, (index) {
      final pregunta = 'pr${index + 27}';
      return '${index + 27}: ${controller.user[pregunta] ?? "N/A"}';
    });
  }

  // Widget para la tarjeta de personalidad
  Widget _buildPersonalityCard() {
    final resultado = PersonalidadService.evaluar(controller.user);
    final color = PersonalidadService.getColor(resultado);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: Colors.purple.shade700,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Evaluación de Tipo de Personalidad',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getBackgroundColorForStatus(color),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _getBorderColorForStatus(color),
                ),
              ),
              child: Text(
                'Diagnóstico: ${resultado['diagnostico']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _getColorForStatus(color),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Subescala de ansiedad
            _buildPersonalityScale(
              'Subescala de Ansiedad',
              resultado['puntaje_ansiedad'],
              40,
              resultado['tiene_ansiedad'],
              Icons.sentiment_very_dissatisfied,
              'Sugestivo de trastorno de ansiedad',
              'Sin riesgo de trastorno de ansiedad',
            ),

            const SizedBox(height: 16),

            // Subescala de depresión
            _buildPersonalityScale(
              'Subescala de Depresión',
              resultado['puntaje_depresion'],
              35,
              resultado['tiene_depresion'],
              Icons.mood_bad,
              'Sugestivo de trastorno de depresión',
              'Sin riesgo de trastorno de depresión',
            ),
          ],
        ),
      ),
    );
  }

  // Widget para las escalas de personalidad
  Widget _buildPersonalityScale(
    String title,
    int score,
    int maxScore,
    bool hasCondition,
    IconData icon,
    String negativeMessage,
    String positiveMessage,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasCondition ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasCondition ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: hasCondition ? Colors.red : Colors.green,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Puntaje: $score/$maxScore',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        hasCondition ? negativeMessage : positiveMessage,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: hasCondition
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para nivel socioeconómico
  Widget _buildNivelSocioeconomicoCard() {
    final nivel = controller.getNivelSE();
    final colorStr = SocioEconomicCalculator.getColor(controller.user);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.home,
                  color: Colors.indigo.shade700,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Evaluación de Nivel Socioeconómico',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getSEBackgroundColor(colorStr),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _getSEBorderColor(colorStr)),
              ),
              child: Row(
                children: [
                  _getSEIcon(colorStr),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      nivel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _getSEIconColor(colorStr),
                      ),
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

  // Diálogo de confirmación de eliminación
  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red.shade700),
            const SizedBox(width: 12),
            const Text('Eliminar Usuario'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // FUNCIONES UTILITARIAS

  // Obtener el ícono según la evaluación
  Widget _getIconForEvaluation(String color) {
    return Icon(
      color == 'green'
          ? Icons.check_circle
          : color == 'yellow'
              ? Icons.warning_amber_rounded
              : Icons.dangerous,
      color: _getColorForStatus(color),
      size: 40,
    );
  }

  // Obtener color según el estado
  Color _getColorForStatus(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green.shade700;
      case 'lightgreen':
        return Colors.green.shade500;
      case 'blue':
        return Colors.blue.shade600;
      case 'yellow':
        return Colors.orange.shade700;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red.shade700;
      case 'darkred':
        return Colors.red.shade900;
      default:
        return Colors.grey.shade700;
    }
  }

  // Obtener color de fondo según el estado
  Color _getBackgroundColorForStatus(String colorName) {
    switch (colorName) {
      case 'green':
      case 'lightgreen':
        return Colors.green.shade50;
      case 'blue':
        return Colors.blue.shade50;
      case 'yellow':
      case 'orange':
        return Colors.orange.shade50;
      case 'red':
      case 'darkred':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  // Obtener color de borde según el estado
  Color _getBorderColorForStatus(String colorName) {
    switch (colorName) {
      case 'green':
      case 'lightgreen':
        return Colors.green.shade200;
      case 'blue':
        return Colors.blue.shade200;
      case 'yellow':
      case 'orange':
        return Colors.orange.shade200;
      case 'red':
      case 'darkred':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  // Funciones para nivel socioeconómico
  Widget _getSEIcon(String colorStr) {
    IconData iconData;
    switch (colorStr) {
      case 'green':
        iconData = Icons.verified; // A/B - Máximo nivel
        break;
      case 'lightgreen':
        iconData = Icons.check_circle; // C+ - Muy bueno
        break;
      case 'blue':
        iconData = Icons.thumb_up; // C - Bueno
        break;
      case 'yellow':
        iconData = Icons.warning_amber_rounded; // C- - Regular alto
        break;
      case 'orange':
        iconData = Icons.warning; // D+ - Regular bajo
        break;
      case 'red':
        iconData = Icons.error; // D - Bajo
        break;
      case 'darkred':
        iconData = Icons.dangerous; // E - Muy bajo
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Icon(
      iconData,
      color: _getSEIconColor(colorStr),
      size: 32,
    );
  }

  Color _getSEIconColor(String colorStr) {
    switch (colorStr) {
      case 'green':
        return Colors.green.shade700;
      case 'lightgreen':
        return Colors.green.shade500;
      case 'blue':
        return Colors.blue.shade600;
      case 'yellow':
        return Colors.orange.shade700;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red.shade700;
      case 'darkred':
        return Colors.red.shade900;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getSEBackgroundColor(String colorStr) {
    switch (colorStr) {
      case 'green':
      case 'lightgreen':
        return Colors.green.shade50;
      case 'blue':
        return Colors.blue.shade50;
      case 'yellow':
      case 'orange':
        return Colors.orange.shade50;
      case 'red':
      case 'darkred':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getSEBorderColor(String colorStr) {
    switch (colorStr) {
      case 'green':
      case 'lightgreen':
        return Colors.green.shade200;
      case 'blue':
        return Colors.blue.shade200;
      case 'yellow':
      case 'orange':
        return Colors.orange.shade200;
      case 'red':
      case 'darkred':
        return Colors.red.shade200;
      default:
        return Colors.grey.shade300;
    }
  }
}
