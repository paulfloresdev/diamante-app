import 'package:flutter/material.dart';

import '../../models/auxiliars/Responsive.dart';

class CustomSnackBar {
  final BuildContext context;
  CustomSnackBar({required this.context});

  void show(String message) {
    var responsive = Responsive(context);
    var vw = responsive.viewportWidth;

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          fontSize: 1.2 * vw,
          color: Theme.of(context).primaryColor,
        ),
      ),
      backgroundColor: Theme.of(context).shadowColor.withOpacity(0.8),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}