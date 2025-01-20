
import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/models/auxiliars/Formatter.dart';
import 'package:diamante_app/src/models/auxiliars/Responsive.dart';
import 'package:diamante_app/src/widgets/Cell.dart';
import 'package:diamante_app/src/widgets/CustomScaffold.dart';
import 'package:diamante_app/src/widgets/dialogs-snackbars/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/dialogs-snackbars/ConfirmDialog.dart';

class OverView extends StatefulWidget {
  const OverView({super.key});

  @override
  State<OverView> createState() => _OverViewState();
}

class _OverViewState extends State<OverView> {
  late Future<Map<String, dynamic>> _futureData;
  late Future<Map<String, dynamic>?> _futureConfig;
  late bool isOpen;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _reload();
    isOpen = true;
  }

  _reload() async{
    setState(() {
      _futureData = DatabaseService.instance.getFullSelection();
      _futureConfig = DatabaseService.instance.getConfigById(1);
    });
  }

  Future<bool> _showConfirmationDialog(
      {required String title, required String subTitle}) async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialog(
              title: title,
              subTitle: subTitle,
              confirmLabel: 'Aceptar',
              confirmColor: Colors.redAccent.shade700,
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

    return Customscaffold(
      groupId: 0, 
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.5 * vw),
        child: ListView(
          children: [

            
            FutureBuilder<Map<String, dynamic>?>(future: _futureConfig, builder: (context, AsyncSnapshot<Map<String, dynamic>?> configData){
              if(!configData.hasData){
                return Center(child: Text('Cargando...'));
              }

              var configsD = configData.data;
              var configs = configsD!;

              return Column(
                children: [
                  Container(
                    width: 95*vw,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Cliente:',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 0.5*vw),
                                Text(
                                  configs['nombre_cliente'],
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1*vw),
                            Row(
                              children: [
                                Text(
                                  'Fecha',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 0.5*vw),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(DateTime.now()),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1*vw),
                            Row(
                              children: [
                                Text(
                                  'Folio:',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 0.5*vw),
                                Text(
                                  'Por definir',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1*vw),
                            Row(
                              children: [
                                Text(
                                  'Moneda:',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 0.5*vw),
                                Text(
                                  configs['moneda'],
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1*vw),
                            Row(
                              children: [
                                Text(
                                  'Empresa:',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 0.5*vw),
                                Text(
                                  configs['nombre_empresa'],
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2*vw),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isOpen = !isOpen;
                                });
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Text(
                                      'Cotización detallada:',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 1.4*vw,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(width: 0.5*vw),
                                    Icon(
                                      isOpen ? Icons.toggle_on : Icons.toggle_off,
                                      size: 5*vw,
                                      color: isOpen ? Theme.of(context).secondaryHeaderColor.withOpacity(.8) : Theme.of(context).shadowColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset('assets/images/logo.png', width: 15*vw, color: Theme.of(context).secondaryHeaderColor,),
                            SizedBox(height: 1*vw),
                            Text(
                              configs['domicilio'],
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 1.2*vw,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'C.P. ${configs['cp']}',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 1.2*vw,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              Formatter.phoneNumber(configs['telefono']),
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 1.2*vw,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 95 * vw,
                    height: 5 * vw,
                    decoration: BoxDecoration(
                      color: Theme.of(context).secondaryHeaderColor.withOpacity(0.8),
                    ),
                    child: Center(
                      child: Text(
                          isOpen ? 'DETALLE DE LA COTIZACIÓN' : 'RESUMEN DE LA COTIZACIÓN',
                          style: TextStyle(
                            fontSize: 1.4*vw,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).splashColor,
                          ),
                        ),
                    )
                  ),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _futureData,
                    builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: Text('Cargando...'));
                      }
                      var data = snapshot.data;
                      var subtotal = data!['totalSum'];
                      var iva = configs['iva_porcentaje']/100;
                      var ivaValor = subtotal*iva;
                      var total = subtotal + ivaValor; 
                      var groups = data['grupos'];
                      if (groups!.isEmpty) {
                        return Center(child: Text('No se han agregado productos.'));
                      }
                  
                      return Column(
                        children: [
                          Container(
                            width: 95 * vw,
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(), // Evita desplazamiento independiente
                              shrinkWrap: true, // Permite ajustar el tamaño al contenido
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> group = groups[index];
                                List<dynamic> products = group['productos'];
                                return Container(
                                  width: 95 * vw,
                                  child: Column(
                                    children: [
                                      
                                      isOpen ? Container(
                                        width: 95 * vw,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(235, 235, 250, 1),
                                          border: Border(
                                            bottom: BorderSide(width: 0.1*vw, color: Theme.of(context).shadowColor)
                                          )
                                        ),
                                        child: Row(
                                          children: [
                                            Cell(text: 'Concepto', width: 42.5*vw, fontWeight: FontWeight.w600, mainAxisAlignment: MainAxisAlignment.start),
                                            Cell(text: 'Tipo de unidad', width: 20*vw, fontWeight: FontWeight.w600,),
                                            Cell(text: 'Precio unitario', width: 12.25*vw, fontWeight: FontWeight.w600,),
                                            Cell(text: 'Cantidad', width: 8*vw, fontWeight: FontWeight.w600,),
                                            Cell(text: 'Importe total', width: 12.25*vw, fontWeight: FontWeight.w600,),
                                          ],
                                        )
                                      ) : SizedBox(),
                                      isOpen ? Container(
                                        width: 95 * vw,
                                        child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(), // Sin desplazamiento independiente
                                          shrinkWrap: true, // Ajuste al contenido
                                          itemCount: products.length,
                                          itemBuilder: (context, index) {
                                            var product = products[index];
                                  
                                            return Material(
                                              color: Color.fromRGBO(240, 240, 255, 1), // Fondo predeterminado
                                              child: InkWell(
                                                onLongPress: () async {
                                                  final bool confirmDelete = await _showConfirmationDialog(title: 'Eliminar producto de la cotización', subTitle: 'Este producto será eliminado unicamente de la cotización, podrás encontrarlo nuevamente en su respectiva propuesta.');
                                                  
                                                  if(confirmDelete){
                                                    await DatabaseService.instance.updateProductoSeleccion(product['producto_id'], false);
                                                    _reload();
                                                    CustomSnackBar(context: context).show('Producto eliminado de la cotización correctamente.');
                                                  }
                                                  
                                                },
                                                splashColor: Theme.of(context).primaryColorLight.withOpacity(0.2), // Color del efecto ripple
                                                highlightColor: Theme.of(context).primaryColorLight.withOpacity(0.2), // Color del sombreado en el press
                                                child: Container(
                                                  width: 95 * vw,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(width: 0.1 * vw, color: Theme.of(context).shadowColor),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Cell(text: product['concepto'], width: 42.5 * vw, mainAxisAlignment: MainAxisAlignment.start, textAlign: TextAlign.left,),
                                                      Cell(text: product['tipo_unidad'], width: 20 * vw),
                                                      Cell(text: Formatter.money(product['precio_unitario']), width: 12.5 * vw),
                                                      Cell(text: product['cantidad'].toString(), width: 7.5 * vw),
                                                      Cell(text: Formatter.money(product['importe_total']), width: 12.5 * vw),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                          
                                        ),
                                      ) : SizedBox(),
                                      Container(
                                        width: 95 * vw,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(225, 225, 240, 1),
                                          border: Border(
                                            bottom: BorderSide(width: 0.1*vw, color: Theme.of(context).hintColor)
                                          )
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Cell(text: group['grupo_nombre'], width: 42.5*vw, fontSize: 1.4*vw, fontWeight: FontWeight.w600, mainAxisAlignment: MainAxisAlignment.start),
                                            Cell(text: Formatter.money(group['sumatoria']), width: 12.5 * vw, fontSize: 1.4*vw, fontWeight: FontWeight.w600,),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 95 * vw,
                            padding: EdgeInsets.symmetric(vertical: 1.5*vw, horizontal: 3.5*vw),
                            decoration: BoxDecoration(
                              color: Theme.of(context).splashColor
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 12.5*vw,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Subtotal:',
                                            style: TextStyle(
                                              fontSize: 1.4*vw,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12.5*vw,
                                      child: Text(
                                        '${Formatter.money(subtotal)}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 1.4*vw,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 0.5*vw),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 12.5*vw,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'IVA (${configs['iva_porcentaje'].toString()}%):',
                                            style: TextStyle(
                                              fontSize: 1.4*vw,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12.5*vw,
                                      child: Text(
                                        '${Formatter.money(ivaValor)}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 1.4*vw,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 1*vw),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 12.5*vw,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Total:',
                                            style: TextStyle(
                                              fontSize: 1.6*vw,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 12.5*vw,
                                      child: Text(
                                        '${Formatter.money(total)}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 1.6*vw,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 0.5*vw),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            }),
            
            SizedBox(height: 10*vw),
          ],
        ),
      )

    );
  }
}