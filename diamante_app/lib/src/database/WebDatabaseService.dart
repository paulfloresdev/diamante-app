import 'dart:async';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class WebDatabaseService {
  late Database _database;

  /// Método para inicializar la base de datos
  Future<void> initializeDatabase() async {
    var databaseFactory = databaseFactoryFfiWeb;

    // Crear o abrir la base de datos
    _database = await databaseFactory.openDatabase(
      'app_database.db',
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          // Crear las tablas necesarias
          await db.execute(
            'CREATE TABLE IF NOT EXISTS Test (id INTEGER PRIMARY KEY AUTOINCREMENT, value TEXT)',
          );
        },
      ),
    );
  }

  /// Método para insertar datos en la tabla Test
  Future<int> insertTestValue(String value) async {
    return await _database.insert('Test', {'value': value});
  }

  /// Método para obtener datos de la tabla Test
  Future<List<Map<String, dynamic>>> getTestValues() async {
    return await _database.query('Test');
  }

  /// Método para cerrar la base de datos
  Future<void> closeDatabase() async {
    await _database.close();
  }
}
