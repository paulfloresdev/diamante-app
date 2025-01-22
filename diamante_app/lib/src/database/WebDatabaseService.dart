import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
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
              is_selected INTEGER NOT NULL DEFAULT 0,
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
              iva_porcentaje REAL NOT NULL,
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
      'iva_porcentaje': 16.0,
      'nombre_empresa': 'Diamante Cabo San Lucas, S. de R.L. de C.V.',
      'domicilio':
          'Cabo San Lucas, Baja California Sur, México.', // Valor para domicilio
      'cp': '12345', // Valor para código postal
      'telefono': '1234567890', // Valor para teléfono
    });
  }

  Future<String> exportToJson() async {
    // Obtener todas las configs (esto es solo un ejemplo, debe adaptarse a tu base de datos)
    List<dynamic> configs = await _database.query('configs');
    List<dynamic> groups = await _database.query('grupos');
    List<dynamic> subgroups = await _database.query('subgrupos');
    List<dynamic> products = await _database.query('productos');

    Map<String, dynamic> data = {
      'export_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), // Formato de fecha
      'configs': configs.first, // Puedes dejarlo como está si configs ya está correctamente formateado
      'grupos': groups,
      'subgrupos': subgroups,
      'productos': products.map((product) {
        return {
          'id': product['id'],
          'concepto': product['concepto'],
          'tipo_unidad': product['tipo_unidad'],
          'precio_unitario': product['precio_unitario'],
          'cantidad': product['cantidad'],
          'importe_total': product['importe_total'],
          'is_selected': product['is_selected'],
          'subgrupo_id': product['subgrupo_id'],
        };
      }).toList(),
    };

    // Serializar el mapa a JSON válido
    String jsonString = jsonEncode(data); // Usa jsonEncode para convertirlo a un string JSON

    return jsonString;
  }


  /// Método para obtener datos de la tabla Test
  Future<List<Map<String, dynamic>>> getTestValues() async {
    return await _database.query('configs');
  }

  Future<Map<String, dynamic>?> getConfigById(int id) async {
    final List<Map<String, dynamic>> result = await _database.query(
      'configs',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> clearTables() async {
    try {
      // Eliminar datos de cada tabla
      await _database.delete('productos');
      await _database.delete('subgrupos');
      await _database.delete('grupos');

      // Limpiar la base de datos para reiniciar contadores
      await _database.execute('VACUUM;');

      print("Tablas vaciadas y contadores reiniciados correctamente.");
    } catch (e) {
      print("Error al vaciar las tablas: $e");
    }
  }

  Future<int> createConfig({required String nombreCliente,
    required String moneda,
    required double porcentajeIVA,
    required String nombreEmpresa,
    required String domicilio,
    required String cp,
    required String telefono,}) async {
    try{
      print('entre a crear config');
      return await _database.insert('configs', {
        'nombre_cliente': nombreCliente,
        'moneda': moneda,
        'iva_porcentaje': porcentajeIVA,
        'nombre_empresa': nombreEmpresa,
        'domicilio': domicilio,
        'cp': cp,
        'telefono': telefono,
      });
    }catch(e){ 
      print(e);
      throw Exception(e);
    }
    
  }

  Future<void> updateConfig(
    int id, {
    required String nombreCliente,
    required String moneda,
    required double porcentajeIVA,
    required String nombreEmpresa,
    required String domicilio,
    required String cp,
    required String telefono,
  }) async {
    await _database.update(
      'configs',
      {
        'nombre_cliente': nombreCliente,
        'moneda': moneda,
        'iva_porcentaje': porcentajeIVA,
        'nombre_empresa': nombreEmpresa,
        'domicilio': domicilio,
        'cp': cp,
        'telefono': telefono,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getFullSelection() async {
    // Consulta SQL para obtener los grupos y sus productos seleccionados
    final result = await _database.rawQuery('''
      SELECT 
        g.id AS grupo_id,
        g.nombre AS grupo_nombre,
        p.id AS producto_id,
        p.concepto AS producto_concepto,
        p.tipo_unidad AS producto_tipo_unidad,
        p.precio_unitario AS producto_precio_unitario,
        p.cantidad AS producto_cantidad,
        p.importe_total AS producto_importe_total,
        p.is_selected AS producto_is_selected,
        s.id AS subgrupo_id,
        s.nombre AS subgrupo_nombre
      FROM productos p
      INNER JOIN subgrupos s ON p.subgrupo_id = s.id
      INNER JOIN grupos g ON s.grupo_id = g.id
      WHERE p.is_selected = 1
      ORDER BY g.id, s.id, p.id
    ''');

    // Procesar los datos para estructurarlos en un mapa por grupo
    Map<int, Map<String, dynamic>> groups = {};
    double totalSum = 0.0; // Sumatoria general de todos los grupos

    for (var row in result) {
      int grupoId = row['grupo_id'] as int;
      double importeTotal = row['producto_importe_total'] as double;

      // Si el grupo no está en el mapa, se inicializa
      if (!groups.containsKey(grupoId)) {
        groups[grupoId] = {
          'grupo_id': grupoId,
          'grupo_nombre': row['grupo_nombre'],
          'productos': [],
          'sumatoria': 0.0, // Inicializar la sumatoria del grupo
        };
      }

      // Agregar el producto al grupo correspondiente
      groups[grupoId]!['productos'].add({
        'producto_id': row['producto_id'],
        'concepto': row['producto_concepto'],
        'tipo_unidad': row['producto_tipo_unidad'],
        'precio_unitario': row['producto_precio_unitario'],
        'cantidad': row['producto_cantidad'],
        'importe_total': importeTotal,
        'is_selected': row['producto_is_selected'],
        'subgrupo_id': row['subgrupo_id'],
        'subgrupo_nombre': row['subgrupo_nombre'],
      });

      // Sumar el importe_total al grupo y a la sumatoria general
      groups[grupoId]!['sumatoria'] += importeTotal;
      totalSum += importeTotal;
    }

    // Devolver los grupos con sus productos y sumatorias, junto con la sumatoria general
    return {
      'grupos': groups.values.toList(),
      'totalSum': totalSum,
    };
  }

  // CRUD para Grupos
  Future<int> createGrupo(String nombre) async {
    try {
      return await _database.insert('grupos', {'nombre': nombre});
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  Future<List<Map<String, dynamic>>> getAllGrupos() async {
    return await _database.query('grupos');
  }

  Future<int> updateGrupo(int id, String nuevoNombre) async {
    return await _database.update(
      'grupos',
      {'nombre': nuevoNombre},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGrupo(int id) async {
    return await _database.delete('grupos', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD para Subgrupos
  Future<int> createSubgrupo(String nombre, int grupoId) async {
    try {
      return await _database.insert('subgrupos', {
        'nombre': nombre,
        'grupo_id': grupoId,
      });
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  Future<List<Map<String, dynamic>>> getSubgruposByGrupo(int grupoId) async {
    return await _database
        .query('subgrupos', where: 'grupo_id = ?', whereArgs: [grupoId]);
  }

  Future<int> updateSubgrupo(int id, String nombre) async {
    return await _database.update(
      'subgrupos',
      {
        'nombre': nombre,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSubgrupo(int id) async {
    return await _database
        .delete('subgrupos', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> hasSelectedProducts(int subgrupoId) async {
    // Consulta a la base de datos
    final result = await _database.rawQuery('''
    SELECT COUNT(*) as count
    FROM productos
    WHERE subgrupo_id = ? AND is_selected = 1
  ''', [subgrupoId]);

    // Verifica si el resultado contiene algún registro
    if (result.isNotEmpty) {
      final count = result.first['count'] as int;
      return count >
          0; // Devuelve true si hay al menos un producto con is_selected = 0
    }

    return false; // Devuelve false si no se encontró ningún registro
  }

  Future<bool> groupHasSelectedProducts(int grupoId) async {
    // Consulta para verificar si hay productos seleccionados en el grupo especificado
    final result = await _database.rawQuery('''
    SELECT COUNT(*) as count
    FROM productos p
    INNER JOIN subgrupos s ON p.subgrupo_id = s.id
    WHERE s.grupo_id = ? AND p.is_selected = 1
  ''', [grupoId]);

    // Verifica si el resultado contiene algún registro
    if (result.isNotEmpty) {
      final count = result.first['count'] as int;
      return count >
          0; // Devuelve true si hay productos seleccionados en el grupo
    }

    return false; // Devuelve false si no se encontró ningún producto seleccionado en el grupo
  }

  Future<bool> otherSubgroupsHaveSelectedProducts(
      int excludedSubgrupoId, int grupoId) async {
    // Consulta para verificar si hay productos seleccionados en subgrupos diferentes al excluido dentro del mismo grupo
    final result = await _database.rawQuery('''
    SELECT COUNT(*) as count
    FROM productos p
    INNER JOIN subgrupos s ON p.subgrupo_id = s.id
    WHERE s.grupo_id = ? AND p.subgrupo_id != ? AND p.is_selected = 1
  ''', [grupoId, excludedSubgrupoId]);

    // Verifica si el resultado contiene algún registro
    if (result.isNotEmpty) {
      final count = result.first['count'] as int;
      return count >
          0; // Devuelve true si otros subgrupos tienen productos seleccionados
    }

    return false; // Devuelve false si no se encontró ningún producto seleccionado en otros subgrupos
  }

  // CRUD para Productos
  Future<int> createProducto({
    required String concepto,
    required String tipoUnidad,
    required double precioUnitario,
    required int cantidad,
    required double importeTotal,
    bool isSelected = false,
    required int subgrupoId,
  }) async {
    return await _database.insert('productos', {
      'concepto': concepto,
      'tipo_unidad': tipoUnidad,
      'precio_unitario': precioUnitario,
      'cantidad': cantidad,
      'importe_total': importeTotal,
      'is_selected': isSelected ? 1 : 0, // Convertimos booleano a 0/1.
      'subgrupo_id': subgrupoId,
    });
  }

  Future<int> updateProducto({
    required int id,
    required String concepto,
    required String tipoUnidad,
    required double precioUnitario,
    required int cantidad,
    required double importeTotal,
    required int subgrupoId,
  }) async {
    return await _database.update(
      'productos', // Nombre de la tabla
      {
        'concepto': concepto,
        'tipo_unidad': tipoUnidad,
        'precio_unitario': precioUnitario,
        'cantidad': cantidad,
        'importe_total': importeTotal,
        'subgrupo_id': subgrupoId,
      },
      where: 'id = ?', // Condición para encontrar el producto
      whereArgs: [id], // Argumentos para la condición
    );
  }

  Future<Map<String, dynamic>> getProductosBySubgrupo(int subgrupoId) async {
    // Obtener los productos del subgrupo
    final productos = await _database.query(
      'productos',
      where: 'subgrupo_id = ?',
      whereArgs: [subgrupoId],
    );

    // Calcular la sumatoria de importe_total
    double totalImporte = 0.0;
    for (var producto in productos) {
      totalImporte += (producto['importe_total'] as num).toDouble();
    }

    // Devolver tanto los productos como el total
    return {
      'productos': productos,
      'total_importe': totalImporte,
    };
  }

  Future<int> updateProductoSeleccion(int id, bool isSelected) async {
    return await _database.update(
      'productos',
      {'is_selected': isSelected ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getProductosSeleccionados(
      int subgrupoId) async {
    return await _database.query(
      'productos',
      where: 'subgrupo_id = ? AND is_selected = ?',
      whereArgs: [subgrupoId, 1],
    );
  }

  Future<int> deleteProducto(int id) async {
    return await _database
        .delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  /// Método para cerrar la base de datos
  Future<void> closeDatabase() async {
    await _database.close();
  }
}
