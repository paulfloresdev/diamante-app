import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/models/auxiliars/Responsive.dart';
import 'package:diamante_app/src/widgets/Cell.dart';
import 'package:diamante_app/src/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';

class OverView extends StatefulWidget {
  const OverView({super.key});

  @override
  State<OverView> createState() => _OverViewState();
}

class _OverViewState extends State<OverView> {
  late Future<List<Map<String, dynamic>>> _futureData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _reload();
  }

  _reload() async{
    _futureData = DatabaseService.instance.getFullSelection();
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
            Container(
              width: 95 * vw,
              height: 5 * vw,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
              ),
              child: Center(
                child: Text(
                  'DETALLE DE LA COTIZACIÓN',
                  style: TextStyle(
                    fontSize: 1.4*vw,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).splashColor,
                  ),
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureData,
              builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: Text('Cargando...'));
                }
                var groups = snapshot.data;
                if (groups!.isEmpty) {
                  return Center(child: Text('Vacío'));
                }

                return Container(
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
                            Container(
                              width: 95 * vw,
                              height: 5 * vw,
                              color: Color.fromRGBO(225, 225, 240, 1),
                              child: Center(
                                child: Text(
                                  group['grupo_nombre'],
                                  style: TextStyle(
                                    fontSize: 1.4*vw,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 95 * vw,
                              height: 4 * vw,
                              color: Color.fromRGBO(235, 235, 250, 1),
                              child: Row(
                                children: [
                                  Cell(text: 'Concepto', width: 42.5*vw, fontSize: 1.4*vw, fontWeight: FontWeight.w600,),
                                  Cell(text: 'Tipo de unidad', width: 20*vw, fontSize: 1.4*vw, fontWeight: FontWeight.w600,),
                                  Cell(text: 'Precio unitario', width: 12.5*vw, fontSize: 1.4*vw, fontWeight: FontWeight.w600,),
                                  Cell(text: 'Cantidad', width: 7.5*vw, fontSize: 1.4*vw, fontWeight: FontWeight.w600,),
                                  Cell(text: 'Importe total', width: 12.5*vw, fontSize: 1.4*vw, fontWeight: FontWeight.w600,),
                                ],
                              )
                            ),
                            Container(
                              width: 95 * vw,
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(), // Sin desplazamiento independiente
                                shrinkWrap: true, // Ajuste al contenido
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 95 * vw,
                                    height: 5 * vw,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(width: 0.1*vw, color: Color.fromRGBO(215, 215, 230, 1))
                                      )
                                    ),
                                    child: Text('assa'),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 10*vw),
          ],
        ),
      )

    );
  }
}