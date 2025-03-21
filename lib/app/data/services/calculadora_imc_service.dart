import 'package:vida_saludable/core/values/pesos_const.dart';

abstract class IMCCategoria {
  String calcular(double imc);
}

class CategoriaIMC implements IMCCategoria {
  final double limiteInferior;
  final double limiteSuperior;
  final String descripcion;

  CategoriaIMC(this.limiteInferior, this.limiteSuperior, this.descripcion);

  @override
  String calcular(double imc) {
    if (imc >= limiteInferior && imc <= limiteSuperior) {
      return descripcion;
    }
    return "";
  }
}

class BajoPeso extends CategoriaIMC {
  BajoPeso(double limiteSuperior) : super(0, limiteSuperior, "Bajo peso");
}

class Normal extends CategoriaIMC {
  Normal(double limiteInferior, double limiteSuperior)
      : super(limiteInferior, limiteSuperior, "Normal");
}

class Sobrepeso extends CategoriaIMC {
  Sobrepeso(double limiteInferior, double limiteSuperior)
      : super(limiteInferior, limiteSuperior, "Sobrepeso");
}

class Obesidad extends CategoriaIMC {
  Obesidad(double limiteInferior)
      : super(limiteInferior, double.infinity, "Obesidad");
}

class CalculadoraIMC {
  static String calcular(double imc, int edad, String sexo) {
    edad = edad.clamp(5, 20);

    if (categoriasPesos.containsKey(sexo) &&
        categoriasPesos[sexo]!.containsKey(edad)) {
      final categorias = categoriasPesos[sexo]![edad]!;
      for (var categoria in categorias) {
        final resultado = categoria.calcular(imc);
        if (resultado.isNotEmpty) {
          return "$resultado (${imc.toStringAsFixed(1)})";
        }
      }
    }
    return "Edad o sexo no válido";
  }
}
