
import 'package:diamante_app/src/models/pdf/PdfGenerator.dart';
import 'package:flutter/material.dart';
import 'views/SplashView.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Rancho San Lucas',
        theme: ThemeData(
          splashColor: const Color.fromRGBO(240, 240, 255, 1),
          primaryColor: const Color.fromRGBO(60, 60, 75, 1),
          primaryColorDark: const Color.fromRGBO(0, 53, 95, 1),
          primaryColorLight: const Color.fromRGBO(124, 191, 212, 1),
          secondaryHeaderColor: const Color.fromRGBO(111, 99, 94, 1),
          shadowColor: Color.fromRGBO(200, 200, 215, 1),
          hintColor: Color.fromRGBO(160, 160, 175, 1),
        ),
        home: SplashView());
  }
}
