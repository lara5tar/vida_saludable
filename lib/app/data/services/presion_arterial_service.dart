abstract class PresionArterialCategoria {
  String evaluar(double sistolica, double diastolica);
}

class CategoriaPresion implements PresionArterialCategoria {
  final double minSistolica;
  final double maxSistolica;
  final double minDiastolica;
  final double maxDiastolica;

  CategoriaPresion(this.minSistolica, this.maxSistolica, this.minDiastolica,
      this.maxDiastolica);

  @override
  String evaluar(double sistolica, double diastolica) {
    if (sistolica >= minSistolica &&
        sistolica <= maxSistolica &&
        diastolica >= minDiastolica &&
        diastolica <= maxDiastolica) {
      return "Presión sistólica($minSistolica - $maxSistolica), Presión diastólica($minDiastolica - $maxDiastolica)";
    }
    return "";
  }
}

class EvaluadorPresionArterial {
  static String evaluar(
      double sistolica, double diastolica, int edad, String sexo) {
    String diagnostico = '';

    // Evaluar presión sistólica
    if (sistolica < 90) {
      diagnostico = 'Presión sistólica baja';
    } else if (sistolica > 140) {
      diagnostico = 'Presión sistólica alta';
    }

    diagnostico += ' ($sistolica mmHg)';

    // Evaluar presión diastólica
    if (diastolica < 60) {
      diagnostico +=
          '${diagnostico.isEmpty ? '' : ' y '}presión diastólica baja';
    } else if (diastolica > 90) {
      diagnostico +=
          '${diagnostico.isEmpty ? '' : ' y '}presión diastólica alta';
    }

    diagnostico += ' ($diastolica mmHg)';

    // Si no hay anomalías, verificar rangos por edad y sexo
    if (diagnostico.isEmpty) {
      Map<String, Map<int, List<CategoriaPresion>>> categoriasPresion = {
        "mujer": {
          10: [CategoriaPresion(90.9, 112.7, 53.2, 73)],
          11: [CategoriaPresion(93.5, 115.7, 54.4, 74.6)],
          12: [CategoriaPresion(96, 119, 57.4, 76.8)],
          13: [CategoriaPresion(95.1, 119.3, 56.7, 78.1)],
          14: [CategoriaPresion(96, 119.6, 57, 78.2)],
          15: [CategoriaPresion(96.1, 118.9, 56, 76.4)],
          16: [CategoriaPresion(97.9, 120.3, 56.3, 77.7)],
          17: [CategoriaPresion(98.8, 121, 57.5, 77.7)],
          18: [CategoriaPresion(99.1, 120.9, 57, 77.8)],
        },
        "hombre": {
          10: [CategoriaPresion(91.4, 112.4, 54.1, 73.1)],
          11: [CategoriaPresion(92.4, 114, 53.6, 73.2)],
          12: [CategoriaPresion(95, 116.6, 55.8, 75.4)],
          13: [CategoriaPresion(95.2, 120.4, 54.7, 76.3)],
          14: [CategoriaPresion(97.2, 123, 55.3, 77.1)],
          15: [CategoriaPresion(100.5, 125.5, 55.2, 77.2)],
          16: [CategoriaPresion(102.4, 127, 56.3, 78.5)],
          17: [CategoriaPresion(105.4, 129.8, 59.8, 80.6)],
          18: [CategoriaPresion(106, 131.1, 61.8, 82)],
        }
      };

      edad = edad.clamp(10, 18);

      if (categoriasPresion.containsKey(sexo) &&
          categoriasPresion[sexo]!.containsKey(edad)) {
        final categorias = categoriasPresion[sexo]![edad]!;
        bool dentroDeLosRangos = false;

        for (var categoria in categorias) {
          if (sistolica >= categoria.minSistolica &&
              sistolica <= categoria.maxSistolica &&
              diastolica >= categoria.minDiastolica &&
              diastolica <= categoria.maxDiastolica) {
            dentroDeLosRangos = true;
            break;
          }
        }

        if (dentroDeLosRangos) {
          diagnostico = 'Presión arterial normal para la edad y sexo';
        } else {
          diagnostico =
              'Presión arterial fuera del rango normal para la edad y sexo';
        }
      }
    }

    return diagnostico.isEmpty ? 'No se puede determinar' : diagnostico;
  }
}
