import 'package:diamante_app/src/widgets/CustomScaffold.dart';
import 'package:diamante_app/src/widgets/Input.dart';
import 'package:flutter/material.dart';

import '../models/auxiliars/Responsive.dart';

class ConfigsView extends StatefulWidget {
  final String nombreCliente;
  final String moneda;
  final double ivaPorcentaje;
  final String nombreEmpresa;
  final String domicilio;
  final String cp;
  final String telefono;
  const ConfigsView({super.key,
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
  late TextEditingController nombreClienteController;
  late TextEditingController monedaController;
  late TextEditingController ivaPorcentajeController;
  late TextEditingController nombreEmpresaController;
  late TextEditingController domicilioController;
  late TextEditingController cpController;
  late TextEditingController telefonoController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nombreClienteController = TextEditingController(text: widget.nombreCliente);
    monedaController = TextEditingController(text: widget.moneda);
    ivaPorcentajeController = TextEditingController(text: widget.ivaPorcentaje.toString());
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
        padding: EdgeInsets.symmetric(horizontal: 2.5*vw),
        child: ListView(
          children: [
            Text('PANEL DE CONFIGURACIÓN',
              style: TextStyle(
                fontSize: 1.4*vw,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 1.5*vw),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                    children: [
                      Text(
                        'Nombre del cliente',
                        style: TextStyle(
                          fontSize: 1.3 * vw,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 0.5 * vw),
                      Input(controller: nombreClienteController, hint: 'Nombre del cliente'),
                    ],
                  ),
                ),
                SizedBox(width: 2.5*vw),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                    children: [
                      Text(
                        'Nombre de la empresa',
                        style: TextStyle(
                          fontSize: 1.3 * vw,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 0.5 * vw),
                      Input(controller: nombreEmpresaController, hint: 'Nombre de la empresa'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5*vw),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                    children: [
                      Text(
                        'Domicilio',
                        style: TextStyle(
                          fontSize: 1.3 * vw,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 0.5 * vw),
                      Input(controller: domicilioController, hint: 'Domicilio'),
                    ],
                  ),
                ),
                SizedBox(width: 2.5*vw),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                          children: [
                            Text(
                              'Código postal',
                              style: TextStyle(
                                fontSize: 1.3 * vw,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 0.5 * vw),
                            Input(controller: cpController, hint: 'C.P.'),
                          ],
                        ),
                      ),
                      SizedBox(width: 2.5*vw),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                          children: [
                            Text(
                              'Teléfono',
                              style: TextStyle(
                                fontSize: 1.3 * vw,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 0.5 * vw),
                            Input(controller: telefonoController, hint: 'Teléfono'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
              ],
            ),
            SizedBox(height: 1.5*vw),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10*vw,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                          children: [
                            Text(
                              'IVA (%)',
                              style: TextStyle(
                                fontSize: 1.3 * vw,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 0.5 * vw),
                            Input(controller: ivaPorcentajeController, hint: 'IVA'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.5*vw),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Moneda',
                      style: TextStyle(
                        fontSize: 1.3 * vw,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 0.5 * vw),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          if(monedaController.text == 'USD'){
                            monedaController.text = 'MXN';
                          }else{
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
                            SizedBox(width: 0.5*vw),
                            Icon(
                              monedaController.text == 'USD' ?  Icons.toggle_off : Icons.toggle_on,
                              size: 5*vw,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                            SizedBox(width: 0.5*vw),
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
              ],
            ),

            
          ],
        ),
      )
    );
  }
}