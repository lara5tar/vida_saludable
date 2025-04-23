import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:vida_saludable/app/data/services/auth_service.dart';

class Persona {
  String id;
  String name;
  int age;
  String gender;
  String nivelEduFam;
  int numIntegrantes;
  String integrantesTrabajando;
  String numDormitorios;
  String numAutos;
  String baths;
  String internet;
  String nivelEducativo;
  String tipoEscuela;
  String municipio;
  String secTamMad;
  String horario;
  String aplicacionLibro;
  String nombreLibro;
  String vidaSaludable;
  String enfermedades;
  int peso;
  double estatura;
  int cintura;
  int cadera;
  int sistolica;
  int diastolica;
  bool apMentales;
  bool apResumen;
  bool apMesaRedonda;
  bool apConceptuales;
  bool apCuestionarios;
  bool apTalleres;
  bool apProyectos;
  bool apOrganigrama;
  bool apVideos;
  bool apDiapos;
  bool apJuegos;
  String dadWork;
  String momWork;
  String grado;
  String nombreEscuela;
  String schoolId;

  Persona({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.nivelEduFam,
    required this.numIntegrantes,
    required this.integrantesTrabajando,
    required this.numAutos,
    required this.baths,
    required this.internet,
    required this.nivelEducativo,
    required this.tipoEscuela,
    required this.municipio,
    required this.secTamMad,
    required this.horario,
    required this.aplicacionLibro,
    required this.nombreLibro,
    required this.vidaSaludable,
    required this.enfermedades,
    required this.peso,
    required this.estatura,
    required this.cintura,
    required this.cadera,
    required this.sistolica,
    required this.diastolica,
    required this.apMentales,
    required this.apResumen,
    required this.apMesaRedonda,
    required this.apConceptuales,
    required this.apCuestionarios,
    required this.apTalleres,
    required this.apProyectos,
    required this.apOrganigrama,
    required this.apVideos,
    required this.apDiapos,
    required this.apJuegos,
    required this.dadWork,
    required this.momWork,
    required this.grado,
    required this.nombreEscuela,
    required this.numDormitorios,
    required this.schoolId,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'num_dormitorios': numDormitorios,
      'name': name,
      'age': age,
      'gender': gender,
      'nivelEduFam': nivelEduFam,
      'num_integrantes': numIntegrantes,
      'integrantes_trabajando': integrantesTrabajando,
      'num_autos': numAutos,
      'baths': baths,
      'internet': internet,
      'nivel_educativo': nivelEducativo,
      'tipo_escuela': tipoEscuela,
      'municipio': municipio,
      'sec_TamMad': secTamMad,
      'horario': horario,
      'aplicacion_libro': aplicacionLibro,
      'nombre_libro': nombreLibro,
      'vida_saludable': vidaSaludable,
      'enfermedades': enfermedades,
      'peso': peso,
      'estatura': estatura,
      'cintura': cintura,
      'cadera': cadera,
      'sistolica': sistolica,
      'diastolica': diastolica,
      'ap_mentales': apMentales,
      'ap_resumen': apResumen,
      'ap_mesaRedonda': apMesaRedonda,
      'ap_conceptuales': apConceptuales,
      'ap_cuestionarios': apCuestionarios,
      'ap_talleres': apTalleres,
      'ap_proyectos': apProyectos,
      'ap_organigrama': apOrganigrama,
      'ap_videos': apVideos,
      'ap_diapos': apDiapos,
      'ap_juegos': apJuegos,
      'dad_work': dadWork,
      'mom_work': momWork,
      'grado': grado,
      'nombre_escuela': nombreEscuela,
      'schoolId': schoolId, // Agregar el ID de la escuela
    };
  }
}

class RandomFormGenerator {
  final Random _random = Random();

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(_random.nextInt(chars.length))));
  }

  int _randomInt(int min, int max) => min + _random.nextInt(max - min);

  double _randomDouble(double min, double max) =>
      min + _random.nextDouble() * (max - min);

  bool _randomBool() => _random.nextBool();

  T _randomFromList<T>(List<T> list) => list[_random.nextInt(list.length)];

  Persona generateRandomPersona() {
    final bathsOptions = [0, 24, 47];
    final dormitoriosOptions = [0, 8, 16, 24, 32];
    final trabajandoOptions = [0, 15, 31, 46, 61];
    final autosOptions = [0, 22, 43];
    final internetOptions = [0, 32];
    final nivelEstudioFamOptions = [0, 6, 11, 12, 18, 23, 27, 36, 59, 85];

    // Crear un nombre de escuela aleatorio
    final escuela = _randomString(5);

    return Persona(
      id: _randomString(20),
      numDormitorios: _randomFromList(dormitoriosOptions).toString(),
      name: _randomString(10),
      age: _randomInt(10, 60),
      gender: _randomBool() ? 'Hombre' : 'Mujer',
      nivelEduFam: _randomFromList(nivelEstudioFamOptions).toString(),
      numIntegrantes: _randomInt(1, 10),
      integrantesTrabajando: _randomFromList(trabajandoOptions).toString(),
      numAutos: _randomFromList(autosOptions).toString(),
      baths: _randomFromList(bathsOptions).toString(),
      internet: _randomFromList(internetOptions).toString(),
      nivelEducativo: _randomString(5),
      tipoEscuela: _randomBool() ? 'Pública' : 'Privada',
      municipio: _randomString(5),
      secTamMad: escuela, // Usar la misma escuela
      horario: _randomBool() ? 'Matutino' : 'Vespertino',
      aplicacionLibro: _randomBool() ? 'Si' : 'No',
      nombreLibro: _randomString(5),
      vidaSaludable: _randomBool() ? 'Si' : 'No',
      enfermedades: _randomBool() ? 'Si' : 'No',
      peso: _randomInt(50, 90),
      estatura:
          double.tryParse(_randomDouble(1.50, 1.90).toStringAsFixed(2)) ?? 1.55,
      cintura: _randomInt(60, 120),
      cadera: _randomInt(80, 150),
      sistolica: _randomInt(90, 140),
      diastolica: _randomInt(60, 90),
      apMentales: _randomBool(),
      apResumen: _randomBool(),
      apMesaRedonda: _randomBool(),
      apConceptuales: _randomBool(),
      apCuestionarios: _randomBool(),
      apTalleres: _randomBool(),
      apProyectos: _randomBool(),
      apOrganigrama: _randomBool(),
      apVideos: _randomBool(),
      apDiapos: _randomBool(),
      apJuegos: _randomBool(),
      dadWork: _randomBool() ? 'Si' : 'No',
      momWork: _randomBool() ? 'Si' : 'No',
      grado: _randomInt(1, 6).toString(),
      nombreEscuela: escuela, // Usar la misma escuela
      schoolId: escuela, // Usar la misma escuela como ID para coherencia
    );
  }

  Future<void> uploadRandomPersona() async {
    try {
      // Intentar obtener el servicio de autenticación si está disponible
      AuthService? authService;
      try {
        authService = Get.find<AuthService>();
      } catch (e) {
        // Si no se encuentra el servicio, continuamos con authService = null
        authService = null;
      }

      final persona = generateRandomPersona();

      // Si tenemos acceso al servicio de autenticación y el usuario no es admin,
      // usar la escuela asignada al usuario actual
      if (authService != null &&
          !authService.isAdmin.value &&
          authService.assignedSchoolId.value.isNotEmpty) {
        final escuelaAsignada = authService.assignedSchoolId.value;

        // Actualizar los campos de escuela para que coincidan con la escuela asignada
        final personaActualizada = Persona(
          id: persona.id,
          name: persona.name,
          age: persona.age,
          gender: persona.gender,
          nivelEduFam: persona.nivelEduFam,
          numIntegrantes: persona.numIntegrantes,
          integrantesTrabajando: persona.integrantesTrabajando,
          numAutos: persona.numAutos,
          baths: persona.baths,
          internet: persona.internet,
          nivelEducativo: persona.nivelEducativo,
          tipoEscuela: persona.tipoEscuela,
          municipio: persona.municipio,
          secTamMad: escuelaAsignada,
          horario: persona.horario,
          aplicacionLibro: persona.aplicacionLibro,
          nombreLibro: persona.nombreLibro,
          vidaSaludable: persona.vidaSaludable,
          enfermedades: persona.enfermedades,
          peso: persona.peso,
          estatura: persona.estatura,
          cintura: persona.cintura,
          cadera: persona.cadera,
          sistolica: persona.sistolica,
          diastolica: persona.diastolica,
          apMentales: persona.apMentales,
          apResumen: persona.apResumen,
          apMesaRedonda: persona.apMesaRedonda,
          apConceptuales: persona.apConceptuales,
          apCuestionarios: persona.apCuestionarios,
          apTalleres: persona.apTalleres,
          apProyectos: persona.apProyectos,
          apOrganigrama: persona.apOrganigrama,
          apVideos: persona.apVideos,
          apDiapos: persona.apDiapos,
          apJuegos: persona.apJuegos,
          dadWork: persona.dadWork,
          momWork: persona.momWork,
          grado: persona.grado,
          nombreEscuela: escuelaAsignada,
          numDormitorios: persona.numDormitorios,
          schoolId: escuelaAsignada,
        );

        // Guardar en Firestore con la escuela asignada
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('users').add(personaActualizada.toMap());

        // Usar Logger en lugar de print
        // Usuario aleatorio creado en la escuela $escuelaAsignada
      } else {
        // Si no hay restricciones o el usuario es administrador, subir los datos tal cual
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('users').add(persona.toMap());

        // Usar Logger en lugar de print
        // Usuario aleatorio creado en la escuela ${persona.schoolId}
      }
    } catch (e) {
      // Usar Logger en lugar de print
      // Error al crear usuario aleatorio: $e
    }
  }
}
