import 'dart:convert';
import 'dart:io';
import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/database/WebDatabaseService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart' as html;
import 'package:universal_html/html.dart' as html;

class DatabaseFiles {
  Future<void> exportDatabase({required BuildContext context}) async {
    try {
      if (kIsWeb) {
        final WebDatabaseService databaseService =
            Provider.of<WebDatabaseService>(context, listen: false);
        String jsonString = await databaseService.exportToJson();

        final blob = html.Blob([jsonString]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = 'plantilla-exportada-${DateTime.now()}.json'
          ..click();
        html.Url.revokeObjectUrl(url); // Limpieza de memoria
        print("Archivo JSON descargado en la web.");
      } else {
        // Manejo para dispositivos móviles
        String jsonString = await DatabaseService.instance.exportToJson();

        if (await Permission.manageExternalStorage.request().isGranted) {
          // Crear un archivo temporal en el dispositivo
          final tempFile = File(
              '${Directory.systemTemp.path}/plantilla-exportada-${DateTime.now()}.json');

          // Escribir el JSON en el archivo
          await tempFile.writeAsString(jsonString);

          // Compartir el archivo utilizando share_plus
          Share.shareFiles([tempFile.path],
              text: "¡Mira este archivo JSON exportado!");
          print("Archivo JSON compartido en el dispositivo móvil.");
        } else {
          print("Permiso de almacenamiento denegado.");
        }
      }
    } catch (e) {
      print('Error al exportar la base de datos: $e');
    }
  }

  Future<void> _exportDatabaseForMobile() async {
    // Solicitar permisos de almacenamiento
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      print('Permiso denegado para acceder al almacenamiento.');
      return;
    }

    try {
      // Localizar la base de datos en el dispositivo
      final dbPath = '/data/user/0/com.example.app/databases/app_database.db';
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        print('La base de datos no existe.');
        return;
      }

      // Ruta para guardar el archivo exportado
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (!await downloadDir.exists()) {
        print('No se encontró la carpeta Descargas.');
        return;
      }

      final exportPath =
          '${downloadDir.path}/database-export-${DateFormat('yyyy-MM-dd-hhmmss').format(DateTime.now())}.db';
      await dbFile.copy(exportPath);

      // Compartir el archivo exportado
      await Share.shareFiles([exportPath], text: 'Base de datos exportada');
      print('Base de datos exportada exitosamente a: $exportPath');
    } catch (e) {
      print('Error al exportar la base de datos en móvil: $e');
    }
  }
}
