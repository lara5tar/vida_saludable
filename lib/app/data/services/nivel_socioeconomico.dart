class SocioEconomicCalculator {
  static String calculateNSE(Map<String, dynamic> personaData) {
    // Extraer los valores del mapa
    int baths = int.parse(personaData['baths']);
    int dormitorios = int.parse(personaData['num_dormitorios']);
    int integrantesTrabajando =
        int.parse(personaData['integrantes_trabajando']);
    int autos = int.parse(personaData['num_autos']);
    int internet = int.parse(personaData['internet']);
    int nivelEstudioFam = int.parse(personaData['nivelEduFam']);

    // Calcular la suma total de puntos
    int totalPuntos = baths +
        dormitorios +
        integrantesTrabajando +
        autos +
        internet +
        nivelEstudioFam;

    // Determinar el nivel socioeconómico
    if (totalPuntos >= 202) {
      return "A/B: Este nivel es el de mayor bienestar socioeconómico en México, con acceso a internet en el 98% de los hogares y un 10% del gasto destinado a educación.";
    } else if (totalPuntos >= 168) {
      return "C+: Este nivel ocupa el segundo lugar en bienestar socioeconómico, con al menos un automóvil y 93% de acceso a internet.";
    } else if (totalPuntos >= 141) {
      return "C: En este nivel, el 77% de los hogares tienen acceso a internet y  el 35% del gasto está destinado a alimentación.";
    } else if (totalPuntos >= 116) {
      return "C-: En este nivel, el 52% de los hogares tienen acceso a internet y el 38% del gasto está destinado a alimentación.";
    } else if (totalPuntos >= 95) {
      return "D+: En este nivel, el 22% de los hogares tienen acceso a internet y el 42% del gasto está destinado a alimentación.";
    } else if (totalPuntos >= 48) {
      return "D: Este es el segundo nivel con bajo bienestar socioeconómico,con solo el 4% de acceso a internet.";
    } else {
      return "E: Este es el nivel con menor bienestar socioeconómico, con casi nulo acceso a internet y el 52% del gasto destinado a alimentación.";
    }
  }

  static String getColor(Map<String, dynamic> personaData) {
    int baths = int.parse(personaData['baths']);
    int dormitorios = int.parse(personaData['num_dormitorios']);
    int integrantesTrabajando =
        int.parse(personaData['integrantes_trabajando']);
    int autos = int.parse(personaData['num_autos']);
    int internet = int.parse(personaData['internet']);
    int nivelEstudioFam = int.parse(personaData['nivelEduFam']);

    int totalPuntos = baths +
        dormitorios +
        integrantesTrabajando +
        autos +
        internet +
        nivelEstudioFam;

    if (totalPuntos >= 202) return 'green'; // A/B
    if (totalPuntos >= 168) return 'lightgreen'; // C+
    if (totalPuntos >= 141) return 'blue'; // C
    if (totalPuntos >= 116) return 'yellow'; // C-
    if (totalPuntos >= 95) return 'orange'; // D+
    if (totalPuntos >= 48) return 'red'; // D
    return 'darkred'; // E
  }
}
