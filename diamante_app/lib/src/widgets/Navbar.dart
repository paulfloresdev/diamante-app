import 'package:diamante_app/src/models/auxiliars/Router.dart';
import 'package:diamante_app/src/views/GroupView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/DatabaseService.dart';
import '../database/WebDatabaseService.dart';
import '../models/auxiliars/Responsive.dart';
import '../views/OverView.dart';
import 'Buttons/BoxButton.dart';
import 'dialogs-snackbars/ConfirmDialog.dart';
import 'dialogs-snackbars/CustomSnackBar.dart';
import 'dialogs-snackbars/SingleInputDialog.dart';

class Navbar extends StatefulWidget {
  final int groupId;
  const Navbar({super.key, required this.groupId});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late var webDatabaseService;

  final TextEditingController _addGroupController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _futureGroups;

  String language = 'en';

  getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      language = prefs.getString('language') ?? 'en';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLanguage();
    webDatabaseService = kIsWeb ? 
        Provider.of<WebDatabaseService>(context, listen: false) : null;
    _reload();
  }

  void _reload() {
    setState(() {
      if (kIsWeb) {
        _futureGroups = webDatabaseService.getAllGrupos();
      } else {
        _futureGroups = DatabaseService.instance.getAllGrupos();
      }
    });
  }

  // Agregar nuevo grupo
  Future<void> addGroup() async {
    final groupName = _addGroupController.text.trim();
    if (groupName.isNotEmpty) {
      if (kIsWeb) {
        await webDatabaseService.createGrupo(groupName);
      } else {
        await DatabaseService.instance.createGrupo(groupName);
      }

      CustomSnackBar(context: context).show(language == 'en'
          ? 'Group created successfully.'
          : 'Grupo creado correctamente.');
      setState(() {
        // Actualiza la lista de grupos después de agregar uno
        _reload();
      });
      _addGroupController.clear();
      Navigator.of(context).pop(); // Cierra el diálogo
    } else {
      CustomSnackBar(context: context)
          .show(language == 'en'
          ? 'Group name can´t be empty.'
          : 'El nombre del grupo no puede estar vacío.');
    }
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleInputDialog(
          title: language == 'en' ? 'New group' : 'Nuevo grupo',
          inputController: _addGroupController,
          inputHint: language == 'en' ? 'Name' : 'Nombre',
          onConfirm: addGroup,
          confirmLabel: language == 'en' ? 'Save' : 'Guardar',
        );
      },
    );
  }

  Future<void> editGroup(String newGroupName, int groupId) async {
    if (newGroupName.isNotEmpty) {
      if (kIsWeb) {
        await webDatabaseService.updateGrupo(groupId, newGroupName);
      } else {
        await DatabaseService.instance.updateGrupo(groupId, newGroupName);
      }

      CustomSnackBar(context: context).show(language == 'en'
          ? 'Group updated successfully.'
          : 'Grupo actualizado correctamente.');
      _reload(); // Recarga los grupos.
      Navigator.of(context).pop(); // Cierra el diálogo.
    } else {
      CustomSnackBar(context: context)
          .show(language == 'en'
          ? 'Group name can´t be empty.'
          : 'El nombre del grupo no puede estar vacío.');
    }
  }

  void _showEditGroupDialog(String currentName, int groupId) {
    final TextEditingController editController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return SingleInputDialog(
          title: language == 'en' ? 'Update group' : 'Editar grupo',
          inputController: editController,
          inputHint: language == 'en' ? 'Name' : 'Nombre',
          inputValue: currentName,
          onConfirm: () => editGroup(editController.text.trim(), groupId),
          confirmLabel: language == 'en' ? 'Save' : 'Guardar',
          onDecline: () async {
            late var hasSelectedProducts;
            if (kIsWeb) {
              hasSelectedProducts =
                  await webDatabaseService.groupHasSelectedProducts(groupId);
            } else {
              hasSelectedProducts = await DatabaseService.instance
                  .groupHasSelectedProducts(groupId);
            }

            if (hasSelectedProducts) {
              CustomSnackBar(context: context).show(
                  language == 'en'
                  ? 'It is not possible to delete this group as it contains selected products. You can remove these products from your selection in the \'Quotation\' tab.'
                  : 'No es posible eliminar este grupo ya que contiene productos seleccionados, puedes eliminar de tu selección estos productos en la pestaña \'Cotización\'');
            } else {
              final bool confirmDelete = await _showDeleteConfirmationDialog();

              if (confirmDelete) {
                if (kIsWeb) {
                  await webDatabaseService.deleteGrupo(groupId);
                } else {
                  await DatabaseService.instance.deleteGrupo(groupId);
                }

                CustomSnackBar(context: context)
                    .show(language == 'en'
                    ? 'Group deleted successfully.'
                    : 'Grupo eliminado correctamente.');

                // Cierra el diálogo inmediatamente
                Navigator.of(context).pop();

                // Actualiza la lista de grupos después de eliminar
                setState(() {
                  _reload();
                });

                // Verifica si el grupo eliminado es el que está visible en la página actual
                if (groupId == widget.groupId) {
                  // Realiza la navegación después de que el diálogo se cierre
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OverView()), // Navega a Overview
                  );
                }
              } else {
                Navigator.of(context)
                    .pop(); // Cierra el diálogo si no se confirma la eliminación
              }
            }
          },
          declineLabel: language == 'en' ? 'Delete' : 'Eliminar',
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialog(
              title: language == 'en' ? 'Confirm Delete' : 'Confirmar Eliminación',
              subTitle:
                  language == 'en'
                  ? 'Are you sure you want to delete this group?\nAll data will be deleted as well.'
                  : '¿Estás seguro de que deseas eliminar este grupo?\nTodos los datos contenidos en él también se perderán.',
              confirmLabel: language == 'en' ? 'Delete' : 'Eliminar',
              confirmColor: Colors.redAccent.shade700,
              declineLabel: language == 'en' ? 'Cancel' : 'Cancelar',
              declineColor: Colors.grey.shade700,
            );
          },
        )) ??
        false; // Devuelve false si el valor retornado es nulo
  }

  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    double vw = responsive.viewportWidth;

    return Column(
      children: [
        SizedBox(height: 1.5 * vw),
        Container(
          width: double.infinity,
          height: 5 * vw,
          padding: EdgeInsets.symmetric(horizontal: 2.5 * vw),
          child: Row(
            children: [
              BoxButton(
                label: '+',
                width: 5 * vw,
                fontSize: 1.75 * vw,
                onPressed: _showAddGroupDialog,
                isFocused: false,
              ),
              BoxButton(
                label: language == 'en' ? 'Quotation' : 'Cotización',
                width: 8.5 * vw,
                onPressed: () => Routes(context).goTo(OverView()),
                isFocused: widget.groupId == 0,
                margin: EdgeInsets.only(left: 1.5 * vw),
              ),
              Container(
                width: 80 * vw,
                height: 5 * vw,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _futureGroups,
                    builder: (context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: Text(language == 'en'
                                ? 'Loading...'
                                : 'Cargando...'));
                      }
                      var groups = snapshot.data;
                      if (groups!.isEmpty) {
                        return Center(child: Text(''));
                      }

                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            var group = groups[index];
                            return BoxButton(
                              label: group['nombre'],
                              onPressed: () async {
                                late var subGroups;

                                if (kIsWeb) {
                                  subGroups = await webDatabaseService
                                      .getSubgruposByGrupo(group['id']);
                                } else {
                                  subGroups = await DatabaseService.instance
                                      .getSubgruposByGrupo(group['id']);
                                }

                                var subGroupId = 0;

                                if (subGroups.isNotEmpty) {
                                  print('Listado de productos no vacío');

                                  for (var subGroup in subGroups) {
                                    late var hasSelected;

                                    if (kIsWeb) {
                                      hasSelected = await webDatabaseService
                                          .hasSelectedProducts(subGroup['id']);
                                    } else {
                                      hasSelected = await DatabaseService
                                          .instance
                                          .hasSelectedProducts(subGroup['id']);
                                    }

                                    print(
                                        'Iteración--> Id: ${subGroup['id']} | hasSelected: $hasSelected');

                                    if (hasSelected) {
                                      subGroupId = subGroup['id'];
                                    }
                                  }

                                  print(
                                      'Despues de iteración--> subGroupId: $subGroupId');

                                  if (subGroupId == 0) {
                                    subGroupId = subGroups.first['id'];
                                  }
                                }

                                print(
                                    'Valores a envíar--> groupId: ${group['id']} | subGroupId: $subGroupId');
                                Routes(context).goTo(GroupView(
                                    groupId: group['id'],
                                    subGroupId: subGroupId));
                              },
                              onLongPress: () => _showEditGroupDialog(
                                  group['nombre'], group['id']),
                              isFocused: widget.groupId == group['id'],
                              margin: EdgeInsets.only(left: 1.5 * vw),
                            );
                          });
                    }),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.5 * vw),
        Container(
          width: 95 * vw,
          height: 0.1 * vw,
          color: Theme.of(context).shadowColor,
        ),
        SizedBox(height: 1.5 * vw),
      ],
    );
  }
}
