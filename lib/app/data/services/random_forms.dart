import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Persona {
  String id;
  String name;
  int age;
  String gender;
  String nivelEduFam;
  int num_integrantes;
  String integrantes_trabajando;
  String num_dormitorios;
  String num_autos;
  String baths;
  String internet;
  String nivel_educativo;
  String tipo_escuela;
  String municipio;
  String sec_TamMad;
  String horario;
  String aplicacion_libro;
  String nombre_libro;
  String vida_saludable;
  String enfermedades;
  int peso;
  double estatura;
  int cintura;
  int cadera;
  int sistolica;
  int diastolica;
  bool ap_mentales;
  bool ap_resumen;
  bool ap_mesaRedonda;
  bool ap_conceptuales;
  bool ap_cuestionarios;
  bool ap_talleres;
  bool ap_proyectos;
  bool ap_organigrama;
  bool ap_videos;
  bool ap_diapos;
  bool ap_juegos;
  String dad_work;
  String mom_work;
  String grado;
  String nombre_escuela;

  Persona({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.nivelEduFam,
    required this.num_integrantes,
    required this.integrantes_trabajando,
    required this.num_autos,
    required this.baths,
    required this.internet,
    required this.nivel_educativo,
    required this.tipo_escuela,
    required this.municipio,
    required this.sec_TamMad,
    required this.horario,
    required this.aplicacion_libro,
    required this.nombre_libro,
    required this.vida_saludable,
    required this.enfermedades,
    required this.peso,
    required this.estatura,
    required this.cintura,
    required this.cadera,
    required this.sistolica,
    required this.diastolica,
    required this.ap_mentales,
    required this.ap_resumen,
    required this.ap_mesaRedonda,
    required this.ap_conceptuales,
    required this.ap_cuestionarios,
    required this.ap_talleres,
    required this.ap_proyectos,
    required this.ap_organigrama,
    required this.ap_videos,
    required this.ap_diapos,
    required this.ap_juegos,
    required this.dad_work,
    required this.mom_work,
    required this.grado,
    required this.nombre_escuela,
    required this.num_dormitorios,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'num_dormitorios': num_dormitorios,
      'name': name,
      'age': age,
      'gender': gender,
      'nivelEduFam': nivelEduFam,
      'num_integrantes': num_integrantes,
      'integrantes_trabajando': integrantes_trabajando,
      'num_autos': num_autos,
      'baths': baths,
      'internet': internet,
      'nivel_educativo': nivel_educativo,
      'tipo_escuela': tipo_escuela,
      'municipio': municipio,
      'sec_TamMad': sec_TamMad,
      'horario': horario,
      'aplicacion_libro': aplicacion_libro,
      'nombre_libro': nombre_libro,
      'vida_saludable': vida_saludable,
      'enfermedades': enfermedades,
      'peso': peso,
      'estatura': estatura,
      'cintura': cintura,
      'cadera': cadera,
      'sistolica': sistolica,
      'diastolica': diastolica,
      'ap_mentales': ap_mentales,
      'ap_resumen': ap_resumen,
      'ap_mesaRedonda': ap_mesaRedonda,
      'ap_conceptuales': ap_conceptuales,
      'ap_cuestionarios': ap_cuestionarios,
      'ap_talleres': ap_talleres,
      'ap_proyectos': ap_proyectos,
      'ap_organigrama': ap_organigrama,
      'ap_videos': ap_videos,
      'ap_diapos': ap_diapos,
      'ap_juegos': ap_juegos,
      'dad_work': dad_work,
      'mom_work': mom_work,
      'grado': grado,
      'nombre_escuela': nombre_escuela,
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

    return Persona(
      id: _randomString(20),
      num_dormitorios: _randomFromList(dormitoriosOptions).toString(),
      name: _randomString(10),
      age: _randomInt(10, 60),
      gender: _randomBool() ? 'Hombre' : 'Mujer',
      nivelEduFam: _randomFromList(nivelEstudioFamOptions).toString(),
      num_integrantes: _randomInt(1, 10),
      integrantes_trabajando: _randomFromList(trabajandoOptions).toString(),
      num_autos: _randomFromList(autosOptions).toString(),
      baths: _randomFromList(bathsOptions).toString(),
      internet: _randomFromList(internetOptions).toString(),
      nivel_educativo: _randomString(5),
      tipo_escuela: _randomBool() ? 'Pública' : 'Privada',
      municipio: _randomString(5),
      sec_TamMad: _randomString(5),
      horario: _randomBool() ? 'Matutino' : 'Vespertino',
      aplicacion_libro: _randomBool() ? 'Si' : 'No',
      nombre_libro: _randomString(5),
      vida_saludable: _randomBool() ? 'Si' : 'No',
      enfermedades: _randomBool() ? 'Si' : 'No',
      peso: _randomInt(50, 90),
      estatura:
          double.tryParse(_randomDouble(1.50, 1.90).toStringAsFixed(2)) ?? 1.55,
      cintura: _randomInt(60, 120),
      cadera: _randomInt(80, 150),
      sistolica: _randomInt(90, 140),
      diastolica: _randomInt(60, 90),
      ap_mentales: _randomBool(),
      ap_resumen: _randomBool(),
      ap_mesaRedonda: _randomBool(),
      ap_conceptuales: _randomBool(),
      ap_cuestionarios: _randomBool(),
      ap_talleres: _randomBool(),
      ap_proyectos: _randomBool(),
      ap_organigrama: _randomBool(),
      ap_videos: _randomBool(),
      ap_diapos: _randomBool(),
      ap_juegos: _randomBool(),
      dad_work: _randomBool() ? 'Si' : 'No',
      mom_work: _randomBool() ? 'Si' : 'No',
      grado: _randomInt(1, 6).toString(),
      nombre_escuela: _randomString(5),
    );
  }

  Future<void> uploadRandomPersona() async {
    final persona = generateRandomPersona();
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').add(persona.toMap());
  }
}
