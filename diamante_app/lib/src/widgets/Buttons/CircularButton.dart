import 'package:flutter/material.dart';

import '../../models/auxiliars/Responsive.dart';

class CircularButton extends StatefulWidget {
  final void Function() onPressed;
  final IconData icon;
  const CircularButton(
      {super.key, required this.onPressed, required this.icon});

  @override
  State<CircularButton> createState() => _CircularButtonState();
}

class _CircularButtonState extends State<CircularButton> {
  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    double vw = responsive.viewportWidth;

    return IconButton(
      onPressed: widget.onPressed,
      icon: Container(
        width: 2.5 * vw,
        height: 2.5 * vw,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              width: 0.1 * vw, color: Theme.of(context).primaryColor),
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: 1.25 * vw,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
