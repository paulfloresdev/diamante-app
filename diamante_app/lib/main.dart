import 'package:diamante_app/src/app.dart';
import 'package:diamante_app/src/database/WebDatabaseService.dart';
import 'package:flutter/material.dart';

void main() async {
  final databaseService = WebDatabaseService();

  // Inicializar la base de datos
  await databaseService.initializeDatabase();

  //  Inserta datos de prueba
  await databaseService.insertTestValue();

  var values = await databaseService.getTestValues();
  print('Valores en la base de datos: $values');

  runApp(const MainApp());
}