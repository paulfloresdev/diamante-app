import 'package:flutter/material.dart';

import '../../models/auxiliars/Responsive.dart';

class BoxButton extends StatefulWidget {
  final String label;
  final void Function() onPressed;
  final bool isFocused;
  final void Function()? onLongPress;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final double? fontSize;
  const BoxButton({super.key, required this.label, required this.onPressed, required this.isFocused, this.onLongPress, this.width, this.margin, this.fontSize});

  @override
  State<BoxButton> createState() => _BoxButtonState();
  
}

class _BoxButtonState extends State<BoxButton> {
  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    double vw = responsive.viewportWidth;
    
    return GestureDetector(
      onTap: widget.onPressed,
      onLongPress: widget.onLongPress,
      child: Container(
        width: widget.width,
        height: 5*vw,
        padding: EdgeInsets.all(1*vw),
        margin: widget.margin,
        decoration: BoxDecoration(
          border: Border.all(width: 0.1*vw, color: Theme.of(context).primaryColor),
          color: widget.isFocused ? Theme.of(context).primaryColor : Theme.of(context).splashColor
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: widget.fontSize ?? 1.2*vw,
              fontWeight: FontWeight.w400,
              color: widget.isFocused ? Theme.of(context).splashColor : Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}