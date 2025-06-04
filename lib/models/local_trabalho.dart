import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'local_trabalho.g.dart'; // Gerado pelo Hive

@HiveType(typeId: 0) // ID único para o tipo
class LocalTrabalho extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nome;

  @HiveField(2)
  int corHex; // Armazenar como int (ex: 0xFFRRGGBB)

  LocalTrabalho({required this.id, required this.nome, required this.corHex});

  Color get cor => Color(corHex);

  // Para DropdownButton ou comparações
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalTrabalho &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
