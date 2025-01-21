import 'dart:io';

import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class DatabaseFiles {
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

  /*Future<List<int>> deleteSelection() async{
    List<int> productIds = [];

    await DatabaseService.instance.

    return productIds;
  }*/

  Future<void> exportDatabase() async {
    // Solicitar permisos de almacenamiento antes de exportar
    await requestStoragePermission();

    try {
      // Localiza la base de datos
      final dbPath =
          '/data/user/0/com.example.diamante_app/databases/app_database.db';

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

  Future<void> selectAndImportDatabase(BuildContext context) async {
    final dbPath =
        '/data/user/0/com.example.diamante_app/databases/app_database.db';

    try {
      // Select the .db file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Se puede seleccionar cualquier archivo
      );

      if (result != null) {
        // Path of the selected file
        String selectedFilePath = result.files.single.path!;
        print('Selected file: $selectedFilePath');

        // Show confirmation dialog before replacing the database
        bool shouldReplaceDatabase = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmar reemplazo'),
              content: Text(
                '¿Deseas reemplazar la base de datos actual con la nueva plantilla seleccionada? Esta acción eliminará la base de datos actual.',
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Don't replace or close the app
                  },
                ),
                TextButton(
                  child: Text('Reemplazar'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Proceed with replacing the database
                  },
                ),
              ],
            );
          },
        );

        // If the user confirmed, proceed with replacing the database
        if (shouldReplaceDatabase) {
          // Check if the selected file exists
          final importedFile = File(selectedFilePath);
          if (!importedFile.existsSync()) {
            throw Exception('The selected file does not exist.');
          }

          // Check if the destination database exists and remove it
          final destinationFile = File(dbPath);
          if (destinationFile.existsSync()) {
            print('Deleting existing database at: $dbPath');
            destinationFile.deleteSync();
          }

          // Copy the file to the database location
          importedFile.copySync(dbPath);
          print('Database copied to: $dbPath');

          // Verify the database has been copied
          if (destinationFile.existsSync()) {
            print('Database imported successfully.');

            // Show confirmation dialog before closing the app
            bool shouldCloseApp = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Plantilla Importada'),
                  content: Text(
                      'La plantilla ha sido importada con éxito. La app se cerrará ahora.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cerrar app'),
                      onPressed: () {
                        Navigator.of(context).pop(true); // Close the app
                      },
                    ),
                  ],
                );
              },
            );

            // If the user confirmed, close the app
            if (shouldCloseApp) {
              SystemNavigator.pop(); // This will close the app
            }
          } else {
            throw Exception('Error importing the database.');
          }
        } else {
          print('Database import canceled.');
        }
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('Error during database import: $e');
    }
  }
}
