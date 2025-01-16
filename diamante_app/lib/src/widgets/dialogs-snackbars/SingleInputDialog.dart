import 'package:flutter/material.dart';

import '../../models/auxiliars/Responsive.dart';
import '../Input.dart';

class SingleInputDialog extends StatefulWidget {
  final String title;
  final String? subTitle;
  final TextEditingController inputController;
  final String inputHint;
  final String? inputValue;
  final void Function() onConfirm;
  final String confirmLabel;
  final void Function()? onDecline;
  final String? declineLabel;
  const SingleInputDialog({
    super.key,
    required this.title,
    this.subTitle,
    required this.inputController,
    required this.inputHint,
    this.inputValue,
    required this.onConfirm,
    required this.confirmLabel,
    this.onDecline,
    this.declineLabel,
  });

  @override
  State<SingleInputDialog> createState() => _SingleInputDialogState();
}

class _SingleInputDialogState extends State<SingleInputDialog> {
  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    var vw = responsive.viewportWidth;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30 * vw),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.5 * vw),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Padding(
                  padding: EdgeInsets.all(2 * vw),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 1.2 * vw, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: widget.subTitle != null ? 1 * vw : 0),
                      widget.subTitle != null
                          ? Text(
                              widget.subTitle ?? '',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 1.2 * vw,
                                  fontWeight: FontWeight.w400),
                            )
                          : SizedBox(),
                      SizedBox(height: 2 * vw),
                      Input(
                          controller: widget.inputController,
                          hint: widget.inputHint),
                      SizedBox(height: 2 * vw),
                      GestureDetector(
                        onTap: widget.onConfirm,
                        child: Container(
                          width: double.infinity,
                          height: 3.5 * vw,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              widget.confirmLabel,
                              style: TextStyle(
                                color: Theme.of(context).splashColor,
                                fontSize: 1.2 * vw,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: (widget.onDecline != null ||
                                  widget.declineLabel != null)
                              ? 0.5 * vw
                              : 0),
                      (widget.onDecline != null || widget.declineLabel != null)
                          ? GestureDetector(
                              onTap: widget.onDecline,
                              child: Container(
                                width: double.infinity,
                                height: 3.5 * vw,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Center(
                                  child: Text(
                                    widget.declineLabel ?? '',
                                    style: TextStyle(
                                      color: Colors.redAccent.shade700,
                                      fontSize: 1.2 * vw,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}