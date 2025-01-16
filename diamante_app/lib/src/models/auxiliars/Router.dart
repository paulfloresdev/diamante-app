import 'package:flutter/material.dart';

class Routes {
  late BuildContext context;
  Routes(this.context);

  goTo(StatefulWidget screen) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (((context, animation, secondaryAnimation) => screen))));
  }
}