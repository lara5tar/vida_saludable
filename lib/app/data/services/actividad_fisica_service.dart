class ActividadFisicaService {
  static String evaluar(Map<String, dynamic> user) {
    int puntajeTotal = 0;

    // Sumar los valores de pr27 a pr36
    for (int i = 27; i <= 36; i++) {
      String key = 'pr$i';
      if (user.containsKey(key)) {
        puntajeTotal += int.tryParse(user[key].toString()) ?? 0;
      }
    }

    // Evaluar según los rangos establecidos
    if (puntajeTotal >= 41) {
      return 'Estilo de vida activo ($puntajeTotal puntos)';
    } else if (puntajeTotal >= 31) {
      return 'Estilo de vida semi-activo ($puntajeTotal puntos)';
    } else {
      return 'Estilo de vida sedentario ($puntajeTotal puntos)';
    }
  }

  static String getColor(Map<String, dynamic> user) {
    int puntajeTotal = 0;
    for (int i = 27; i <= 36; i++) {
      String key = 'pr$i';
      if (user.containsKey(key)) {
        puntajeTotal += int.tryParse(user[key].toString()) ?? 0;
      }
    }

    if (puntajeTotal >= 41) return 'green';
    if (puntajeTotal >= 31) return 'yellow';
    return 'red';
  }

  static String getRecomendaciones() {
    return '''• 60 minutos diarios de actividad física moderada a vigorosa
• Al menos 3 días de actividad aeróbica vigorosa
• Actividades recreativas: juegos, deportes, ejercicios
• Caminar o usar bicicleta para desplazamientos
• Participar en tareas domésticas
• Reducir el tiempo frente a pantallas''';
  }
}
