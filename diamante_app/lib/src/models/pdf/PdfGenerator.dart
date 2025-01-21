import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:diamante_app/src/models/auxiliars/Formatter.dart';
import 'package:diamante_app/src/models/auxiliars/Router.dart';
import 'package:diamante_app/src/views/OverView.dart';
import 'package:diamante_app/src/widgets/Buttons/CircularButton.dart';
import 'package:diamante_app/src/widgets/dialogs-snackbars/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' as flutter_services;

import '../auxiliars/Responsive.dart';

class PdfWithSignature extends StatefulWidget {
  final Map<String, dynamic>? configData;
  final List<Map<String, dynamic>> contentTable;
  final List<dynamic> chunks;
  const PdfWithSignature(
      {required this.configData,
      required this.contentTable,
      required this.chunks});

  @override
  _PdfWithSignatureState createState() => _PdfWithSignatureState();
}

class _PdfWithSignatureState extends State<PdfWithSignature> {
  late String folio;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.blue.shade800,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    folio = generateUniqueFolio();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  /// Genera un folio alfanumérico único
  String generateUniqueFolio() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  /// Crea el PDF con la firma y lo guarda en la carpeta de descargas
  Future<void> generateAndSharePdf(Uint8List signature) async {
    final pdf = pw.Document();
    final folio = generateUniqueFolio(); // Folio único
    final fileName = "$folio.pdf";

    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
    );

    // Crear contenido del PDF con la firma
    final image = pw.MemoryImage(signature);

    for (int p = 0; p < widget.chunks.length; p++) {
      var chunk = widget.chunks[p];
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat(612, 792, marginAll: 30.6),
        build: (context) => pw.Column(children: [
          p == p
              ? pw.Column(
                  children: [
                    pw.Container(
                      width: 550.8,
                      padding: pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: PdfColor(210 / 255, 210 / 255, 220 / 255),
                            width: 1.5),
                      ),
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: 294,
                              child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(children: [
                                      pw.Text(
                                        'Cliente:',
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.SizedBox(width: 5),
                                      pw.Text(
                                        widget.configData!['nombre_cliente'],
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.normal),
                                      ),
                                    ]),
                                    pw.SizedBox(height: 6),
                                    pw.Row(children: [
                                      pw.Text(
                                        'Fecha:',
                                        textAlign: pw.TextAlign.start,
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.SizedBox(width: 5),
                                      pw.Text(
                                        DateFormat('dd-MM-yyyy')
                                            .format(DateTime.now()),
                                        textAlign: pw.TextAlign.start,
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.normal),
                                      ),
                                    ]),
                                    pw.SizedBox(height: 6),
                                    pw.Row(children: [
                                      pw.Text(
                                        'Folio:',
                                        textAlign: pw.TextAlign.start,
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.SizedBox(width: 5),
                                      pw.Text(
                                        folio,
                                        textAlign: pw.TextAlign.start,
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.normal),
                                      ),
                                    ]),
                                    pw.SizedBox(height: 6),
                                    pw.Row(children: [
                                      pw.Text(
                                        'Moneda:',
                                        textAlign: pw.TextAlign.start,
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.SizedBox(width: 5),
                                      pw.Text(
                                        widget.configData!['moneda'],
                                        textAlign: pw.TextAlign.start,
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.normal),
                                      ),
                                    ]),
                                    pw.SizedBox(height: 6),
                                    pw.Row(children: [
                                      pw.Text(
                                        'Empresa:',
                                        textAlign: pw.TextAlign.start,
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.SizedBox(width: 5),
                                      pw.Text(
                                        widget.configData!['nombre_empresa'],
                                        textAlign: pw.TextAlign.start,
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.normal),
                                      ),
                                    ]),
                                  ]),
                            ),
                            pw.SizedBox(width: 10),
                            pw.Container(
                              width: 234.8,
                              child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  children: [
                                    pw.Image(
                                      logoImage,
                                      width: 112.9,
                                      height: 112.9,
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.Text(
                                      widget.configData!['domicilio'],
                                      textAlign: pw.TextAlign.end,
                                      style: pw.TextStyle(
                                          fontSize: 12,
                                          fontWeight: pw.FontWeight.normal),
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.Text(
                                      'C.P. ${widget.configData!['cp']}',
                                      textAlign: pw.TextAlign.end,
                                      style: pw.TextStyle(
                                          fontSize: 12,
                                          fontWeight: pw.FontWeight.normal),
                                    ),
                                    pw.SizedBox(height: 6),
                                    pw.Text(
                                      Formatter.phoneNumber(
                                          widget.configData!['telefono']),
                                      textAlign: pw.TextAlign.end,
                                      style: pw.TextStyle(
                                          fontSize: 12,
                                          fontWeight: pw.FontWeight.normal),
                                    ),
                                  ]),
                            ),
                          ]),
                    ),
                  ],
                )
              : pw.SizedBox(),
          pw.SizedBox(height: 12),
          pw.Column(
            children: chunk.map<pw.Widget>((item) {
              if (item['type'] == 'header') {
                return pw.Container(
                  width: 550.8,
                  height: 30,
                  color: PdfColor(111 / 255, 99 / 255, 94 / 255),
                  child: pw.Center(
                    child: pw.Text(
                      'DETALLE DE LA COTIZACIÓN',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColor(1, 1, 1),
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              if (item['type'] == 'titles' || item['type'] == 'content') {
                return pw.Column(children: [
                  pw.Container(
                      width: 550.8,
                      height: 30,
                      color: PdfColor(1, 1, 1),
                      child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            //Concepto
                            pw.Container(
                              width: 275.4,
                              padding: pw.EdgeInsets.symmetric(horizontal: 4.5),
                              child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  children: [
                                    pw.Flexible(
                                      child: pw.Text(
                                        textAlign: pw.TextAlign.left,
                                        item['type'] == 'titles'
                                            ? 'Concepto'
                                            : item['concepto'],
                                        style: pw.TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: item['type'] == 'titles'
                                              ? pw.FontWeight.bold
                                              : pw.FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                            //Tipo de unidad
                            pw.Container(
                              width: 100,
                              padding: pw.EdgeInsets.symmetric(horizontal: 4.5),
                              child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  children: [
                                    pw.Flexible(
                                      child: pw.Text(
                                        textAlign: pw.TextAlign.center,
                                        item['type'] == 'titles'
                                            ? 'Unidad'
                                            : item['tipo_unidad'],
                                        style: pw.TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: item['type'] == 'titles'
                                              ? pw.FontWeight.bold
                                              : pw.FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                            //Precio unitario
                            pw.Container(
                              width: 70,
                              padding: pw.EdgeInsets.symmetric(horizontal: 4.5),
                              child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  children: [
                                    pw.Flexible(
                                      child: pw.Text(
                                        textAlign: pw.TextAlign.center,
                                        item['type'] == 'titles'
                                            ? 'PU'
                                            : Formatter.money(
                                                item['precio_unitario']),
                                        style: pw.TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: item['type'] == 'titles'
                                              ? pw.FontWeight.bold
                                              : pw.FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                            //Cantidad
                            pw.Container(
                              width: 35.4,
                              padding: pw.EdgeInsets.symmetric(horizontal: 4.5),
                              child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  children: [
                                    pw.Flexible(
                                      child: pw.Text(
                                        textAlign: pw.TextAlign.center,
                                        item['type'] == 'titles'
                                            ? 'Cant'
                                            : item['cantidad'].toString(),
                                        style: pw.TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: item['type'] == 'titles'
                                              ? pw.FontWeight.bold
                                              : pw.FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                            //Importe total
                            pw.Container(
                              width: 70,
                              padding: pw.EdgeInsets.symmetric(horizontal: 4.5),
                              child: pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  children: [
                                    pw.Flexible(
                                      child: pw.Text(
                                        textAlign: pw.TextAlign.center,
                                        item['type'] == 'titles'
                                            ? 'Total'
                                            : Formatter.money(
                                                item['importe_total']),
                                        style: pw.TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: item['type'] == 'titles'
                                              ? pw.FontWeight.bold
                                              : pw.FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                          ])),
                  item['type'] == 'titles'
                      ? pw.Container(
                          width: 550.8,
                          height: 1.5,
                          color: PdfColor(210 / 255, 210 / 255, 220 / 255),
                        )
                      : pw.SizedBox(),
                ]);
              }
              if (item['type'] == 'group') {
                return pw.Container(
                  width: 550.8,
                  height: 30,
                  padding: pw.EdgeInsets.symmetric(horizontal: 4.5),
                  color: PdfColor(230 / 255, 230 / 255, 240 / 255),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        item['nombre'],
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        Formatter.money(item['sumatoria']),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (item['type'] == 'signature') {
                return pw.Column(children: [
                  pw.Image(
                    image,
                    width: 137.7 / 2,
                    height: 137.7 / 2,
                    fit: pw.BoxFit.fill,
                  ),
                  pw.Container(
                    width: 550.8,
                    child: pw.Center(
                      child: pw.Text(
                        widget.configData!['nombre_cliente'],
                        style: pw.TextStyle(
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 137.7,
                    height: 1.5,
                    color: PdfColor(0, 0, 0),
                  ),
                  pw.SizedBox(height: 1.5),
                  pw.Container(
                    width: 137.7,
                    child: pw.Center(
                      child: pw.Text(
                        'Nombre y firma del cliente',
                        style: pw.TextStyle(
                          fontSize: 10.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ]);
              }
              return pw.Container(
                width: 550.8,
                height: 30,
                padding: pw.EdgeInsets.symmetric(horizontal: 4.5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      '${item['label']} ${Formatter.money(item['value'])}',
                      style: pw.TextStyle(
                        fontSize: item['type'] == 'total' ? 13.5 : 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ]),
      ));
    }
    ;

    // Verificar permisos de almacenamiento
    if (await Permission.manageExternalStorage.request().isGranted) {
      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final file = File("${directory.path}/$fileName");
      await file.writeAsBytes(await pdf.save());

      Share.shareFiles([file.path],
          text: "¡Mira este archivo PDF con firma! Folio: $folio");
    } else {
      print("Permiso de almacenamiento denegado.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    double vw = responsive.viewportWidth;

    return Scaffold(
      backgroundColor: Theme.of(context).splashColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).splashColor,
        title: Row(
          children: [
            CircularButton(
                onPressed: () => Routes(context).goTo(OverView()),
                icon: Icons.arrow_back),
            Text("Captura de firma"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Signature(
              width: 137.7 * 2,
              height: 137.7 * 2,
              controller: _signatureController,
              backgroundColor: Theme.of(context).shadowColor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  _signatureController.clear();
                },
                child: Container(
                  width: 15 * vw,
                  height: 4 * vw,
                  padding: EdgeInsets.symmetric(horizontal: 1 * vw),
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: 1.2 * vw,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).splashColor,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                splashColor: Theme.of(context).hintColor,
                onTap: () async {
                  if (_signatureController.isNotEmpty) {
                    final signature = await _signatureController.toPngBytes();
                    if (signature != null) {
                      CustomSnackBar(context: context)
                          .show('Generando archivo...');

                      await generateAndSharePdf(signature);
                    }
                  } else {
                    CustomSnackBar(context: context)
                        .show('Por favor firma antes de continuar');
                  }
                },
                child: Container(
                  width: 15 * vw,
                  height: 4 * vw,
                  padding: EdgeInsets.symmetric(horizontal: 1 * vw),
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: Text(
                      'Firmar cotización',
                      style: TextStyle(
                        fontSize: 1.2 * vw,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).splashColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
