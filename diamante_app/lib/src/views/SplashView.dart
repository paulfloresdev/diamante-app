import 'package:animate_do/animate_do.dart';
import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/views/OverView.dart';
import 'package:diamante_app/src/views/WebOverView.dart';
import 'package:diamante_app/src/widgets/Buttons/BoxButton.dart';
import 'package:diamante_app/src/widgets/Input.dart';
import 'package:diamante_app/src/widgets/dialogs-snackbars/CustomSnackBar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auxiliars/Responsive.dart';
import '../models/auxiliars/Router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late bool hasToken;
  late TextEditingController tokenController;

  @override
  void initState() {
    super.initState();
    tokenController = TextEditingController();
    checkCredentials();
  }

  checkCredentials() async{
    // Verificar si tiene token
    final prefs = await SharedPreferences.getInstance();
    hasToken = prefs.getBool('hasToken') ?? false;

    if(hasToken){
      Routes(context).goTo(OverView());
    }
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
              SizedBox(height: 4*vw),
              SizedBox(
                width: 50*vw,
                child: Input(controller: tokenController, hint: 'Token'),
              ),
              SizedBox(height: 2*vw),
              GestureDetector(
                onTap: () async {
                  if(tokenController.text == 'DCSLAPP2025'){
                    //Token correcto
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setBool('hasToken', true);

                    Routes(context).goTo(OverView());
                  }else{
                    CustomSnackBar(context: context).show('El token ingresado es incorrecto.');
                  }
                },
                child: Container(
                  width: 50*vw,
                  height: 5*vw,
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: Text(
                      'Ingresar',
                      style: TextStyle(
                        fontSize: 1.2*vw,
                        color: Theme.of(context).splashColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
