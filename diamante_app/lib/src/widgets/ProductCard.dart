import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    // TODO: implement initState
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
            onTap: widget.onTap,
            child: Container(
              width: widget.isOpen ? 69.5 * vw : 73.5 * vw,
              padding: EdgeInsets.all(1.5 * vw),
              margin: EdgeInsets.only(top: 1.5 * vw),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 0.1 * vw,
                  color: isSelected
                      ? Colors.grey.shade300
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
                          ? Colors.grey.shade600
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
                              ? Colors.grey.shade600
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
                              ? Colors.grey.shade300
                              : Colors.transparent,
                          padding: EdgeInsets.all(0.75 * vw),
                          child: widget.product['is_selected'] == 1
                              ? Center(
                                  child: Text(
                                    'Agregado a la Cotización',
                                    style: TextStyle(
                                      fontSize: 1.2 * vw,
                                      fontWeight: FontWeight.w400,
                                      color: isSelected
                                          ? Colors.grey.shade600
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
                                    moneyFormat(
                                        widget.product['precio_unitario']),
                                    style: TextStyle(
                                      fontSize: 1.2 * vw,
                                      fontWeight: FontWeight.w400,
                                      color: isSelected
                                          ? Colors.grey.shade600
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
                                          ? Colors.grey.shade600
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.75 * vw),
                              Text(
                                moneyFormat(widget.product['importe_total']),
                                style: TextStyle(
                                  fontSize: 1.4 * vw,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.grey.shade600
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
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                    child: widget.isPicked
                        ? Container(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColorDark,
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

  String moneyFormat(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US', // Usa 'es_MX' si prefieres formato español-mexicano
      symbol: '\$', // Símbolo de moneda
      decimalDigits: 2, // Cantidad de decimales
    );

    return formatter.format(amount);
  }
}