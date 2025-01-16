import 'package:diamante_app/src/database/DatabaseFiles.dart';
import 'package:diamante_app/src/database/DatabaseService.dart';
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
                color: Theme.of(context).primaryColorDark,
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