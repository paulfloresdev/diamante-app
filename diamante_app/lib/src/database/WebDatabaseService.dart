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

          // Crear tabla de Grupos
          await db.execute(''' 
            CREATE TABLE IF NOT EXISTS grupos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL
            )
          ''');

          // Crear tabla de Subgrupos
          await db.execute(''' 
            CREATE TABLE IF NOT EXISTS subgrupos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              grupo_id INTEGER NOT NULL,
              FOREIGN KEY (grupo_id) REFERENCES grupos (id) ON DELETE CASCADE
            )
          ''');

          // Crear tabla de Productos
          await db.execute(''' 
            CREATE TABLE IF NOT EXISTS productos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              concepto TEXT NOT NULL,
              tipo_unidad TEXT NOT NULL,
              precio_unitario REAL NOT NULL,
              cantidad INTEGER NOT NULL,
              importe_total REAL NOT NULL,
              is_selected BOOLEAN NOT NULL DEFAULT 0,
              subgrupo_id INTEGER NOT NULL,
              FOREIGN KEY (subgrupo_id) REFERENCES subgrupos (id) ON DELETE CASCADE
            )
          ''');

          // Crear tabla de Configs
          await db.execute(''' 
            CREATE TABLE IF NOT EXISTS configs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre_cliente TEXT NOT NULL,
              moneda TEXT NOT NULL CHECK(moneda IN ('MXN', 'USD')),
              tipo_cambio REAL NOT NULL,
              iva_porcentaje REAL NOT NULL,
              aplicar_iva BOOLEAN NOT NULL,
              nombre_empresa TEXT,
              domicilio TEXT,            -- Nuevo campo domicilio
              cp TEXT,                   -- Nuevo campo código postal
              telefono TEXT              -- Nuevo campo teléfono
            )
          ''');
        },
      ),
    );
  }

  /// Método para insertar datos en la tabla Test
  Future<int> insertTestValue() async {
    return await _database.insert('configs', {
      'nombre_cliente': 'Cliente Predeterminado',
      'moneda': 'MXN',
      'tipo_cambio': 20.0, // Tipo de cambio predeterminado
      'iva_porcentaje': 16.0, // IVA predeterminado
      'aplicar_iva': true,
      'nombre_empresa': 'Diamante Cabo San Lucas, S. de R.L. de C.V.',
      'domicilio': 'Cabo San Lucas, Baja California Sur, México.',  // Valor para domicilio
      'cp': '12345',                    // Valor para código postal
      'telefono': '1234567890',          // Valor para teléfono
    });
  }

  /// Método para obtener datos de la tabla Test
  Future<List<Map<String, dynamic>>> getTestValues() async {
    return await _database.query('configs');
  }

  /// Método para cerrar la base de datos
  Future<void> closeDatabase() async {
    await _database.close();
  }
}
