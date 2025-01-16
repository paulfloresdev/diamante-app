import 'package:diamante_app/src/views/OverView.dart';
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
    Future.delayed(const Duration(seconds: 2), _onSplashComplete);
  }

  void _onSplashComplete() {
    Routes(context).goTo(OverView());
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
            FadeInImage(
              width: 15 * vw,
              fadeInDuration: const Duration(milliseconds: 1000),
              placeholder: const AssetImage('assets/images/logo.png'),
              image: const AssetImage('assets/images/logo.png'),
            ),
          ],
        ),
      ),
    );
  }
}