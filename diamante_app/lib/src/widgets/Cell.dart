import 'package:flutter/material.dart';

import '../models/auxiliars/Responsive.dart';

class Cell extends StatefulWidget {
  final String text;
  final double width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final MainAxisAlignment? mainAxisAlignment;
  final TextAlign? textAlign;

  const Cell({
    super.key,
    required this.text,
    required this.width,
    this.fontSize,
    this.fontWeight,
    this.mainAxisAlignment,
    this.textAlign,
  });

  @override
  State<Cell> createState() => _CellState();
}

class _CellState extends State<Cell> {
  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    double vw = responsive.viewportWidth;

    return Container(
      width: widget.width,
      padding: EdgeInsets.symmetric(horizontal: 1 * vw, vertical: 1*vw),
      child: Row(
        mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              widget.text,
              textAlign: widget.textAlign ?? TextAlign.center,
              style: TextStyle(
                fontSize: widget.fontSize ?? 1.3 * vw,
                fontWeight: widget.fontWeight ?? FontWeight.w400,
                color: Theme.of(context).primaryColor
              ),
              softWrap: true, // Permite que el texto se ajuste en otro renglón
              overflow: TextOverflow.visible, // Controla el desbordamiento del texto
            ),
          ),
        ],
      ),
    );
  }
}
