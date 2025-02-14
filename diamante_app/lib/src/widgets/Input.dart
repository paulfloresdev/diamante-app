import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/auxiliars/Responsive.dart';

class Input extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final Pattern? pattern;
  final Function(String)? onSubmitted;
  const Input(
      {super.key,
      required this.controller,
      required this.hint,
      this.keyboardType,
      this.pattern,
      this.onSubmitted});

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    var vw = responsive.viewportWidth;

    return SizedBox(
      height: 3 * vw,
      child: TextField(
        inputFormatters: [
          FilteringTextInputFormatter.allow(widget.pattern ?? RegExp(r'.*'))
        ],
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: Colors.grey.shade700),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColorDark,
              width: 0.1 * vw,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 0.1 * vw,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 0.75 * vw,
            horizontal: 1 * vw,
          ),
        ),
        style: TextStyle(
          fontSize: 1 * vw,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
