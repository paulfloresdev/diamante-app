import 'dart:io';
import 'dart:typed_data';

import 'package:diamante_app/src/database/WebDatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import '../models/auxiliars/Router.dart';
import '../views/LoadView.dart';
import '../views/OverView.dart';
import '../widgets/dialogs-snackbars/ConfirmDialog.dart';
import '../widgets/dialogs-snackbars/CustomSnackBar.dart';

class Webdatabasefiles {

  //  Exportar la DB
  Future<void> exportDatabase({required BuildContext context}) async {
    try{
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
    }catch(e){
      print('Error al exportar la base de datos: $e');
    }
  }

  Future<bool> _showDeleteConfirmationDialog(
      {required BuildContext context ,required String title, required String subTitle}) async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialog(
              title: title,
              subTitle: subTitle,
              confirmLabel: 'Reemplazar',
              confirmColor: Theme.of(context).primaryColorDark,
              declineLabel: 'Cancelar',
              declineColor: Colors.grey.shade700,
            );
          },
        )) ??
        false; // Devuelve false si el valor retornado es nulo
  }

  //  Importar la DB
  Future<void> importDatabase(BuildContext context) async {
    try {
      final WebDatabaseService databaseService =
          Provider.of<WebDatabaseService>(context, listen: false);
          
      late Map<String, dynamic> collection;

      // Usar file_picker para seleccionar un archivo JSON
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      // Verificar si se seleccionó un archivo
      if (result != null) {
        // Obtener los bytes del archivo seleccionado (usado en Web)
        Uint8List? fileBytes = result.files.single.bytes;

        // Verificar si los bytes son válidos
        if (fileBytes != null) {
          // Decodificar el contenido del archivo JSON
          String data = utf8.decode(fileBytes);
          print('DATA:\n${data}\n\n\n');

          // Decodificar el JSON y actualizar el estado
          collection = json.decode(data);

          // Limpiar la DB
          await databaseService.clearTables();

          // Extraer los datos de cada tabla
          Map<String, dynamic> configs = collection['configs'];
          List<dynamic> groups = collection['grupos'];
          List<dynamic> subgroups = collection['subgrupos'];
          List<dynamic> products = collection['productos'];

          // Insert de configs
          await databaseService.updateConfig(1,
            nombreCliente: configs['nombre_cliente'],
            moneda: configs['moneda'],
            porcentajeIVA: configs['iva_porcentaje'],
            nombreEmpresa: configs['nombre_empresa'],
            domicilio: configs['domicilio'],
            cp: configs['cp'],
            telefono: configs['telefono'],
          );

          for (var group in groups) {
            //  Inserta el grupo y guarda su nuevo id
            int groupId = await databaseService.createGrupo(group['nombre']);

            for (var subgroup in subgroups) {
              if(subgroup['grupo_id'] == group['id']){// Busca los subgrupos de este grupo
                //  Crea el subgrupo asignando el nuevo groupId y guarda su nuevo id
                int subgroupId = await databaseService.createSubgrupo(
                subgroup['nombre'], groupId);

                for (var product in products) {
                  if(product['subgrupo_id'] == subgroup['id']){// Busca los productos de este subgrupo
                    //  Crea los productos con el nuevo subgroupId
                    await databaseService.createProducto(
                      concepto: product['concepto'],
                      tipoUnidad: product['tipo_unidad'],
                      precioUnitario: product['precio_unitario'],
                      cantidad: product['cantidad'],
                      importeTotal: product['importe_total'],
                      subgrupoId: subgroupId,
                    );
                  }
                }
              }
              
            }
          }

          print('Base de datos reemplazada exitosamente.');
        } else {
          print('No se pudo leer el archivo.');
        }
      } else {
        print('ARCHIVO SIN RESULT');
      }
    } catch (e) {
      print('Error al importar en web: $e');
    }
  }

    
}