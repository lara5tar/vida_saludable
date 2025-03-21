import '../../app/data/services/calculadora_imc_service.dart';

final Map<String, Map<double, List<IMCCategoria>>> categoriasPesos = {
  "mujer": {
    5.6: [
      BajoPeso(12.7),
      Normal(12.8, 15.2),
      Sobrepeso(15.3, 17.0),
      Obesidad(17.1),
    ],
    6: [
      BajoPeso(12.7),
      Normal(12.8, 15.3),
      Sobrepeso(15.4, 17.0),
      Obesidad(17.1),
    ],
    6.6: [
      BajoPeso(12.7),
      Normal(12.8, 15.3),
      Sobrepeso(15.4, 17.1),
      Obesidad(17.2),
    ],
    7: [
      BajoPeso(12.7),
      Normal(12.8, 15.4),
      Sobrepeso(15.5, 17.3),
      Obesidad(17.4),
    ],
    7.6: [
      BajoPeso(12.8),
      Normal(12.9, 15.5),
      Sobrepeso(15.6, 17.5),
      Obesidad(17.6),
    ],
    8: [
      BajoPeso(12.9),
      Normal(13.0, 15.7),
      Sobrepeso(15.8, 17.7),
      Obesidad(17.8),
    ],
    8.6: [
      BajoPeso(13.0),
      Normal(13.1, 15.9),
      Sobrepeso(16.0, 18.0),
      Obesidad(18.1),
    ],
    9: [
      BajoPeso(13.1),
      Normal(13.2, 16.1),
      Sobrepeso(16.2, 18.3),
      Obesidad(18.4),
    ],
    9.6: [
      BajoPeso(13.3),
      Normal(13.4, 16.3),
      Sobrepeso(16.4, 18.7),
      Obesidad(18.8),
    ],
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
    20: [
      BajoPeso(18.5),
      Normal(18.5, 24.9),
      Sobrepeso(25, 29.9),
      Obesidad(30),
    ],
  },

  //hombres
  // edades, BAJO PESO	NORMAL	SOBREPESO	OBESIDAD
// 5a6m	<=13	15.3	>=16.7	>=18.4
// 6	<=13	15.3	>=16.8	>=18.5
// 6a6m	<=13.1	15.4	>=16.9	>=18.7
// 7	<=13.1	15.5	>=17	>=19
// 7a6m	<=13.2	15.6	>=17.2	>=19.3
// 8	<=13.3	15.7	>=17.4	>=19.7
// 8a6m	<=13.4	15.9	>=17.7	>=20.1
// 9	<=13.5	16	>=17.9	>=20.5
// 9a6m	<=13.6	16.2	>=18.2	>=20.9
  'hombre': {
    5.6: [
      BajoPeso(13),
      Normal(13.1, 15.3),
      Sobrepeso(16.7, 18.3),
      Obesidad(18.4),
    ],
    6: [
      BajoPeso(13),
      Normal(13.1, 15.3),
      Sobrepeso(16.8, 18.4),
      Obesidad(18.5),
    ],
    6.6: [
      BajoPeso(13.1),
      Normal(13.2, 15.4),
      Sobrepeso(16.9, 18.6),
      Obesidad(18.7),
    ],
    7: [
      BajoPeso(13.1),
      Normal(13.2, 15.5),
      Sobrepeso(17, 18.9),
      Obesidad(19),
    ],
    7.6: [
      BajoPeso(13.2),
      Normal(13.3, 15.6),
      Sobrepeso(17.2, 19.2),
      Obesidad(19.3),
    ],
    8: [
      BajoPeso(13.3),
      Normal(13.4, 15.7),
      Sobrepeso(17.4, 19.6),
      Obesidad(19.7),
    ],
    8.6: [
      BajoPeso(13.4),
      Normal(13.5, 15.9),
      Sobrepeso(17.7, 20),
      Obesidad(20.1),
    ],
    9: [
      BajoPeso(13.5),
      Normal(13.6, 16),
      Sobrepeso(17.9, 20.4),
      Obesidad(20.5),
    ],
    9.6: [
      BajoPeso(13.6),
      Normal(13.7, 16.2),
      Sobrepeso(18.2, 20.8),
      Obesidad(20.9),
    ],
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
    20: [
      BajoPeso(18.5),
      Normal(18.5, 24.9),
      Sobrepeso(25, 29.9),
      Obesidad(30),
    ],
  },
};
