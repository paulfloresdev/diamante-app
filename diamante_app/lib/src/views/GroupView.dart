import 'package:diamante_app/src/models/auxiliars/Formatter.dart';
import 'package:diamante_app/src/models/auxiliars/Router.dart';
import 'package:diamante_app/src/widgets/Buttons/BoxButton.dart';
import 'package:diamante_app/src/widgets/CustomScaffold.dart';
import 'package:diamante_app/src/widgets/Input.dart';
import 'package:diamante_app/src/widgets/ProductCard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/DatabaseService.dart';
import '../database/WebDatabaseService.dart';
import '../models/auxiliars/Responsive.dart';
import '../widgets/Dialogs-Snackbars/ConfirmDialog.dart';
import '../widgets/Dialogs-Snackbars/CustomSnackBar.dart';
import '../widgets/Dialogs-Snackbars/SingleInputDialog.dart';
import '../widgets/SubgroupOption.dart';

class GroupView extends StatefulWidget {
  final int groupId;
  final int subGroupId;
  const GroupView({super.key, required this.groupId, required this.subGroupId});

  @override
  State<GroupView> createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  late WebDatabaseService webDatabaseService;

  final TextEditingController _addSubGroupController = TextEditingController();
  final TextEditingController _conceptoController = TextEditingController();
  final TextEditingController _unidadController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioUnitarioController =
      TextEditingController();
  late Future<List<Map<String, dynamic>>> _futureSubGroups;
  late Future<Map<String, dynamic>> _futureProducts;
  final List<int> pickedItems = [];
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    webDatabaseService =
        Provider.of<WebDatabaseService>(context, listen: false);
    _reload();
  }

  void _reload() {
    setState(() {
      if (kIsWeb) {
        _futureSubGroups =
            webDatabaseService.getSubgruposByGrupo(widget.groupId);
        _futureProducts =
            webDatabaseService.getProductosBySubgrupo(widget.subGroupId);
      } else {
        _futureSubGroups =
            DatabaseService.instance.getSubgruposByGrupo(widget.groupId);
        _futureProducts =
            DatabaseService.instance.getProductosBySubgrupo(widget.subGroupId);
      }
    });
  }

  void _autoSelect() async {
    var subGroups = await _futureSubGroups;
    if (subGroups.length == 1) {
      int sgId = subGroups.first['id'];
      Routes(context).goTo(GroupView(
        groupId: widget.groupId,
        subGroupId: sgId,
      ));
    }
  }

  // Agregar nuevo grupo
  Future<void> addSubGroup() async {
    final subGroupName = _addSubGroupController.text.trim();
    if (subGroupName.isNotEmpty) {
      if (kIsWeb) {
        await webDatabaseService.createSubgrupo(subGroupName, widget.groupId);
      } else {
        await DatabaseService.instance
            .createSubgrupo(subGroupName, widget.groupId);
      }

      CustomSnackBar(context: context).show('Subgrupo creado correctamente.');
      _reload();
      _autoSelect();
      _addSubGroupController.clear();
      Navigator.of(context).pop(); // Cierra el diálogo
    } else {
      CustomSnackBar(context: context)
          .show('El nombre del subgrupo no puede estar vacío.');
    }
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleInputDialog(
          title: 'Nuevo subgrupo',
          inputController: _addSubGroupController,
          inputHint: 'Nombre',
          onConfirm: addSubGroup,
          confirmLabel: 'Guardar',
        );
      },
    );
  }

  Future<void> editSubGroup(String newSubGroupName, int subgroupId) async {
    if (newSubGroupName.isNotEmpty) {
      if (kIsWeb) {
        await webDatabaseService.updateSubgrupo(subgroupId, newSubGroupName);
      } else {
        await DatabaseService.instance
            .updateSubgrupo(subgroupId, newSubGroupName);
      }

      CustomSnackBar(context: context)
          .show('Subgrupo actualizado correctamente.');
      _reload(); // Recarga los grupos.
      Navigator.of(context).pop(); // Cierra el diálogo.
    } else {
      CustomSnackBar(context: context)
          .show('El nombre del subgrupo no puede estar vacío.');
    }
  }

  void _showEditSubGroupDialog(String currentName, int subgroupId) {
    final TextEditingController editController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return SingleInputDialog(
          title: 'Editar grupo',
          inputController: editController,
          inputHint: 'Nombre',
          inputValue: currentName,
          onConfirm: () => editSubGroup(editController.text.trim(), subgroupId),
          confirmLabel: 'Guardar',
          onDecline: () async {
            late var hasSelected;

            if (kIsWeb) {
              hasSelected =
                  await webDatabaseService.hasSelectedProducts(subgroupId);
            } else {
              hasSelected = await DatabaseService.instance
                  .hasSelectedProducts(subgroupId);
            }

            if (hasSelected) {
              CustomSnackBar(context: context).show(
                  'No es posible eliminar esta propuesta ya que contiene productos seleccionados, puedes eliminar de tu selección estos productos en la pestaña \'Cotización\'');
            } else {
              final bool confirmDelete = await _showDeleteConfirmationDialog(
                  title: 'Eliminar subgrupo',
                  subTitle:
                      '¿Estás seguro que deseas eliminarlo?, todos los datos se perderán.');

              if (confirmDelete) {
                if (kIsWeb) {
                  await webDatabaseService.deleteSubgrupo(subgroupId);
                } else {
                  await DatabaseService.instance.deleteSubgrupo(subgroupId);
                }

                CustomSnackBar(context: context)
                    .show('Subgrupo eliminado correctamente.');

                // Cierra el diálogo inmediatamente
                Navigator.of(context).pop();

                // Actualiza la lista de grupos después de eliminar
                _reload();

                // Verifica si el grupo eliminado es el que está visible en la página actual
                if (subgroupId == widget.subGroupId) {
                  // Realiza la navegación después de que el diálogo se cierre
                  final subgroupId = await getFirstId();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupView(
                            groupId: widget.groupId,
                            subGroupId: subgroupId)), // Navega a Overview
                  );
                }
              } else {
                Navigator.of(context)
                    .pop(); // Cierra el diálogo si no se confirma la eliminación
              }
            }
          },
          declineLabel: 'Eliminar',
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmationDialog(
      {required String title, required String subTitle}) async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialog(
              title: title,
              subTitle: subTitle,
              confirmLabel: 'Eliminar',
              confirmColor: Colors.redAccent.shade700,
              declineLabel: 'Cancelar',
              declineColor: Colors.grey.shade700,
            );
          },
        )) ??
        false; // Devuelve false si el valor retornado es nulo
  }

  Future<bool> _showConfirmationDialog(
      {required String title, required String subTitle}) async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialog(
              title: title,
              subTitle: subTitle,
              confirmLabel: 'Aceptar',
              confirmColor: Theme.of(context).primaryColorDark,
              declineLabel: 'Cancelar',
              declineColor: Colors.grey.shade700,
            );
          },
        )) ??
        false; // Devuelve false si el valor retornado es nulo
  }

  Future<int> getFirstId() async {
    late var data;
    if (kIsWeb) {
      data = await webDatabaseService.getSubgruposByGrupo(widget.groupId);
    } else {
      data = await DatabaseService.instance.getSubgruposByGrupo(widget.groupId);
    }

    if (data.isEmpty) {
      return 0;
    } else {
      return data.first['id'];
    }
  }

  // EN DESARROLLO
  Future<void> addProduct() async {
    final concepto = _conceptoController.text.trim();
    final unidad = _unidadController.text.trim();
    final precioUnitario =
        double.tryParse(_precioUnitarioController.text.trim());
    final cantidad = double.tryParse(_cantidadController.text.trim());

    if (concepto.isNotEmpty &&
        unidad.isNotEmpty &&
        precioUnitario != null &&
        cantidad != null) {
      final total = precioUnitario * cantidad;

      if (kIsWeb) {
        await webDatabaseService.createProducto(
            concepto: concepto,
            tipoUnidad: unidad,
            precioUnitario: precioUnitario,
            cantidad: cantidad.toInt(),
            importeTotal: total,
            subgrupoId: widget.subGroupId);
      } else {
        await DatabaseService.instance.createProducto(
            concepto: concepto,
            tipoUnidad: unidad,
            precioUnitario: precioUnitario,
            cantidad: cantidad.toInt(),
            importeTotal: total,
            subgrupoId: widget.subGroupId);
      }

      CustomSnackBar(context: context).show('Producto creado correctamente.');
      _reload();
      _addSubGroupController.clear();
      Navigator.of(context).pop(); // Cierra el diálogo
    } else {
      CustomSnackBar(context: context)
          .show('El producto no puede tener campos vacíos.');
    }

    _conceptoController.clear();
    _unidadController.clear();
    _cantidadController.clear();
    _precioUnitarioController.clear();
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        var responsive = Responsive(context);
        var vw = responsive.viewportWidth;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * vw),
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
                            'Nuevo producto',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 1.2 * vw,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 1.5 * vw),
                          Text(
                            'Concepto',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 1.2 * vw,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 0.5 * vw),
                          Input(
                              controller: _conceptoController,
                              hint: 'Concepto'),
                          SizedBox(height: 1 * vw),
                          Container(
                            width: 49 * vw,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 24 * vw,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Tipo de unidad',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 1.2 * vw,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(height: 0.5 * vw),
                                      Input(
                                          controller: _unidadController,
                                          hint: 'Tipo de unidad'),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 8 * vw,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Cantidad',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 1.2 * vw,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(height: 0.5 * vw),
                                      Input(
                                        controller: _cantidadController,
                                        hint: 'Cantidad',
                                        keyboardType: TextInputType.number,
                                        pattern: RegExp(r'[0-9]'),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 15 * vw,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Precio unitario',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 1.2 * vw,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(height: 0.5 * vw),
                                      Input(
                                        controller: _precioUnitarioController,
                                        hint: 'Precio unitario',
                                        keyboardType: TextInputType.number,
                                        pattern: RegExp(r'[0-9.]'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2 * vw),
                          GestureDetector(
                            onTap: addProduct,
                            child: Container(
                              width: double.infinity,
                              height: 3.5 * vw,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Center(
                                child: Text(
                                  'Guardar',
                                  style: TextStyle(
                                    color: Theme.of(context).splashColor,
                                    fontSize: 1.2 * vw,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> editProduct(Map<String, dynamic> product) async {
    print('Entre aqui');
    late var operation;

    if (kIsWeb) {
      operation = await webDatabaseService.updateProducto(
          id: product['id'],
          concepto: product['concepto'],
          tipoUnidad: product['tipo_unidad'],
          precioUnitario: product['precio_unitario'],
          cantidad: product['cantidad'].toInt(),
          importeTotal: product['importe_total'],
          subgrupoId: product['subgrupo_id']);
    } else {
      operation = await DatabaseService.instance.updateProducto(
          id: product['id'],
          concepto: product['concepto'],
          tipoUnidad: product['tipo_unidad'],
          precioUnitario: product['precio_unitario'],
          cantidad: product['cantidad'].toInt(),
          importeTotal: product['importe_total'],
          subgrupoId: product['subgrupo_id']);
    }

    if (operation == 1) {
      CustomSnackBar(context: context).show('Producto editado correctamente.');
    } else {
      CustomSnackBar(context: context).show('Algo ha salido mal');
    }
    Navigator.of(context).pop();
    _reload();
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    final TextEditingController _conceptoEditController =
        TextEditingController(text: product['concepto']);
    final TextEditingController _unidadEditController =
        TextEditingController(text: product['tipo_unidad']);
    final TextEditingController _cantidadEditController =
        TextEditingController(text: product['cantidad'].toString());
    final TextEditingController _precioUnitarioEditController =
        TextEditingController(text: product['precio_unitario'].toString());

    showDialog(
      context: context,
      builder: (context) {
        var responsive = Responsive(context);
        var vw = responsive.viewportWidth;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * vw),
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
                            'Editar producto',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 1.2 * vw,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 1.5 * vw),
                          Text(
                            'Concepto',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 1.2 * vw,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 0.5 * vw),
                          Input(
                              controller: _conceptoEditController,
                              hint: 'Concepto'),
                          SizedBox(height: 1 * vw),
                          Container(
                            width: 49 * vw,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 24 * vw,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Tipo de unidad',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 1.2 * vw,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(height: 0.5 * vw),
                                      Input(
                                          controller: _unidadEditController,
                                          hint: 'Tipo de unidad'),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 8 * vw,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Cantidad',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 1.2 * vw,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(height: 0.5 * vw),
                                      Input(
                                        controller: _cantidadEditController,
                                        hint: 'Cantidad',
                                        keyboardType: TextInputType.number,
                                        pattern: RegExp(r'[0-9]'),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 15 * vw,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Precio unitario',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 1.2 * vw,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(height: 0.5 * vw),
                                      Input(
                                        controller:
                                            _precioUnitarioEditController,
                                        hint: 'Precio unitario',
                                        keyboardType: TextInputType.number,
                                        pattern: RegExp(r'[0-9.]'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2 * vw),
                          GestureDetector(
                            onTap: () {
                              var concepto =
                                  _conceptoEditController.text.trim();
                              var unidad = _unidadEditController.text.trim();
                              var cantidad = double.tryParse(
                                  _cantidadEditController.text.trim());
                              var precioUnitario = double.tryParse(
                                  _precioUnitarioEditController.text.trim());
                              if (concepto.isNotEmpty &&
                                  unidad.isNotEmpty &&
                                  cantidad != null &&
                                  precioUnitario != null) {
                                var total = cantidad * precioUnitario;
                                Map<String, dynamic> editedProduct = {
                                  'concepto': concepto,
                                  'tipo_unidad': unidad,
                                  'cantidad': cantidad,
                                  'precio_unitario': precioUnitario,
                                  'importe_total': total,
                                  'id': product['id'],
                                  'subgrupo_id': product['subgrupo_id'],
                                };

                                editProduct(editedProduct);
                              } else {
                                CustomSnackBar(context: context).show(
                                    'Los campos del producto no pueden estar vacíos.');
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 3.5 * vw,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Center(
                                child: Text(
                                  'Guardar',
                                  style: TextStyle(
                                    color: Theme.of(context).splashColor,
                                    fontSize: 1.2 * vw,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    var vw = responsive.viewportWidth;

    return Customscaffold(
      groupId: widget.groupId,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.5 * vw),
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 18.4 * vw,
                  child: Column(
                    children: [
                      Container(
                        width: 18.4 * vw,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PROPUESTAS',
                              style: TextStyle(
                                  fontSize: 1.6 * vw,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor),
                            ),
                            GestureDetector(
                              onTap: _showAddGroupDialog,
                              child: Container(
                                padding: EdgeInsets.all(0.75 * vw),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 0.1 * vw,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                child: Center(
                                  child: Text('Añadir'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _futureSubGroups,
                        builder: (
                          context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                        ) {
                          if (!snapshot.hasData) {
                            return SizedBox();
                          }
                          if (snapshot.data!.isEmpty) {
                            return Container(
                              width: 18.4 * vw,
                              margin: EdgeInsets.only(top: 1.5 * vw),
                              child: Text(
                                'No se encontraron propuestas.',
                                style: TextStyle(
                                  fontSize: 1.2 * vw,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            );
                          }
                          final subGroups = snapshot.data!;

                          return Container(
                            width: double.maxFinite,
                            height: 5 * vw * subGroups.length,
                            child: ListView.builder(
                              itemCount: subGroups.length,
                              itemBuilder: (context, index) {
                                final subGroup = subGroups[index];
                                return SubgroupOption(
                                  subGroup: subGroup,
                                  isFocused:
                                      subGroup['id'] == widget.subGroupId,
                                  margin: EdgeInsets.only(top: 1.5 * vw),
                                  onPressed: () => Routes(context).goTo(
                                    GroupView(
                                      groupId: widget.groupId,
                                      subGroupId: subGroup['id'],
                                    ),
                                  ),
                                  onLongPress: () => _showEditSubGroupDialog(
                                    subGroup['nombre'],
                                    subGroup['id'],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                widget.subGroupId == 0
                    ? SizedBox()
                    : Container(
                        width: 75.1 * vw,
                        padding: EdgeInsets.only(left: 1.5 * vw),
                        decoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    width: 0.1 * vw,
                                    color: Theme.of(context).shadowColor))),
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: _futureProducts,
                          builder: (context,
                              AsyncSnapshot<Map<String, dynamic>> snapshot) {
                            if (!snapshot.hasData) {
                              return SizedBox();
                            }
                            var data = snapshot.data!;
                            var products = data['productos'];
                            return Column(
                              children: [
                                Container(
                                  width: double.maxFinite,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'PRODUCTOS',
                                            style: TextStyle(
                                                fontSize: 1.6 * vw,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          SizedBox(height: 0.25 * vw),
                                          Row(
                                            children: [
                                              Text(
                                                'Total:',
                                                style: TextStyle(
                                                    fontSize: 1.6 * vw,
                                                    fontWeight: FontWeight.w400,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                              SizedBox(width: 0.5 * vw),
                                              Text(
                                                Formatter.money(
                                                    data['total_importe']),
                                                style: TextStyle(
                                                    fontSize: 1.6 * vw,
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          !isOpen && products.isNotEmpty
                                              ? BoxButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isOpen = true;
                                                    });
                                                  },
                                                  label: 'Seleccionar',
                                                  isFocused: false,
                                                )
                                              : SizedBox(),
                                          !isOpen
                                              ? BoxButton(
                                                  onPressed:
                                                      _showAddProductDialog,
                                                  label: 'Añadir producto',
                                                  margin: EdgeInsets.only(
                                                      left: 1.5 * vw),
                                                  isFocused: false,
                                                )
                                              : SizedBox(),
                                          isOpen
                                              ? BoxButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      isOpen = false;
                                                      pickedItems.clear();
                                                    });
                                                  },
                                                  label: '  X  ',
                                                  margin: EdgeInsets.only(
                                                      left: 1.5 * vw),
                                                  isFocused: false,
                                                )
                                              : SizedBox(),
                                          isOpen
                                              ? BoxButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      var unselected = [];
                                                      for (int i = 0;
                                                          i < products.length;
                                                          i++) {
                                                        if (products[i][
                                                                'is_selected'] ==
                                                            0) {
                                                          unselected
                                                              .add(products[i]);
                                                        }
                                                      }
                                                      if (pickedItems.length ==
                                                          unselected.length) {
                                                        pickedItems.clear();
                                                      } else {
                                                        pickedItems.clear();
                                                        for (int i = 0;
                                                            i < products.length;
                                                            i++) {
                                                          if (products[i][
                                                                  'is_selected'] ==
                                                              0) {
                                                            pickedItems.add(
                                                                products[i]
                                                                    ['id']);
                                                          }
                                                        }
                                                      }
                                                    });
                                                  },
                                                  label: 'Seleccionar todos',
                                                  margin: EdgeInsets.only(
                                                      left: 1.5 * vw),
                                                  isFocused: false,
                                                )
                                              : SizedBox(),
                                          isOpen
                                              ? BoxButton(
                                                  onPressed: () async {
                                                    if (pickedItems.isEmpty) {
                                                      CustomSnackBar(
                                                              context: context)
                                                          .show(
                                                              'No hay productos seleccionados.');
                                                    } else {
                                                      final bool confirmSend =
                                                          await _showConfirmationDialog(
                                                              title:
                                                                  'Aceptar y enviar',
                                                              subTitle:
                                                                  'Este producto se enviará a la cotización final.');
                                                      if (confirmSend) {
                                                        for (int i = 0;
                                                            i <
                                                                pickedItems
                                                                    .length;
                                                            i++) {
                                                          if (kIsWeb) {
                                                            webDatabaseService
                                                                .updateProductoSeleccion(
                                                                    pickedItems[
                                                                        i],
                                                                    true);
                                                          } else {
                                                            DatabaseService
                                                                .instance
                                                                .updateProductoSeleccion(
                                                                    pickedItems[
                                                                        i],
                                                                    true);
                                                          }
                                                        }
                                                        setState(() {
                                                          pickedItems.clear();
                                                          isOpen = false;
                                                        });
                                                        _reload();
                                                        Routes(context).goTo(
                                                            GroupView(
                                                                groupId: widget
                                                                    .groupId,
                                                                subGroupId: widget
                                                                    .subGroupId));
                                                      }
                                                    }
                                                  },
                                                  label: 'Aceptar y enviar',
                                                  margin: EdgeInsets.only(
                                                      left: 1.5 * vw),
                                                  isFocused: false,
                                                )
                                              : SizedBox(),
                                          isOpen
                                              ? BoxButton(
                                                  onPressed: () async {
                                                    if (pickedItems.isEmpty) {
                                                      CustomSnackBar(
                                                              context: context)
                                                          .show(
                                                              'No hay productos seleccionados.');
                                                    } else {
                                                      final bool confirmDelete =
                                                          await _showDeleteConfirmationDialog(
                                                              title:
                                                                  'Eliminar producto(s)',
                                                              subTitle:
                                                                  '¿Estás seguro que deseas eliminarlo(s)?, todos los datos se perderán.');
                                                      if (confirmDelete) {
                                                        for (int i = 0;
                                                            i <
                                                                pickedItems
                                                                    .length;
                                                            i++) {
                                                          if (kIsWeb) {
                                                            webDatabaseService
                                                                .deleteProducto(
                                                                    pickedItems[
                                                                        i]);
                                                          } else {
                                                            DatabaseService
                                                                .instance
                                                                .deleteProducto(
                                                                    pickedItems[
                                                                        i]);
                                                          }
                                                        }
                                                        setState(() {
                                                          pickedItems.clear();
                                                          isOpen = false;
                                                        });
                                                        _reload();
                                                      }
                                                    }
                                                  },
                                                  label:
                                                      'Eliminar de la propuesta',
                                                  margin: EdgeInsets.only(
                                                      left: 1.5 * vw),
                                                  isFocused: false,
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 0.75 * vw),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        isOpen
                                            ? 'Productos seleccionados (${pickedItems.length})'
                                            : '',
                                      ),
                                    ],
                                  ),
                                ),
                                products.isNotEmpty
                                    ? Container(
                                        width: 73.5 * vw,
                                        height: 15.5 * vw * products.length,
                                        child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: products.length,
                                          itemBuilder: (context, index) {
                                            var product = products[index];
                                            return ProductCard(
                                              isPicked: pickedItems
                                                  .contains(product['id']),
                                              isOpen: isOpen,
                                              onTap: () =>
                                                  _showEditProductDialog(
                                                      product),
                                              product: product,
                                              //aqui
                                              onLongPress: () {
                                                setState(() {
                                                  if (isOpen) {
                                                    pickedItems.clear();
                                                  }
                                                  isOpen = !isOpen;
                                                });
                                              },
                                              onPick: () {
                                                setState(() {
                                                  if (pickedItems.contains(
                                                      product['id'])) {
                                                    pickedItems.removeWhere(
                                                        (element) =>
                                                            element ==
                                                            product['id']);
                                                  } else {
                                                    pickedItems
                                                        .add(product['id']);
                                                  }
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      )
                                    : Text('No se encontraron productos.'),
                              ],
                            );
                          },
                        ),
                      ),
              ],
            ),
            SizedBox(height: 1.5 * vw),
          ],
        ),
      ),
    );
  }
}
