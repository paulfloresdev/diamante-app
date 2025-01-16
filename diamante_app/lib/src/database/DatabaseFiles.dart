import 'dart:io';

import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class DatabaseFiles {
  final String dbPath =
      '/data/user/0/com.example.myapp/databases/app_database.db';

  Future<void> requestStoragePermission() async {
    // Solicitar permisos de almacenamiento
    var status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      print("Permiso de almacenamiento concedido");
    } else if (status.isDenied) {
      print("Permiso de almacenamiento denegado");
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> exportDatabase() async {
    // Solicitar permisos de almacenamiento antes de exportar
    await requestStoragePermission();

    try {
      // Localiza la base de datos
      final dbPath = '/data/user/0/com.example.diamante_app/databases/app_database.db';

      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        print('La base de datos no existe.');
        return;
      }

      // Solicita permiso para acceder a almacenamiento externo
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) {
        print('Permiso denegado para acceder al almacenamiento.');
        return;
      }

      // Copia el archivo a la carpeta Descargas
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) {
        print('No se encontró la carpeta Descargas.');
        return;
      }

      final exportPath =
          '${downloadDir.path}/Plantilla-exportada-${DateFormat('yyyy-MM-dd-hhmmss').format(DateTime.now())}.db';
      await dbFile.copy(exportPath);

      // Comparte el archivo exportado
      await Share.shareFiles([exportPath], text: 'Base de datos exportada');
      print('Base de datos exportada exitosamente a: $exportPath');
    } catch (e) {
      print('Error al exportar la base de datos: $e');
    }
  }

  
}