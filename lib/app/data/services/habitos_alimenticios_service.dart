class HabitosAlimenticiosService {
  static String evaluar(Map<String, dynamic> user) {
    int puntajeTotal = 0;

    // Sumar los valores de pr1 a pr26
    for (int i = 1; i <= 26; i++) {
      String key = 'pr$i';
      if (user.containsKey(key)) {
        puntajeTotal += int.tryParse(user[key].toString()) ?? 0;
      }
    }

    // Evaluar según los rangos establecidos
    if (puntajeTotal < 91) {
      return 'Hábitos alimenticios deficientes ($puntajeTotal puntos)';
    } else if (puntajeTotal <= 104) {
      return 'Hábitos alimenticios suficientes ($puntajeTotal puntos)';
    } else {
      return 'Hábitos alimenticios saludables ($puntajeTotal puntos)';
    }
  }

  static String getColor(Map<String, dynamic> user) {
    int puntajeTotal = 0;
    for (int i = 1; i <= 26; i++) {
      String key = 'pr$i';
      if (user.containsKey(key)) {
        puntajeTotal += int.tryParse(user[key].toString()) ?? 0;
      }
    }

    if (puntajeTotal < 91) return 'red';
    if (puntajeTotal <= 104) return 'yellow';
    return 'green';
  }
}
