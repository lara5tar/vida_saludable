import '../../app/data/services/calculadora_imc_service.dart';

final Map<String, Map<int, List<IMCCategoria>>> categoriasPesos = {
  "mujer": {
    10: [
      BajoPeso(13.5),
      Normal(13.6, 19.0),
      Sobrepeso(19.1, 22.6),
      Obesidad(22.7),
    ],
    11: [
      BajoPeso(13.9),
      Normal(14.0, 19.9),
      Sobrepeso(20.0, 23.7),
      Obesidad(23.8),
    ],
    12: [
      BajoPeso(14.4),
      Normal(14.5, 20.8),
      Sobrepeso(20.9, 25.0),
      Obesidad(25.1),
    ],
    13: [
      BajoPeso(14.9),
      Normal(15.0, 21.8),
      Sobrepeso(21.9, 26.2),
      Obesidad(26.3),
    ],
    14: [
      BajoPeso(15.4),
      Normal(15.5, 22.7),
      Sobrepeso(22.8, 27.3),
      Obesidad(27.4),
    ],
    15: [
      BajoPeso(15.9),
      Normal(16.0, 23.5),
      Sobrepeso(23.6, 28.2),
      Obesidad(28.3),
    ],
    16: [
      BajoPeso(16.2),
      Normal(16.3, 24.1),
      Sobrepeso(24.2, 28.9),
      Obesidad(29.0),
    ],
    17: [
      BajoPeso(16.4),
      Normal(16.5, 24.5),
      Sobrepeso(24.6, 29.3),
      Obesidad(29.4),
    ],
    18: [
      BajoPeso(16.4),
      Normal(16.5, 24.8),
      Sobrepeso(24.9, 29.5),
      Obesidad(29.6),
    ],
    19: [
      BajoPeso(16.5),
      Normal(16.6, 25.0),
      Sobrepeso(25.1, 29.7),
      Obesidad(29.8),
    ],
  },
  'hombre': {
    10: [
      BajoPeso(13.7),
      Normal(13.8, 18.5),
      Sobrepeso(18.6, 21.4),
      Obesidad(21.5),
    ],
    11: [
      BajoPeso(14.1),
      Normal(14.2, 19.2),
      Sobrepeso(19.3, 22.5),
      Obesidad(22.6),
    ],
    12: [
      BajoPeso(14.5),
      Normal(14.6, 19.9),
      Sobrepeso(20.0, 23.6),
      Obesidad(23.7),
    ],
    13: [
      BajoPeso(14.9),
      Normal(15.0, 20.8),
      Sobrepeso(20.9, 24.8),
      Obesidad(24.9),
    ],
    14: [
      BajoPeso(15.5),
      Normal(15.6, 21.8),
      Sobrepeso(21.9, 25.9),
      Obesidad(26.0),
    ],
    15: [
      BajoPeso(16.0),
      Normal(16.1, 22.7),
      Sobrepeso(22.8, 27.0),
      Obesidad(27.1),
    ],
    16: [
      BajoPeso(16.5),
      Normal(16.6, 23.5),
      Sobrepeso(23.6, 27.9),
      Obesidad(28.0),
    ],
    17: [
      BajoPeso(16.9),
      Normal(17.0, 24.3),
      Sobrepeso(24.4, 28.6),
      Obesidad(28.7),
    ],
    18: [
      BajoPeso(17.3),
      Normal(17.4, 24.9),
      Sobrepeso(25.0, 29.2),
      Obesidad(29.3),
    ],
    19: [
      BajoPeso(17.6),
      Normal(17.7, 25.4),
      Sobrepeso(25.5, 29.7),
      Obesidad(29.8),
    ],
  },
};
