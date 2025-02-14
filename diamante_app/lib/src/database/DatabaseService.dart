import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(
    String filePath,
  ) async {
    print('POR ALGUNA RAZON ENTRE AQUÍ');
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<dynamic> checkOrigin(String msg) async {
    print(msg);
    final db = await instance.database;
  }

  Future<void> _createDB(Database db, int version) async {
    // Crear tabla de Grupos
    await db.execute('''
      CREATE TABLE grupos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    // Crear tabla de Subgrupos
    await db.execute('''
      CREATE TABLE subgrupos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        grupo_id INTEGER NOT NULL,
        FOREIGN KEY (grupo_id) REFERENCES grupos (id) ON DELETE CASCADE
      )
    ''');

    // Crear tabla de Productos
    await db.execute('''
      CREATE TABLE productos (
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
      CREATE TABLE configs (
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

    // Insertar un registro predeterminado en la tabla de Configs
    await db.insert('configs', {
      'nombre_cliente': 'Cliente Predeterminado',
      'moneda': 'MXN',
      'iva_porcentaje': 16.0, // IVA predeterminado
      'nombre_empresa': 'Rancho San Lucas',
      'domicilio':
          'Cabo San Lucas, Baja California Sur, México.', // Valor para domicilio
      'cp': '12345', // Valor para código postal
      'telefono': '1234567890', // Valor para teléfono
    });
  }

  Future<String> exportToJson() async {
    final db = await instance.database;

    // Obtener todas las configs
    List<Map<String, dynamic>> configs = await db.query('configs');

    // Obtener todas las configs de otros datos
    List<Map<String, dynamic>> groups = await db.query('grupos');
    List<Map<String, dynamic>> subgroups = await db.query('subgrupos');
    List<Map<String, dynamic>> products = await db.query('productos');

    // Convertir a Map<String, dynamic>
    Map<String, dynamic> data = {
      "export_date": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),  // Formato de fecha
      'configs': configs.first,  // Asegúrate de que esta lista esté bien formateada
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
          // Agregar más campos si es necesario
        };
      }).toList(),
    };

    // Convertir el mapa a un string JSON
    String jsonString = jsonEncode(data);  // Utiliza jsonEncode en lugar de toString
    return jsonString;
  }

  Future<void> clearTables() async {
    try {
      final db = await instance.database;
      
      await db.delete('productos');
      await db.execute('DELETE FROM sqlite_sequence WHERE name = "productos"');

      await db.delete('subgrupos');
      await db.execute('DELETE FROM sqlite_sequence WHERE name = "subgrupos"');

      await db.delete('grupos');
      await db.execute('DELETE FROM sqlite_sequence WHERE name = "grupos"');

      print("Tablas vaciadas correctamente.");
    } catch (e) {
      print("Error al vaciar las tablas': $e");
    }
  }

  Future<int> createConfig({required String nombreCliente,
    required String moneda,
    required double porcentajeIVA,
    required String nombreEmpresa,
    required String domicilio,
    required String cp,
    required String telefono,}) async {
    print('Ejecutado: createGrupo');
    final db = await instance.database;
    return await db.insert('configs', {
      'nombre_cliente': nombreCliente,
      'moneda': moneda,
      'iva_porcentaje': porcentajeIVA,
      'nombre_empresa': nombreEmpresa,
      'domicilio': domicilio,
      'cp': cp,
      'telefono': telefono,
    });
  }

  Future<Map<String, dynamic>?> getConfigById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'configs',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
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
    final db = await instance.database;
    await db.update(
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
    final db = await instance.database;

    // Consulta SQL para obtener los grupos y sus productos seleccionados
    final result = await db.rawQuery('''
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

  Future<String> printDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    print('Database path: $databasesPath');
    return databasesPath;
  }

  // CRUD para Grupos
  Future<int> createGrupo(String nombre) async {
    print('Ejecutado: createGrupo');
    final db = await instance.database;
    return await db.insert('grupos', {'nombre': nombre});
  }

  Future<List<Map<String, dynamic>>> getAllGrupos() async {
    print('Ejecutado: getAllGrupos');
    final db = await instance.database;
    return await db.query('grupos');
  }

  Future<int> updateGrupo(int id, String nuevoNombre) async {
    print('Ejecutado: UpdateGrupo');
    final db = await instance.database;
    return await db.update(
      'grupos',
      {'nombre': nuevoNombre},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGrupo(int id) async {
    print('Ejecutado: deleteGrupo');
    final db = await instance.database;
    return await db.delete('grupos', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD para Subgrupos
  Future<int> createSubgrupo(String nombre, int grupoId) async {
    print('Ejecutado: createSubgrupo');
    final db = await instance.database;
    return await db.insert('subgrupos', {
      'nombre': nombre,
      'grupo_id': grupoId,
    });
  }

  Future<List<Map<String, dynamic>>> getSubgruposByGrupo(int grupoId) async {
    print('Ejecutado: getSubgruposByGrupo');
    final db = await instance.database;
    return await db
        .query('subgrupos', where: 'grupo_id = ?', whereArgs: [grupoId]);
  }

  Future<int> updateSubgrupo(int id, String nombre) async {
    print('Ejecutado: updateSubgrupo');
    final db = await instance.database;
    return await db.update(
      'subgrupos',
      {
        'nombre': nombre,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSubgrupo(int id) async {
    print('Ejecutado: deleteSubgrupo');
    final db = await instance.database;
    return await db.delete('subgrupos', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> hasSelectedProducts(int subgrupoId) async {
    print('Ejecutado: hasSelectedProducts');
    final db = await instance.database;
    // Consulta a la base de datos
    final result = await db.rawQuery('''
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
    print('Ejecutado: groupHasSelectedProducts');
    final db = await instance.database;

    // Consulta para verificar si hay productos seleccionados en el grupo especificado
    final result = await db.rawQuery('''
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
    print('Ejecutado: otherSubgroupsHaveSelectedProducts');
    final db = await instance.database;

    // Consulta para verificar si hay productos seleccionados en subgrupos diferentes al excluido dentro del mismo grupo
    final result = await db.rawQuery('''
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
    print('Ejecutado: createProducto');
    final db = await instance.database;

    return await db.insert('productos', {
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
    print('Ejecutado: updateProducto');
    final db = await instance.database;

    return await db.update(
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
    print('Ejecutado: getProductosBySubgrupo');
    final db = await instance.database;

    // Obtener los productos del subgrupo
    final productos = await db.query(
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
    print('Ejecutado: updateProductoSeleccion');
    final db = await instance.database;
    return await db.update(
      'productos',
      {'is_selected': isSelected ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getProductosSeleccionados(
      int subgrupoId) async {
    print('Ejecutado: getProductosSeleccionados');
    final db = await instance.database;
    return await db.query(
      'productos',
      where: 'subgrupo_id = ? AND is_selected = ?',
      whereArgs: [subgrupoId, 1],
    );
  }

  Future<int> deleteProducto(int id) async {
    print('Ejecutado: deleteProducto');
    final db = await instance.database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
