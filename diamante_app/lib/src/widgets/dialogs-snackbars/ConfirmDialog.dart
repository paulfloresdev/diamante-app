import 'package:flutter/material.dart';

import '../../models/auxiliars/Responsive.dart';

class ConfirmDialog extends StatefulWidget {
  final String title;
  final String subTitle;
  final String confirmLabel;
  final Color confirmColor;
  final String declineLabel;
  final Color declineColor;
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.subTitle,
    required this.confirmLabel,
    required this.confirmColor,
    required this.declineLabel,
    required this.declineColor,
  });

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    var vw = responsive.viewportWidth;

    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(fontSize: 1.2 * vw, fontWeight: FontWeight.w600),
      ),
      content: Text(
        widget.subTitle,
        style: TextStyle(fontSize: 1.2 * vw, fontWeight: FontWeight.w400),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Cancela la eliminación
          },
          child: Text(
            widget.declineLabel,
            style: TextStyle(fontSize: 1.2 * vw, color: widget.declineColor),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Confirma la eliminación
          },
          child: Text(
            widget.confirmLabel,
            style: TextStyle(fontSize: 1.2 * vw, color: widget.confirmColor),
          ),
        ),
      ],
    );
  }
}