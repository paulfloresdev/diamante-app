
import 'package:flutter/material.dart';
import 'views/SplashView.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Diamante Resorts app',
        theme: ThemeData(
          splashColor: const Color.fromRGBO(240, 240, 255, 1),
          primaryColor: const Color.fromRGBO(45, 45, 60, 1),
          primaryColorDark: const Color.fromRGBO(0, 53, 95, 1),
          primaryColorLight: const Color.fromRGBO(124, 191, 212, 1),
          secondaryHeaderColor: const Color.fromRGBO(111, 99, 94, 1),
        ),
        home: const SplashView());
  }
}
