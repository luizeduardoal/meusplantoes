import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:meus_plantoes_app/models/local_trabalho.dart';
import 'package:uuid/uuid.dart';

class LocaisProvider with ChangeNotifier {
  final Box<LocalTrabalho> _locaisBox = Hive.box<LocalTrabalho>(
    'locais_trabalho',
  );
  final Uuid _uuid = Uuid();

  List<LocalTrabalho> get locais {
    // Retorna uma lista dos valores da box.
    // É importante converter para List para evitar problemas de modificação
    // em uma coleção que está sendo iterada (LazyBoxCollection).
    return _locaisBox.values.toList();
  }

  Future<void> adicionarOuEditarLocal(
    String? id,
    String nome,
    Color cor,
  ) async {
    final novoLocal = LocalTrabalho(
      id: id ?? _uuid.v4(), // Usa ID existente ou gera um novo
      nome: nome,
      corHex: cor.value, // Salva o valor int da cor
    );

    // Hive usa 'put' para adicionar e atualizar. A chave é o ID.
    await _locaisBox.put(novoLocal.id, novoLocal);
    notifyListeners();
  }

  Future<void> removerLocal(String id) async {
    await _locaisBox.delete(id);
    // Adicional: remover plantões associados a este local ou marcá-los como "local desconhecido"
    notifyListeners();
  }

  LocalTrabalho? getLocalById(String id) {
    return _locaisBox.get(id);
  }
}
