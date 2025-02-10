class PersonalidadService {
  static Map<String, dynamic> evaluar(Map<String, dynamic> user) {
    // Calcular puntaje de ansiedad (ítems 37-44)
    int puntajeAnsiedad = 0;
    for (int i = 37; i <= 44; i++) {
      String key = 'pr$i';
      if (user.containsKey(key)) {
        puntajeAnsiedad += int.tryParse(user[key].toString()) ?? 0;
      }
    }

    // Calcular puntaje de depresión (ítems 45-51)
    int puntajeDepresion = 0;
    for (int i = 45; i <= 51; i++) {
      String key = 'pr$i';
      if (user.containsKey(key)) {
        puntajeDepresion += int.tryParse(user[key].toString()) ?? 0;
      }
    }

    // Evaluar resultados
    bool tieneAnsiedad = puntajeAnsiedad <= 20;
    bool tieneDepresion = puntajeDepresion <= 15;
    String diagnostico;

    if (tieneAnsiedad && tieneDepresion) {
      diagnostico = 'Trastorno mixto (ansiedad y depresión)';
    } else if (tieneAnsiedad) {
      diagnostico = 'Trastorno de ansiedad';
    } else if (tieneDepresion) {
      diagnostico = 'Trastorno de depresión';
    } else {
      diagnostico = 'Sin riesgo de trastorno';
    }

    return {
      'diagnostico': diagnostico,
      'puntaje_ansiedad': puntajeAnsiedad,
      'puntaje_depresion': puntajeDepresion,
      'tiene_ansiedad': tieneAnsiedad,
      'tiene_depresion': tieneDepresion,
    };
  }

  static String getColor(Map<String, dynamic> resultado) {
    if (resultado['diagnostico'] == 'Sin riesgo de trastorno') {
      return 'green';
    } else if (resultado['diagnostico'] ==
        'Trastorno mixto (ansiedad y depresión)') {
      return 'red';
    } else {
      return 'yellow';
    }
  }
}
