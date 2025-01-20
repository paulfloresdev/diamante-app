import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:diamante_app/src/models/auxiliars/Formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' as flutter_services;

class PdfWithSignature extends StatefulWidget {
  final Map<String, dynamic>? configData;
  final List<Map<String, dynamic>> contentTable;
  final List<dynamic> chunks;
  const PdfWithSignature({required this.configData, required this.contentTable, required this.chunks});

  @override
  _PdfWithSignatureState createState() => _PdfWithSignatureState();
}

class _PdfWithSignatureState extends State<PdfWithSignature> {
  late String folio;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
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
    return String.fromCharCodes(Iterable.generate(10, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(612, 792, marginAll: 30.6),
        build: (context) => pw.Column(
          children: [
            pw.Container(
              width: 550.8,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 300,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              'Cliente:',
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold
                              ),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              widget.configData!['nombre_cliente'],
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.normal
                              ),
                            ),
                          ]
                        ),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Fecha:',
                              textAlign: pw.TextAlign.start,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold
                              ),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              DateFormat('dd-MM-yyyy').format(DateTime.now()),
                              textAlign: pw.TextAlign.start,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.normal
                              ),
                            ),
                          ]
                        ),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Folio:',
                              textAlign: pw.TextAlign.start,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold
                              ),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              folio,
                              textAlign: pw.TextAlign.start,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.normal
                              ),
                            ),
                          ]
                        ),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Moneda:',
                              textAlign: pw.TextAlign.start,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold
                              ),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              widget.configData!['moneda'],
                              textAlign: pw.TextAlign.start,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.normal
                              ),
                            ),
                          ]
                        ),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          children: [
                            pw.Text(
                              'Empresa:',
                              textAlign: pw.TextAlign.start,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold
                              ),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              widget.configData!['nombre_empresa'],
                              textAlign: pw.TextAlign.start,
                              style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.normal
                              ),
                            ),
                          ]
                        ),
                      ]
                    ),
                  ),
                  
                  pw.SizedBox(width: 10),
                  pw.Container(
                    width: 240.8,
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
                            fontWeight: pw.FontWeight.normal
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'C.P. ${widget.configData!['cp']}',
                          textAlign: pw.TextAlign.end,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.normal
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          Formatter.phoneNumber(widget.configData!['telefono']),
                          textAlign: pw.TextAlign.end,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.normal
                          ),
                        ),
                      ]
                    ),
                  ),
                  
                ]
              ),
            ),
           
          ],
        ),
      ),

    );

    

    // Verificar permisos de almacenamiento
    if (await Permission.manageExternalStorage.request().isGranted) {
      final directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      final file = File("${directory.path}/$fileName");
      await file.writeAsBytes(await pdf.save());

      Share.shareFiles([file.path], text: "¡Mira este archivo PDF con firma! Folio: $folio");
    } else {
      print("Permiso de almacenamiento denegado.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generar PDF con Firma")),
      body: Column(
        children: [
          Expanded(
            child: Signature(
              controller: _signatureController,
              backgroundColor: Colors.grey[200]!,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _signatureController.clear();
                },
                child: Text("Limpiar"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_signatureController.isNotEmpty) {
                    final signature = await _signatureController.toPngBytes();
                    if (signature != null) {
                      await generateAndSharePdf(signature);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Por favor, firma antes de continuar.")),
                    );
                  }
                },
                child: Text("Generar PDF"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
