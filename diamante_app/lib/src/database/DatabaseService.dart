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

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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
  }

  Future<List<Map<String, dynamic>>> getFullSelection() async {
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

  for (var row in result) {
    int grupoId = row['grupo_id'] as int;

    // Si el grupo no está en el mapa, se inicializa
    if (!groups.containsKey(grupoId)) {
      groups[grupoId] = {
        'grupo_id': grupoId,
        'grupo_nombre': row['grupo_nombre'],
        'productos': []
      };
    }

    // Agregar el producto al grupo correspondiente
    groups[grupoId]!['productos'].add({
      'producto_id': row['producto_id'],
      'concepto': row['producto_concepto'],
      'tipo_unidad': row['producto_tipo_unidad'],
      'precio_unitario': row['producto_precio_unitario'],
      'cantidad': row['producto_cantidad'],
      'importe_total': row['producto_importe_total'],
      'is_selected': row['producto_is_selected'],
      'subgrupo_id': row['subgrupo_id'],
      'subgrupo_nombre': row['subgrupo_nombre'],
    });
  }

  // Devolver la lista de grupos con sus productos seleccionados
  return groups.values.toList();
}


  Future<String> printDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    print('Database path: $databasesPath');
    return databasesPath;
  }

  // CRUD para Grupos
  Future<int> createGrupo(String nombre) async {
    final db = await instance.database;
    return await db.insert('grupos', {'nombre': nombre});
  }

  Future<List<Map<String, dynamic>>> getAllGrupos() async {
    final db = await instance.database;
    return await db.query('grupos');
  }

  Future<int> updateGrupo(int id, String nuevoNombre) async {
    final db = await instance.database;
    return await db.update(
      'grupos',
      {'nombre': nuevoNombre},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGrupo(int id) async {
    final db = await instance.database;
    return await db.delete('grupos', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD para Subgrupos
  Future<int> createSubgrupo(String nombre, int grupoId) async {
    final db = await instance.database;
    return await db.insert('subgrupos', {
      'nombre': nombre,
      'grupo_id': grupoId,
    });
  }

  Future<List<Map<String, dynamic>>> getSubgruposByGrupo(int grupoId) async {
    final db = await instance.database;
    return await db
        .query('subgrupos', where: 'grupo_id = ?', whereArgs: [grupoId]);
  }

  Future<int> updateSubgrupo(int id, String nombre) async {
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
    final db = await instance.database;
    return await db.delete('subgrupos', where: 'id = ?', whereArgs: [id]);
  }



Future<bool> hasSelectedProducts(int subgrupoId) async {
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
    return count > 0; // Devuelve true si hay al menos un producto con is_selected = 0
  }

  return false; // Devuelve false si no se encontró ningún registro
}

Future<bool> groupHasSelectedProducts(int grupoId) async {
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
    return count > 0; // Devuelve true si hay productos seleccionados en el grupo
  }

  return false; // Devuelve false si no se encontró ningún producto seleccionado en el grupo
}


Future<bool> otherSubgroupsHaveSelectedProducts(int excludedSubgrupoId, int grupoId) async {
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
    return count > 0; // Devuelve true si otros subgrupos tienen productos seleccionados
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

  Future<List<Map<String, dynamic>>> getProductosBySubgrupo(
      int subgrupoId) async {
    final db = await instance.database;
    return await db
        .query('productos', where: 'subgrupo_id = ?', whereArgs: [subgrupoId]);
  }

  Future<int> updateProductoSeleccion(int id, bool isSelected) async {
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
    final db = await instance.database;
    return await db.query(
      'productos',
      where: 'subgrupo_id = ? AND is_selected = ?',
      whereArgs: [subgrupoId, 1],
    );
  }

  Future<int> deleteProducto(int id) async {
    final db = await instance.database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}