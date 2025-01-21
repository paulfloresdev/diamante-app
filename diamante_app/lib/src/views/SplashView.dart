import 'package:animate_do/animate_do.dart';
import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/views/OverView.dart';
import 'package:diamante_app/src/views/WebOverView.dart';
import 'package:flutter/material.dart';

import '../models/auxiliars/Responsive.dart';
import '../models/auxiliars/Router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2)).then((_) {
      Routes(context).goTo(WebOverView());
    });

  }

  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    var vw = responsive.viewportWidth;

    return Scaffold(
      backgroundColor: Theme.of(context).splashColor,
      body:SizedBox(
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
                ],
              ),
            )
    );
  }
}
