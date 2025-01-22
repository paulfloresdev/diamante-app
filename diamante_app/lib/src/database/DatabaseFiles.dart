import 'dart:io';
import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/models/auxiliars/Router.dart';
import 'package:diamante_app/src/views/LoadView.dart';
import 'package:diamante_app/src/views/OverView.dart';
import 'package:diamante_app/src/widgets/dialogs-snackbars/ConfirmDialog.dart';
import 'package:diamante_app/src/widgets/dialogs-snackbars/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class DatabaseFiles {
  
  Future<void> exportDatabase({required BuildContext context}) async {
    try {
      String jsonString = await DatabaseService.instance.exportToJson();
      String fileName = 'PE_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

      // Verificar permisos de almacenamiento
      if (await Permission.manageExternalStorage.request().isGranted ||
          await Permission.storage.request().isGranted) {

        // Ruta de la carpeta Docs
        var docsDirectory = Directory('/storage/emulated/0/Documents');

        final diamanteDirectory = Directory('${docsDirectory.path}/Diamante');

        if(!diamanteDirectory.existsSync()){
          diamanteDirectory.createSync(recursive: true);
        }

        // Ruta de la carpeta personalizada dentro de Documentos
        final targetDirectory = Directory('${diamanteDirectory.path}/Plantillas');

        // Crear la carpeta si no existe
        if (!targetDirectory.existsSync()) {
          targetDirectory.createSync(recursive: true);
          print("Carpeta 'Plantillas' creada en Documentos.");
        }

        // Crear y escribir el archivo JSON
        final file = File('${targetDirectory.path}/$fileName');
        await file.writeAsString(jsonString);
        print("Archivo JSON guardado en: ${file.path}");

        // Compartir el archivo utilizando share_plus
        Share.shareFiles([file.path], text: "Te comparto esta plantilla");
      } else {
        print("Permiso de almacenamiento denegado.");
      }
    } catch (e) {
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
    try{
      late Map<String, dynamic> collection;

      // Usar file_picker para seleccionar un archivo JSON
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      // Verificar si se seleccionó un archivo
      if (result != null) {
        // Obtener la ruta del archivo seleccionado
        String filePath = result.files.single.path!;

        // Leer el contenido del archivo JSON
        File file = File(filePath);
        String data = await file.readAsString();
        print('DATA:\n${data}\n\n\n');

        // Decodificar el JSON y actualizar el estado
        collection = json.decode(data);
        
        //  Limpia la DB
        await DatabaseService.instance.clearTables();
        
        //Extrae los datos de cada tabla
        Map<String, dynamic> configs = collection['configs'];
        List<dynamic> groups = collection['grupos'];
        List<dynamic> subgroups = collection['subgrupos'];
        List<dynamic> products = collection['productos'];

        //  Insert de configs
        await DatabaseService.instance.updateConfig(1,
          nombreCliente: configs['nombre_cliente'], 
          moneda: configs['moneda'], 
          porcentajeIVA: configs['iva_porcentaje'].toDouble(), 
          nombreEmpresa: configs['nombre_empresa'], 
          domicilio: configs['domicilio'],  
          cp: configs['cp'], 
          telefono: configs['telefono'], 
        );

        for (var group in groups) {
          //  Inserta el grupo y guarda su nuevo id
          int groupId = await DatabaseService.instance.createGrupo(group['nombre']);

          for (var subgroup in subgroups) {
            if(subgroup['grupo_id'] == group['id']){// Busca los subgrupos de este grupo
              //  Crea el subgrupo asignando el nuevo groupId y guarda su nuevo id
              int subgroupId = await DatabaseService.instance.createSubgrupo(
              subgroup['nombre'], groupId);

              for (var product in products) {
                if(product['subgrupo_id'] == subgroup['id']){// Busca los productos de este subgrupo
                  //  Crea los productos con el nuevo subgroupId
                  await DatabaseService.instance.createProducto(
                    concepto: product['concepto'],
                    tipoUnidad: product['tipo_unidad'],
                    precioUnitario: product['precio_unitario'].toDouble(),
                    cantidad: product['cantidad'],
                    importeTotal: product['importe_total'].toDouble(),
                    subgrupoId: subgroupId,
                  );
                }
              }
            }
            
          }
        }
        
        print('Base de datos reemplazada exitosamente.');
      } else {
        print('ARCHIVO SIN RESULT');
      }
    }catch(e){
      print('Error al importar en móvil: $e');
    }
  }
}
