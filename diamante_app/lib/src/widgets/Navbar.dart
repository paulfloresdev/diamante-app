import 'package:diamante_app/src/models/auxiliars/Router.dart';
import 'package:diamante_app/src/views/GroupView.dart';
import 'package:flutter/material.dart';

import '../database/DatabaseService.dart';
import '../models/auxiliars/Responsive.dart';
import '../views/OverView.dart';
import 'Buttons/BoxButton.dart';
import 'dialogs-snackbars/ConfirmDialog.dart';
import 'dialogs-snackbars/CustomSnackBar.dart';
import 'dialogs-snackbars/SingleInputDialog.dart';

class Navbar extends StatefulWidget{
  final int groupId;
  const Navbar({super.key, required this.groupId});

  @override
  State<Navbar> createState() => _NavbarState();
  
}

class _NavbarState extends State<Navbar> {
  final TextEditingController _addGroupController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _futureGroups;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _reload();
  }

  void _reload() {
    _futureGroups = DatabaseService.instance.getAllGrupos();
  }

  // Agregar nuevo grupo
  Future<void> addGroup() async {
    final groupName = _addGroupController.text.trim();
    if (groupName.isNotEmpty) {
      await DatabaseService.instance.createGrupo(groupName);
      CustomSnackBar(context: context).show('Grupo creado correctamente.');
      setState(() {
        // Actualiza la lista de grupos después de agregar uno
        _reload();
      });
      _addGroupController.clear();
      Navigator.of(context).pop(); // Cierra el diálogo
    } else {
      CustomSnackBar(context: context)
          .show('El nombre del grupo no puede estar vacío.');
    }
  }

  void _showAddGroupDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SingleInputDialog(
          title: 'Nuevo grupo',
          inputController: _addGroupController,
          inputHint: 'Nombre',
          onConfirm: addGroup,
          confirmLabel: 'Guardar',
        );
      },
    );
  }

  Future<void> editGroup(String newGroupName, int groupId) async {
    if (newGroupName.isNotEmpty) {
      await DatabaseService.instance.updateGrupo(groupId, newGroupName);
      CustomSnackBar(context: context).show('Grupo actualizado correctamente.');
      _reload(); // Recarga los grupos.
      Navigator.of(context).pop(); // Cierra el diálogo.
    } else {
      CustomSnackBar(context: context)
          .show('El nombre del grupo no puede estar vacío.');
    }
  }

  void _showEditGroupDialog(String currentName, int groupId) {
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
          onConfirm: () => editGroup(editController.text.trim(), groupId),
          confirmLabel: 'Guardar',
          onDecline: () async {
            var hasSelectedProducts = await DatabaseService.instance.groupHasSelectedProducts(groupId);

            if(hasSelectedProducts){
              CustomSnackBar(context: context)
                  .show('No es posible eliminar este grupo ya que contiene productos seleccionados, puedes eliminar de tu selección estos productos en la pestaña \'Cotización\'');
            }else{
              final bool confirmDelete = await _showDeleteConfirmationDialog();

              if (confirmDelete) {
                await DatabaseService.instance.deleteGrupo(groupId);
                CustomSnackBar(context: context)
                    .show('Grupo eliminado correctamente.');

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
          declineLabel: 'Eliminar',
        );
      },
    );
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return (await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialog(
              title: 'Confirmar Eliminación',
              subTitle:
                  '¿Estás seguro de que deseas eliminar este grupo?\nTodos los datos contenidos en él también se perderán.',
              confirmLabel: 'Eliminar',
              confirmColor: Colors.redAccent.shade700,
              declineLabel: 'Cancelar',
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
        SizedBox(height: 1.5*vw),
        Container(
          width: double.infinity,
          height: 5 * vw,
          padding: EdgeInsets.symmetric( horizontal: 2.5*vw),
          child: Row(
            children: [
              BoxButton(
                label: '+',
                width: 5*vw,
                fontSize: 1.75*vw,
                onPressed: _showAddGroupDialog,
                isFocused: false,
              ),
              BoxButton(
                label: 'Cotización',
                width: 8.5*vw,
                onPressed: () => Routes(context).goTo(OverView()),
                isFocused: widget.groupId == 0,
                margin: EdgeInsets.only(left: 1.5*vw),
              ),
              Container(
                width: 80*vw,
                height: 5*vw,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _futureGroups, 
                  builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot){
                    if(!snapshot.hasData){
                      return Center(child: Text('Cargando...'));
                    }
                    var groups = snapshot.data;
                    if(groups!.isEmpty){
                      return Center(child: Text('No se encontraron grupos.'));
                    }
        
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: groups.length,
                      itemBuilder: (context, index){
                        var group = groups[index];
                        return BoxButton(
                          label: group['nombre'], 
                          onPressed: () async {
                            var subGroups = await DatabaseService.instance.getSubgruposByGrupo(group['id']);

                            var subGroupId = 0;

                            if(subGroups.isNotEmpty){
                              print('Listado de productos no vacío');

                              for(var subGroup in subGroups) {
                                var hasSelected = await DatabaseService.instance.hasSelectedProducts(subGroup['id']);
                                print('Iteración--> Id: ${subGroup['id']} | hasSelected: $hasSelected');

                                if(hasSelected){
                                  subGroupId = subGroup['id'];
                                }
                              }

                              print('Despues de iteración--> subGroupId: $subGroupId');

                              if(subGroupId == 0){
                                subGroupId = subGroups.first['id'];
                              }
                            }

                            print('Valores a envíar--> groupId: ${group['id']} | subGroupId: $subGroupId');
                            Routes(context).goTo(GroupView(groupId: group['id'], subGroupId: subGroupId));
                            
                          },
                          onLongPress: () => _showEditGroupDialog(
                                      group['nombre'], group['id']),
                                      isFocused: widget.groupId == group['id'],
                          margin: EdgeInsets.only(left: 1.5*vw),
                        );
                      }
                    );
                  }
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.5*vw),
        Container(
          width: 95*vw,
          height: 0.1*vw,
          color: Colors.grey.shade400,
        ),
        SizedBox(height: 1.5*vw),
      ],
    );
  }
}