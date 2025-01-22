import 'package:animate_do/animate_do.dart';
import 'package:diamante_app/src/database/DatabaseFiles.dart';
import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/database/WebDatabaseFiles.dart';
import 'package:diamante_app/src/models/auxiliars/Router.dart';
import 'package:diamante_app/src/models/pdf/PdfGenerator.dart';
import 'package:diamante_app/src/views/ConfigsView.dart';
import 'package:diamante_app/src/views/OverView.dart';
import 'package:diamante_app/src/widgets/NavBar.dart';
import 'package:diamante_app/src/widgets/dialogs-snackbars/CustomSnackBar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/WebDatabaseService.dart';
import '../models/auxiliars/Responsive.dart';
import 'Buttons/CircularButton.dart';
import 'dialogs-snackbars/ConfirmDialog.dart';

class Customscaffold extends StatefulWidget {
  final int groupId;
  final Widget body;
  const Customscaffold({super.key, required this.groupId, required this.body});

  @override
  State<Customscaffold> createState() => _CustomscaffoldState();
}

class _CustomscaffoldState extends State<Customscaffold> {
  late var webDatabaseService;
  late var isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
    webDatabaseService = kIsWeb ?
        Provider.of<WebDatabaseService>(context, listen: false) : null;
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

  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    double vw = responsive.viewportWidth;

    if(isLoading){
      return Scaffold(
        backgroundColor: Theme.of(context).splashColor,
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeIn(
                duration: const Duration(milliseconds: 2000),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 25 * vw,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              SizedBox(height: 2.5*vw),
              SizedBox(
                width: 3 * vw, // Ajusta el ancho
                height: 3 * vw, // Ajusta la altura
                child: CircularProgressIndicator(
                  strokeWidth: 0.6 * vw, // Ajusta el grosor
                  color: Theme.of(context).shadowColor,
                ),
              )

            ],
          ),
        ));
    }

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
                widget.groupId == 0 ? CircularButton(
                  onPressed: () async {
                    //AQUÍ
                    if(kIsWeb){
                      Webdatabasefiles().exportDatabase(context: context);
                    }else{
                      DatabaseFiles().exportDatabase(context: context);
                    }
                  },
                  icon: Icons.arrow_upward_rounded,
                ) : SizedBox(),
                SizedBox(width: 0.25 * vw),
                widget.groupId == 0 ? CircularButton(
                  onPressed: () async {
                    if(await _showDeleteConfirmationDialog(context: context, title: 'Reemplazar base de datos', subTitle: '¿Estás seguro de reemplazar la base de datos?, todos actuales se perderán.')){
                      setState(() {
                        isLoading = true;
                      });
                      if(kIsWeb){
                        await Webdatabasefiles().importDatabase(context);
                      }else{
                        await DatabaseFiles().importDatabase(context);
                      }
                      CustomSnackBar(context: context).show('Base de datos reemplazada exitosamente.');
                      setState(() {
                        isLoading = false;
                      });
                    }else{
                      print('No se reemplazará');
                    }
                    Routes(context).goTo(OverView());
                  },
                  icon: Icons.arrow_downward_rounded,
                ) : SizedBox(),
                SizedBox(width: 0.25 * vw),
                widget.groupId == 0 ? CircularButton(
                  onPressed: () async {
                    Map<String, dynamic>? data = kIsWeb
                        ? await webDatabaseService.getConfigById(1)
                        : await DatabaseService.instance.getConfigById(1);

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
                ) : SizedBox(),
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
