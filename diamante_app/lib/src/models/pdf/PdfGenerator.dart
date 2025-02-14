import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:diamante_app/src/models/auxiliars/Formatter.dart';
import 'package:diamante_app/src/models/auxiliars/Router.dart';
import 'package:diamante_app/src/models/pdf/PdfWeb.dart';
import 'package:diamante_app/src/views/OverView.dart';
import 'package:diamante_app/src/widgets/Buttons/CircularButton.dart';
import 'package:diamante_app/src/widgets/dialogs-snackbars/CustomSnackBar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:share_plus/share_plus.dart';


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
    penStrokeWidth: 4.5,
    penColor: Colors.blue.shade800,
    exportBackgroundColor: Colors.white,
  );

  String language = 'en'; // Asignar un valor predeterminado para evitar errores

  getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      language = prefs.getString('language') ?? 'en';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLanguage();
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
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              widget.configData!['nombre_empresa'],
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              '${widget.configData!['domicilio']} ${widget.configData!['cp']}',
                              style: pw.TextStyle(
                                fontSize: 11,
                              ),
                            ),
                            pw.Text(
                              Formatter.phoneNumber(
                                  widget.configData!['telefono']),
                              style: pw.TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        pw.Image(
                          logoImage,
                          width: 90,
                          height: 90,
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  language == 'en' ? 'Date' : 'Fecha',
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  DateFormat('MM/dd/yyyy')
                                      .format(DateTime.now()),
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                                pw.SizedBox(height: 5.5),
                                pw.Text(
                                  language == 'en' ? 'Client' : 'Cliente',
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  widget.configData!['nombre_cliente'],
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            pw.Text(
                              folio,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      width: 550.8,
                      height: 1.5,
                      color: PdfColor(230 / 255, 230 / 255, 240 / 255),
                    ),
                    pw.SizedBox(height: 16),
                  ],
                )
              : pw.SizedBox(),
          pw.SizedBox(height: 12),
          pw.Column(
            children: chunk.map<pw.Widget>((item) {
              if (item['type'] == 'header') {
                return pw.Column(children: [
                  pw.Container(
                    width: 550.8,
                    height: 30,
                    child: pw.Center(
                      child: pw.Text(
                        item['label'],
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 550.8,
                    height: 1.5,
                    color: PdfColor(230 / 255, 230 / 255, 240 / 255),
                  ),
                ]);
              }
              if (item['type'] == 'titles' || item['type'] == 'content') {
                return pw.Column(children: [
                  pw.Container(
                      width: 550.8,
                      height: 31.5,
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
                                            ? language == 'en'
                                                ? 'Description'
                                                : 'Concepto'
                                            : item['concepto'],
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          color: PdfColor(0.45, 0.45, 0.45),
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
                                            ? language == 'en'
                                                ? 'Unit'
                                                : 'Unidad'
                                            : item['tipo_unidad'],
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          color: PdfColor(0.45, 0.45, 0.45),
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
                                            ? language == 'en'
                                                ? 'UP'
                                                : 'PU'
                                            : Formatter.money(
                                                item['precio_unitario']),
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          color: PdfColor(0.45, 0.45, 0.45),
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
                                            ? language == 'en'
                                                ? 'Amt'
                                                : 'Cant'
                                            : item['cantidad'].toString(),
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          color: PdfColor(0.45, 0.45, 0.45),
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
                                          fontSize: 10,
                                          color: PdfColor(0.45, 0.45, 0.45),
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
                return pw.Column(children: [
                  pw.Container(
                    width: 550.8,
                    height: 28.5,
                    padding: pw.EdgeInsets.symmetric(horizontal: 4.5),
                    color: item['subtype'] == 'resumen'
                        ? PdfColor(1, 1, 1)
                        : PdfColor(1, 1, 1),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          item['nombre'],
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: item['subtype'] == 'resumen'
                                ? pw.FontWeight.bold
                                : pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          Formatter.money(item['sumatoria']),
                          style: pw.TextStyle(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    width: 550.8,
                    height: 1.5,
                    color: PdfColor(230 / 255, 230 / 255, 240 / 255),
                  )
                ]);
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
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ]);
              }

              if (item['type'] == 'space') {
                return pw.SizedBox(
                  height: 30,
                );
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
                      '${item['label']} ',
                      style: pw.TextStyle(
                        fontSize: item['type'] == 'total' ? 11 : 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      Formatter.money(item['value']),
                      style: pw.TextStyle(
                        fontSize: item['type'] == 'total' ? 12 : 11,
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
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat(612, 792, marginAll: 30.6),
        build: (context) => pw.Column(
              children: [
                language == 'en'
                    ? pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'Prices shown above are in ${widget.configData!['moneda']} and the final exchange rate to consider for the payment will be determined on the date when Client authorizes this quote.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'Prices include all importation fees and taxes.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'All quotes are valid only for 30 (Thirty) natural days, starting to count on the proposal date.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'Authorization of the quote and its payment must be done in full during this valid period.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'If payment is not made during this valid period, conveyance date shall be automatically extended in the same number of days payment is late.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'Client agrees with colors, finishes and pricing listed above.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'Client accepts that any refund is only valid within the next 5 (Five) natural days after having paid the quote.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'Client understands that each item is custom made and once work has begun, no changes, cancelations or returns will be allowed.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'Client understands and acknowledges that prices shown in this quote are an estimate and may vary during the process of selection and until final project, according to client selections.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                            'Client will be notified of any changes in cost prior to them being incurred.',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            'PAYMENT INFORMATION:',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            'MXN ACCOUNT',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Beneficiary Bank: SANTANDER (MÉXICO) S.A.',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Bank Address: 0302 CABO SAN LUCAS',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Swift Code: BMSXMXMMXXX',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Beneficiary: RANCHO REAL ESTATE, S.A. DE C.V.',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Beneficiary Account: 014041655053161121',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            'USD ACCOUNT',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Beneficiary Bank: CITI COMMERCIAL BANK',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Bank Address: #653 740 LOMAS SANTA FE DR. SOLANA BEACH, CALIFORNIA. ZIP. 92075',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'ABA: 322 271 724',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Swift Code: CITIUS33',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Beneficiary: RANCHO REAL ESTATE, S.A. DE C.V.',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Beneficiary Account: 207849431',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            'SIGN OF ACCEPTANCE',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Image(
                            image,
                            width: 90,
                            height: 90,
                          ),
                          pw.Container(
                            width: 180,
                            height: 1.5,
                            color: PdfColor(210 / 255, 210 / 255, 220 / 255),
                          ),
                          pw.Text(
                            widget.configData!['nombre_cliente'],
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            'SIGNED AND AGREED ON',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            DateFormat('MM/dd/yyyy').format(DateTime.now()),
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Container(
                            width: 180,
                            height: 1.5,
                            color: PdfColor(210 / 255, 210 / 255, 220 / 255),
                          ),
                          pw.Text(
                            'Date of acceptance',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      )
                    : pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'Los precios mostrados arriba están en ${widget.configData!['moneda']} y la tasa de cambio final a considerar para el pago será determinada en la fecha en que el Cliente autorice esta cotización.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'Los precios incluyen todas las tarifas de importación e impuestos.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'Todas las cotizaciones son válidas únicamente por 30 (Treinta) días naturales, comenzando a contar desde la fecha de la propuesta.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'La autorización de la cotización y su pago deben realizarse en su totalidad durante este periodo válido.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'Si el pago no se realiza durante este periodo válido, la fecha de entrega se extenderá automáticamente por el mismo número de días que el pago esté retrasado.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'El Cliente acepta los colores, acabados y precios listados anteriormente.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'El Cliente acepta que cualquier reembolso solo es válido dentro de los próximos 5 (Cinco) días naturales después de haber pagado la cotización.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'El Cliente entiende que cada artículo es hecho a medida y, una vez iniciado el trabajo, no se permitirán cambios, cancelaciones ni devoluciones.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'El Cliente entiende y reconoce que los precios mostrados en esta cotización son una estimación y pueden variar durante el proceso de selección hasta el proyecto final, de acuerdo con las elecciones del cliente.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.Text(
                              'El Cliente será notificado de cualquier cambio en el costo antes de que se incurra en ellos.',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.SizedBox(height: 16),
                          pw.Text('INFORMACIÓN DE PAGO:',
                              style: pw.TextStyle(
                                fontSize: 10,
                              )),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            'CUENTA EN PESOS MEXICANO',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Banco del eneficiario: SANTANDER (MÉXICO) S.A.',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Dirección del banco: 0302 CABO SAN LUCAS',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Código swift: BMSXMXMMXXX',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Beneficiario: RANCHO REAL ESTATE, S.A. DE C.V.',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Cuenta del beneficiairo: 014041655053161121',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            'CUENTA EN DOLARES AMERICANOS',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Banco del beneficiario: CITI COMMERCIAL BANK',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Dirección del banco: #653 740 LOMAS SANTA FE DR. SOLANA BEACH, CALIFORNIA. ZIP. 92075',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'ABA: 322 271 724',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Código swift: CITIUS33',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Beneficiario: RANCHO REAL ESTATE, S.A. DE C.V.',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'Cuenta del beneficiario: 207849431',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            'FIRMA DE ACEPTACIÓN',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Image(
                            image,
                            width: 45,
                            height: 45,
                          ),
                          pw.Container(
                            width: 180,
                            height: 1.5,
                            color: PdfColor(210 / 255, 210 / 255, 220 / 255),
                          ),
                          pw.Text(
                            widget.configData!['nombre_cliente'],
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            'FIRMADO Y ACEPTADO EL',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            DateFormat('MM/dd/yyyy').format(DateTime.now()),
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                          pw.Container(
                            width: 180,
                            height: 1.5,
                            color: PdfColor(210 / 255, 210 / 255, 220 / 255),
                          ),
                          pw.Text(
                            'Fecha de aceptación',
                            style: pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
              ],
            )));

    if (kIsWeb) {
      // Manejo específico para la web
      Pdfweb().download(await pdf.save(), fileName);
      
    } else {
      // Manejo para móviles
      // Verificar permisos de almacenamiento
      if (await Permission.manageExternalStorage.request().isGranted) {
        // Ruta de la carpeta Docs
        var docsDirectory = Directory('/storage/emulated/0/Documents');

        final diamanteDirectory = Directory('${docsDirectory.path}/RanchoSL');

        if(!diamanteDirectory.existsSync()){
          diamanteDirectory.createSync(recursive: true);
        }

        // Ruta de la carpeta personalizada dentro de Descargas
        final targetDirectory = Directory('${diamanteDirectory.path}/Cotizaciones');

        // Crear la carpeta si no existe
        if (!targetDirectory.existsSync()) {
          targetDirectory.createSync(recursive: true);
          print("Carpeta 'Cotizaciones' creada en Descargas.");
        }


        final file = File("${targetDirectory.path}/$fileName");
        await file.writeAsBytes(await pdf.save());

        Share.shareFiles([file.path],
            text: "¡Mira este archivo PDF con firma! Folio: $folio");
      } else {
        print("Permiso de almacenamiento denegado.");
      }
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
            Text(language == 'en' ? 'Signature capture' : "Captura de firma"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Signature(
              width: 137.7 * 3,
              height: 137.7 * 3,
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
                      language == 'en' ? 'Clear' : 'Limpiar',
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
                          .show(language == 'en' ? 'Generating file...' : 'Generando archivo...');

                      await generateAndSharePdf(signature);
                    }
                  } else {
                    CustomSnackBar(context: context)
                        .show(language == 'en' ? 'Please sign before continuing.' : 'Por favor firma antes de continuar.');
                  }
                },
                child: Container(
                  width: 15 * vw,
                  height: 4 * vw,
                  padding: EdgeInsets.symmetric(horizontal: 1 * vw),
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: Text(
                      language == 'en' ? 'Sign quotation' : 'Firmar cotización',
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
