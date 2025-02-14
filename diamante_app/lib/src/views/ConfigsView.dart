import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/models/auxiliars/Router.dart';
import 'package:diamante_app/src/widgets/Buttons/BoxButton.dart';
import 'package:diamante_app/src/widgets/CustomScaffold.dart';
import 'package:diamante_app/src/widgets/Input.dart';
import 'package:diamante_app/src/widgets/dialogs-snackbars/CustomSnackBar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/WebDatabaseService.dart';
import '../models/auxiliars/Responsive.dart';

class ConfigsView extends StatefulWidget {
  final String nombreCliente;
  final String moneda;
  final double ivaPorcentaje;
  final String nombreEmpresa;
  final String domicilio;
  final String cp;
  final String telefono;
  const ConfigsView({
    super.key,
    required this.nombreCliente,
    required this.moneda,
    required this.ivaPorcentaje,
    required this.nombreEmpresa,
    required this.domicilio,
    required this.cp,
    required this.telefono,
  });

  @override
  State<ConfigsView> createState() => _ConfigsViewState();
}

class _ConfigsViewState extends State<ConfigsView> {
  late var webDatabaseService;

  late TextEditingController nombreClienteController;
  late TextEditingController monedaController;
  late TextEditingController ivaPorcentajeController;
  late TextEditingController nombreEmpresaController;
  late TextEditingController domicilioController;
  late TextEditingController cpController;
  late TextEditingController telefonoController;

  String language = 'en';

  getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      language = prefs.getString('language') ?? 'en';
    });
  }

  toogleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('language', language == 'en' ? 'es' : 'en');
      language = prefs.getString('language') ?? 'en';
    });
    Routes(context).goTo(ConfigsView(nombreCliente: widget.nombreCliente, moneda: widget.moneda, ivaPorcentaje: widget.ivaPorcentaje, nombreEmpresa: widget.nombreEmpresa, domicilio: widget.domicilio, cp: widget.cp, telefono: widget.telefono));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getLanguage();

    webDatabaseService = kIsWeb ?
        Provider.of<WebDatabaseService>(context, listen: false) : null;

    nombreClienteController = TextEditingController(text: widget.nombreCliente);
    monedaController = TextEditingController(text: widget.moneda);
    ivaPorcentajeController =
        TextEditingController(text: widget.ivaPorcentaje.toString());
    nombreEmpresaController = TextEditingController(text: widget.nombreEmpresa);
    domicilioController = TextEditingController(text: widget.domicilio);
    cpController = TextEditingController(text: widget.cp);
    telefonoController = TextEditingController(text: widget.telefono);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nombreClienteController.dispose();
    monedaController.dispose();
    ivaPorcentajeController.dispose();
    nombreEmpresaController.dispose();
    domicilioController.dispose();
    cpController.dispose();
    telefonoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    double vw = responsive.viewportWidth;

    return Customscaffold(
        groupId: 999999999,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.5 * vw),
          child: ListView(
            children: [
              Text(
                language == 'en' ? 'CONFIGS' : 'PANEL DE CONFIGURACIÓN',
                style: TextStyle(
                  fontSize: 1.4 * vw,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 1.5 * vw),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Alinea el contenido a la izquierda
                      children: [
                        Text(
                          language == 'en'
                              ? 'Client name'
                              : 'Nombre del cliente',
                          style: TextStyle(
                            fontSize: 1.3 * vw,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 0.5 * vw),
                        Input(
                            controller: nombreClienteController,
                            hint: language == 'en'
                                ? 'Client name'
                                : 'Nombre del cliente'),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.5 * vw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Alinea el contenido a la izquierda
                      children: [
                        Text(
                          language == 'en'
                              ? 'Company name'
                              : 'Nombre de la empresa',
                          style: TextStyle(
                            fontSize: 1.3 * vw,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 0.5 * vw),
                        Input(
                            controller: nombreEmpresaController,
                            hint: language == 'en'
                              ? 'Company name'
                              : 'Nombre de la empresa',),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5 * vw),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Alinea el contenido a la izquierda
                      children: [
                        Text(
                          language == 'en' ? 'Address' : 'Domicilio',
                          style: TextStyle(
                            fontSize: 1.3 * vw,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 0.5 * vw),
                        Input(
                            controller: domicilioController, hint: language == 'en' ? 'Address' : 'Domicilio',),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.5 * vw),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Alinea el contenido a la izquierda
                            children: [
                              Text(
                                language == 'en' ? 'Zip code' : 'Código postal',
                                style: TextStyle(
                                  fontSize: 1.3 * vw,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: 0.5 * vw),
                              Input(
                                controller: cpController,
                                hint: language == 'en' ? 'Zip code' : 'Código postal',
                                keyboardType: TextInputType.number,
                                pattern: RegExp(r'[0-9]'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.5 * vw),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Alinea el contenido a la izquierda
                            children: [
                              Text(
                                language == 'en' ? 'Phone number' : 'Teléfono',
                                style: TextStyle(
                                  fontSize: 1.3 * vw,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: 0.5 * vw),
                              Input(
                                controller: telefonoController,
                                hint: language == 'en' ? 'Phone number' : 'Teléfono',
                                keyboardType: TextInputType.number,
                                pattern: RegExp(r'[0-9]'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5 * vw),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10 * vw,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Alinea el contenido a la izquierda
                            children: [
                              Text(
                                'IVA (%)',
                                style: TextStyle(
                                  fontSize: 1.3 * vw,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(height: 0.5 * vw),
                              Input(
                                controller: ivaPorcentajeController,
                                hint: 'IVA',
                                keyboardType: TextInputType.number,
                                pattern: RegExp(r'[0-9.]'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.5 * vw),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language == 'en' ? 'Currency' : 'Moneda',
                        style: TextStyle(
                          fontSize: 1.3 * vw,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 0.5 * vw),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (monedaController.text == 'USD') {
                              monedaController.text = 'MXN';
                            } else {
                              monedaController.text = 'USD';
                            }
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Text(
                                'USD',
                                style: TextStyle(
                                  fontSize: 1.4 * vw,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 0.5 * vw),
                              Icon(
                                monedaController.text == 'USD'
                                    ? Icons.toggle_off
                                    : Icons.toggle_on,
                                size: 5 * vw,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                              SizedBox(width: 0.5 * vw),
                              Text(
                                'MXN',
                                style: TextStyle(
                                  fontSize: 1.4 * vw,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(width: 2.5 * vw),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language == 'en' ? 'Language' : 'Lenguaje',
                        style: TextStyle(
                          fontSize: 1.3 * vw,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 0.5 * vw),
                      GestureDetector(
                        onTap: toogleLanguage,
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Text(
                                'English',
                                style: TextStyle(
                                  fontSize: 1.4 * vw,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 0.5 * vw),
                              Icon(
                                language == 'en'
                                    ? Icons.toggle_off
                                    : Icons.toggle_on,
                                size: 5 * vw,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                              SizedBox(width: 0.5 * vw),
                              Text(
                                'Español',
                                style: TextStyle(
                                  fontSize: 1.4 * vw,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1.5 * vw),
              InkWell(
                onTap: () async {
                  print(nombreClienteController.text);
                  print(nombreEmpresaController.text);
                  print(domicilioController.text);
                  print(cpController.text);
                  print(telefonoController.text);
                  print(ivaPorcentajeController.text);
                  print(monedaController.text);

                  if (cpController.text.length > 4) {
                    if (telefonoController.text.length > 9) {
                      if (nombreEmpresaController.text.isNotEmpty &&
                          nombreClienteController.text.isNotEmpty &&
                          domicilioController.text.isNotEmpty &&
                          ivaPorcentajeController.text.isNotEmpty) {
                        if (kIsWeb) {
                          await webDatabaseService.updateConfig(1,
                              nombreCliente: nombreClienteController.text,
                              moneda: monedaController.text,
                              porcentajeIVA:
                                  double.parse(ivaPorcentajeController.text),
                              nombreEmpresa: nombreEmpresaController.text,
                              domicilio: domicilioController.text,
                              cp: cpController.text,
                              telefono: telefonoController.text);
                        } else {
                          await DatabaseService.instance.updateConfig(1,
                              nombreCliente: nombreClienteController.text,
                              moneda: monedaController.text,
                              porcentajeIVA:
                                  double.parse(ivaPorcentajeController.text),
                              nombreEmpresa: nombreEmpresaController.text,
                              domicilio: domicilioController.text,
                              cp: cpController.text,
                              telefono: telefonoController.text);
                        }

                        CustomSnackBar(context: context).show(
                            'Configuraciones actualizadas correctamente.');
                      } else {
                        CustomSnackBar(context: context)
                            .show('Se encontraron campos vacíos.');
                      }
                    } else {
                      CustomSnackBar(context: context)
                          .show('El teléfono debe tener mímino 10 dígitos.');
                    }
                  } else {
                    CustomSnackBar(context: context)
                        .show('El código postal debe tener mímino 5 dígitos.');
                  }
                },
                child: Container(
                  width: 95 * vw,
                  height: 5 * vw,
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: Text(
                      language == 'en' ? 'Save' : 'Guardar',
                      style: TextStyle(
                        fontSize: 1.2 * vw,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).splashColor,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
