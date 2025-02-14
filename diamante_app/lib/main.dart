import 'package:diamante_app/src/app.dart';
import 'package:diamante_app/src/database/WebDatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para usar kIsWeb
import 'package:provider/provider.dart'; // Para usar Provider
import 'package:shared_preferences/shared_preferences.dart'; // Para gestionar la primera ejecución

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WebDatabaseService? webDatabaseService;

  if (kIsWeb) {
    webDatabaseService = WebDatabaseService();

    // Inicializar la base de datos
    await webDatabaseService.initializeDatabase();

    // Verificar si es la primera ejecución
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      // Insertar datos de prueba
      await webDatabaseService.insertTestValue();
      await prefs.setBool('isFirstRun', false);
      await prefs.setString('language', 'en');
    }

    var values = await webDatabaseService.getTestValues();
    print('Valores en la base de datos: $values');
  }

  runApp(
    MultiProvider(
      providers: [
        if (kIsWeb)
        Provider<WebDatabaseService>(
          create: (_) => webDatabaseService!,
        )
        else
          Provider<WebDatabaseService>(
            create: (_) => throw UnimplementedError('WebDatabaseService no está disponible en esta plataforma'),
          ),
      ],
      child: const MainApp(),
    ),
  );
}
