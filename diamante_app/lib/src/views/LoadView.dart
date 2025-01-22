import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../models/auxiliars/Responsive.dart';

class LoadView extends StatefulWidget {
  const LoadView({super.key});

  @override
  State<LoadView> createState() => _LoadViewState();
}

class _LoadViewState extends State<LoadView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    var vw = responsive.viewportWidth;

    return Scaffold(
        backgroundColor: Theme.of(context).splashColor,
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeIn(
                duration: const Duration(milliseconds: 2000),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 25 * vw,
                  color: Theme.of(context).secondaryHeaderColor,
                ),
              ),
              SizedBox(height: 2.5*vw),
              SizedBox(
                width: 3 * vw, // Ajusta el ancho
                height: 3 * vw, // Ajusta la altura
                child: CircularProgressIndicator(
                  strokeWidth: 0.6 * vw, // Ajusta el grosor
                  color: Theme.of(context).shadowColor,
                ),
              )

            ],
          ),
        ));
  }
}
