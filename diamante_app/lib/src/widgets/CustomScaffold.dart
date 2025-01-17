import 'package:diamante_app/src/database/DatabaseFiles.dart';
import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/models/auxiliars/Router.dart';
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
        automaticallyImplyLeading: false, // Desactiva el espacio reservado para leading
        titleSpacing: 0, // Elimina el padding entre leading y title
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.5 * vw),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/logo.png',
                color: Theme.of(context).secondaryHeaderColor,
                width: 7.5 * vw
              ),
              SizedBox(width: 1.25 * vw),
              CircularButton(
                onPressed: () async {
                  await DatabaseFiles().exportDatabase();
                },
                icon: Icons.arrow_upward_rounded,
              ),
              SizedBox(width: 0.25 * vw),
              CircularButton(
                onPressed: () async {
                  var data = await DatabaseService.instance.getFullSelection();
                  print(data.toString());
                },
                icon: Icons.arrow_downward_rounded,
              ),
              SizedBox(width: 0.25 * vw),
              CircularButton(
                onPressed: () async {
                  Map<String, dynamic>? data = await DatabaseService.instance.getConfigById(1);

                  if(data != {}){
                    Routes(context).goTo(
                      ConfigsView(nombreCliente: data!['nombre_cliente'], moneda: data!['moneda'], ivaPorcentaje: data!['iva_porcentaje'], nombreEmpresa: data!['nombre_empresa'], domicilio: data!['domicilio'], cp: data!['cp'], telefono: data!['telefono'])
                    );
                  }
                },
                icon: Icons.mode_edit_outlined,
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(9.6 * vw), 
          child: Navbar(
            groupId: widget.groupId,
          ),
        )
      ),
      body: widget.body,
    );
  }
}