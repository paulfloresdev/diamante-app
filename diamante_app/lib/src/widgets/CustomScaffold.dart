import 'package:diamante_app/src/database/DatabaseFiles.dart';
import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/models/auxiliars/Router.dart';
import 'package:diamante_app/src/models/pdf/PdfGenerator.dart';
import 'package:diamante_app/src/views/ConfigsView.dart';
import 'package:diamante_app/src/widgets/NavBar.dart';
import 'package:flutter/material.dart';

import '../models/auxiliars/Responsive.dart';
import 'Buttons/CircularButton.dart';

class Customscaffold extends StatefulWidget {
  final int groupId;
  final Widget body;
  const Customscaffold({super.key, required this.groupId, required this.body});

  @override
  State<Customscaffold> createState() => _CustomscaffoldState();
}

class _CustomscaffoldState extends State<Customscaffold> {
  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    double vw = responsive.viewportWidth;

    return Scaffold(
      backgroundColor: Theme.of(context).splashColor,
      appBar: AppBar(
          backgroundColor: Theme.of(context).splashColor,
          automaticallyImplyLeading:
              false, // Desactiva el espacio reservado para leading
          titleSpacing: 0, // Elimina el padding entre leading y title
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.5 * vw),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo.png',
                    color: Theme.of(context).secondaryHeaderColor,
                    width: 7.5 * vw),
                SizedBox(width: 1.25 * vw),
                CircularButton(
                  onPressed: () async {
                    await DatabaseFiles().exportDatabase();
                  },
                  icon: Icons.arrow_upward_rounded,
                ),
                SizedBox(width: 0.25 * vw),
                CircularButton(
                  onPressed: () =>
                      DatabaseFiles().selectAndImportDatabase(context),
                  icon: Icons.arrow_downward_rounded,
                ),
                SizedBox(width: 0.25 * vw),
                CircularButton(
                  onPressed: () async {
                    Map<String, dynamic>? data =
                        await DatabaseService.instance.getConfigById(1);

                    if (data != {}) {
                      Routes(context).goTo(ConfigsView(
                          nombreCliente: data!['nombre_cliente'],
                          moneda: data!['moneda'],
                          ivaPorcentaje: data!['iva_porcentaje'],
                          nombreEmpresa: data!['nombre_empresa'],
                          domicilio: data!['domicilio'],
                          cp: data!['cp'],
                          telefono: data!['telefono']));
                    }
                  },
                  icon: Icons.settings_outlined,
                ),
                SizedBox(width: 0.25 * vw),
                /*CircularButton(
                    onPressed: () async {
                      var configData =
                          await DatabaseService.instance.getConfigById(1);
                      var contentData =
                          await DatabaseService.instance.getFullSelection();
                      var groups = contentData['grupos'];
                      var subtotal = contentData['totalSum'];
                      var iva = configData!['iva_porcentaje'] / 100;
                      var ivaValor = subtotal * iva;
                      var total = subtotal + ivaValor;

                      List<Map<String, dynamic>> contentTable = [
                        {'type': 'header'}
                      ];

                      for (int i = 0; i < groups.length; i++) {
                        contentTable.add({
                          'type': 'titles',
                        });
                        List<dynamic> products = groups[i]['productos'];
                        for (int j = 0; j < products.length; j++) {
                          contentTable.add({
                            'type': 'content',
                            'concepto': products[j]['concepto'],
                            'tipo_unidad': products[j]['tipo_unidad'],
                            'precio_unitario': products[j]['precio_unitario'],
                            'cantidad': products[j]['cantidad'],
                            'importe_total': products[j]['importe_total'],
                          });
                        }
                        contentTable.add({
                          'type': 'group',
                          'nombre': groups[i]['grupo_nombre'],
                          'sumatoria': groups[i]['sumatoria'],
                        });
                      }

                      contentTable.add({
                        'type': 'subtotal',
                        'label': 'Subtotal:',
                        'value': subtotal,
                      });
                      contentTable.add({
                        'type': 'iva',
                        'label': 'IVA (${iva * 100}%):',
                        'value': ivaValor,
                      });
                      contentTable.add({
                        'type': 'total',
                        'label': 'Total:',
                        'value': total,
                      });
                      contentTable.add({
                        'type': 'signature',
                      });

                      var chunks = [];
                      int chunkSize = 14;
                      for (var i = 0; i < contentTable.length; i += chunkSize) {
                        chunks.add(contentTable.sublist(
                            i,
                            i + chunkSize > contentTable.length
                                ? contentTable.length
                                : i + chunkSize));
                      }

                      print('Cantidad de chunks: ${chunks.length}');
                      for (int i = 0; i < chunks.length; i++) {
                        print('Chunk ${i + 1}: ${chunks[i].length} items');
                      }

                      Routes(context).goTo(PdfWithSignature(
                        configData: configData,
                        contentTable: contentTable,
                        chunks: chunks,
                      ));
                    },
                    icon: Icons.upload_file),*/
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(9.6 * vw),
            child: Navbar(
              groupId: widget.groupId,
            ),
          )),
      body: widget.body,
    );
  }
}
