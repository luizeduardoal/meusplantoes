import 'package:hive/hive.dart';

part 'plantao.g.dart'; // Gerado pelo Hive

@HiveType(typeId: 1)
class Plantao extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String localTrabalhoId; // Referência ao ID do LocalTrabalho

  @HiveField(2)
  double valor;

  @HiveField(3)
  DateTime? dataPagamento;

  @HiveField(4)
  bool pago;

  @HiveField(5)
  DateTime dataHoraInicio;

  @HiveField(6)
  DateTime dataHoraFim;

  @HiveField(7)
  String? comentarios;

  Plantao({
    required this.id,
    required this.localTrabalhoId,
    required this.valor,
    this.dataPagamento,
    required this.pago,
    required this.dataHoraInicio,
    required this.dataHoraFim,
    this.comentarios,
  });
}
