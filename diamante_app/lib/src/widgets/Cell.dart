import 'package:flutter/material.dart';

import '../models/auxiliars/Responsive.dart';

class Cell extends StatefulWidget {
  final String text;
  final double width;
  final double? fontSize;
  final FontWeight? fontWeight;
  final MainAxisAlignment? mainAxisAlignment;
  const Cell({super.key, required this.text, required this.width, this.fontSize, this.fontWeight, this.mainAxisAlignment});

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

      child: Row(
        mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.center,
        children: [
          Text(
            widget.text, 
            style: TextStyle(
              fontSize: widget.fontSize ?? 1.2*vw,
              fontWeight: widget.fontWeight ?? FontWeight.w400,
            ),
          ),
        ],
      ),
      
    );
  }
}