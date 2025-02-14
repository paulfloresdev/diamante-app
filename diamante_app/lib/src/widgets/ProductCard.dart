import 'package:diamante_app/src/models/auxiliars/Formatter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auxiliars/Responsive.dart';

class ProductCard extends StatefulWidget {
  final bool isPicked;
  final bool isOpen;
  final Map<String, dynamic> product;
  final void Function() onLongPress;
  final void Function() onPick;
  final void Function() onTap;
  const ProductCard({
    super.key,
    required this.isPicked,
    required this.isOpen,
    required this.product,
    required this.onLongPress,
    required this.onPick,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isSelected;

  String language = 'en'; // Asignar un valor predeterminado para evitar errores

  getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      language = prefs.getString('language') ?? 'en';
    });
  }

  @override
  void initState() {
    super.initState();
    getLanguage();
    isSelected = widget.product['is_selected'] == 1;
  }

  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    var vw = responsive.viewportWidth;

    return Container(
      width: 73.5 * vw,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onLongPress: widget.onLongPress,
            onTap: isSelected ? null : widget.onTap,
            child: Container(
              width: widget.isOpen ? 69.5 * vw : 73.5 * vw,
              padding: EdgeInsets.all(1.5 * vw),
              margin: EdgeInsets.only(top: 1.5 * vw),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.1 * vw,
                  color: isSelected
                      ? Theme.of(context).shadowColor
                      : Theme.of(context).primaryColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.product['concepto'],
                    style: TextStyle(
                      fontSize: 1.4 * vw,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).hintColor
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 0.25 * vw),
                  Row(
                    children: [
                      Text(
                        widget.product['tipo_unidad'],
                        style: TextStyle(
                          fontSize: 1.2 * vw,
                          fontWeight: FontWeight.w400,
                          color: isSelected
                              ? Theme.of(context).hintColor
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.75 * vw),
                  Container(
                    width: widget.isOpen ? 66.5 * vw : 70.5 * vw,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 15.5 * vw,
                          color: widget.product['is_selected'] == 1
                              ? Theme.of(context).shadowColor
                              : Colors.transparent,
                          padding: EdgeInsets.all(0.75 * vw),
                          child: widget.product['is_selected'] == 1
                              ? Center(
                                  child: Text(
                                    language == 'en'
                                        ? 'Added to the quotation'
                                        : 'Agregado a la cotización',
                                    style: TextStyle(
                                      fontSize: 1.2 * vw,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Theme.of(context).splashColor
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    Formatter.money(
                                        widget.product['precio_unitario']),
                                    style: TextStyle(
                                      fontSize: 1.2 * vw,
                                      fontWeight: FontWeight.w400,
                                      color: isSelected
                                          ? Theme.of(context).hintColor
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 0.75 * vw),
                                  Text(
                                    'x ${widget.product['cantidad']}',
                                    style: TextStyle(
                                      fontSize: 1.4 * vw,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Theme.of(context).hintColor
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.75 * vw),
                              Text(
                                Formatter.money(widget.product['importe_total']),
                                style: TextStyle(
                                  fontSize: 1.4 * vw,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Theme.of(context).hintColor
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          widget.isOpen && !isSelected
              ? GestureDetector(
                  onTap: widget.onPick,
                  child: Container(
                    width: 2.5 * vw,
                    height: 2.5 * vw,
                    padding: EdgeInsets.all(0.25 * vw),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 0.1 * vw,
                        color: Theme.of(context).secondaryHeaderColor,
                      ),
                    ),
                    child: widget.isPicked
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
                )
              : SizedBox()
        ],
      ),
    );
  }

  
}