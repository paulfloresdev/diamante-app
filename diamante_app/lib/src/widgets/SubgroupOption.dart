import 'package:diamante_app/src/database/DatabaseService.dart';
import 'package:diamante_app/src/widgets/dialogs-snackbars/CustomSnackBar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/WebDatabaseService.dart';
import '../models/auxiliars/Responsive.dart';

class SubgroupOption extends StatefulWidget {
  final Map<String, dynamic> subGroup;
  final bool isFocused;
  final double? width;
  final double? fontSize;
  final void Function()? onPressed;
  final void Function()? onLongPress;
  final EdgeInsetsGeometry? margin;
  const SubgroupOption({
    super.key,
    required this.subGroup,
    required this.isFocused,
    this.width,
    this.fontSize,
    this.onPressed,
    this.onLongPress,
    this.margin,
  });

  @override
  State<SubgroupOption> createState() => _SubgroupOptionState();
}

class _SubgroupOptionState extends State<SubgroupOption> {
  late var webDatabaseService;
  late bool otherHaveSelected = false;

  @override
  void initState() {
    super.initState();
    webDatabaseService = kIsWeb ?
        Provider.of<WebDatabaseService>(context, listen: false) : null;
    check();
  }

  void check() async {
    // Realiza la operación asíncrona fuera de setState
    if (kIsWeb) {
      bool result = await webDatabaseService.otherSubgroupsHaveSelectedProducts(
          widget.subGroup['id'], widget.subGroup['grupo_id']);
      // Luego, actualiza el estado de forma síncrona
      setState(() {
        otherHaveSelected = result;
      });
    } else {
      bool result = await DatabaseService.instance
          .otherSubgroupsHaveSelectedProducts(
              widget.subGroup['id'], widget.subGroup['grupo_id']);
      // Luego, actualiza el estado de forma síncrona
      setState(() {
        otherHaveSelected = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    var vw = responsive.viewportWidth;

    return GestureDetector(
      onTap: otherHaveSelected
          ? () => CustomSnackBar(context: context).show(
              'No puedes acceder a esta propuesta porque ya has seleccionado productos de otra propuesta, puedes eliminarlos de la selección en la pestaña \'Cotización\'.')
          : widget.onPressed ?? () {},
      onLongPress: widget.onLongPress,
      child: Container(
        width: 18.4 * vw,
        margin: EdgeInsets.only(top: 1.5 * vw),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 2.5 * vw,
              height: 2.5 * vw,
              padding: EdgeInsets.all(0.25 * vw),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 0.1 * vw,
                  color: otherHaveSelected
                      ? Theme.of(context).shadowColor
                      : Theme.of(context).secondaryHeaderColor,
                ),
              ),
              child: widget.isFocused
                  ? Container(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    )
                  : null,
            ),
            Container(
              width: 15.4 * vw,
              padding: EdgeInsets.symmetric(vertical: 0.25 * vw),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Text(
                widget.subGroup['nombre'],
                style: TextStyle(
                  fontSize: 1.3 * vw,
                  color: otherHaveSelected
                      ? Colors.grey.shade400
                      : Theme.of(context).primaryColor,
                  fontWeight:
                      widget.isFocused ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
