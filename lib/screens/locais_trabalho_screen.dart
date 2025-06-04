import 'package:flutter/material.dart';
//import 'package:meus_plantoes_app/models/local_trabalho.dart';
import 'package:meus_plantoes_app/providers/locais_provider.dart';
import 'package:meus_plantoes_app/screens/add_edit_local_trabalho_screen.dart';
import 'package:provider/provider.dart';

class LocaisTrabalhoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O FAB foi movido para HomeScreen
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(builder: (ctx) => AddEditLocalTrabalhoScreen()),
      //     );
      //   },
      // ),
      body: Consumer<LocaisProvider>(
        builder: (ctx, locaisProvider, _) {
          if (locaisProvider.locais.isEmpty) {
            return Center(
              child: Text(
                'Nenhum local cadastrado.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: locaisProvider.locais.length,
            itemBuilder: (ctx, i) {
              final local = locaisProvider.locais[i];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: local.cor, radius: 20),
                  title: Text(
                    local.nome,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (ctx) => AddEditLocalTrabalhoScreen(
                                    localTrabalho: local,
                                  ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () async {
                          // Adicionar confirmação antes de deletar
                          final confirm =
                              await showDialog<bool>(
                                context: context,
                                builder:
                                    (BuildContext context) => AlertDialog(
                                      title: const Text('Confirmar Exclusão'),
                                      content: Text(
                                        'Deseja realmente excluir o local "${local.nome}"? Isso não pode ser desfeito.',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                          child: const Text(
                                            'Excluir',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              ) ??
                              false; // ?? false para caso o dialog seja dispensado

                          if (confirm) {
                            try {
                              await Provider.of<LocaisProvider>(
                                context,
                                listen: false,
                              ).removerLocal(local.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${local.nome} removido com sucesso!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Falha ao remover ${local.nome}: $error',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
