import 'package:flutter/material.dart';

class Responsive {
  late double vw;
  late double vh;

  Responsive(BuildContext context) {
    vw = MediaQuery.of(context).size.width / 100;
    vh = MediaQuery.of(context).size.height / 100;
  }

  double get viewportWidth => vw;
  double get viewportHeight => vh;
}