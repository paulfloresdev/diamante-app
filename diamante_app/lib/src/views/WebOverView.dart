import 'package:diamante_app/src/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebOverView extends StatefulWidget {
  const WebOverView({super.key});

  @override
  State<WebOverView> createState() => _WebOverViewState();
}

class _WebOverViewState extends State<WebOverView> {
  @override
  Widget build(BuildContext context) {
    return Customscaffold(
      groupId: 0,
      body: ListView(
        children: [
          Text(
            'Web',
          ),
        ],
      ),
    );
  }
}
