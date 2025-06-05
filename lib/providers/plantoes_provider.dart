// IMPORTS MANTIDOS
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:meus_plantoes_app/models/plantao.dart';
import 'package:uuid/uuid.dart';

class PlantoesProvider with ChangeNotifier {
  final Box<Plantao> _plantoesBox = Hive.box<Plantao>('plantoes');
  final Uuid _uuid = Uuid();

  List<Plantao> get plantoes {
    var lista = _plantoesBox.values.toList();
    lista.sort((a, b) => b.dataHoraInicio.compareTo(a.dataHoraInicio));
    return lista;
  }

  List<Plantao> getPlantoesPorDia(DateTime dia) {
    return plantoes.where((plantao) {
      return plantao.dataHoraInicio.year == dia.year &&
          plantao.dataHoraInicio.month == dia.month &&
          plantao.dataHoraInicio.day == dia.day;
    }).toList();
  }

  Map<DateTime, List<Plantao>> get plantoesAgrupadosPorDia {
    final Map<DateTime, List<Plantao>> map = {};
    for (var plantao in plantoes) {
      final diaNormalizado = DateTime(
        plantao.dataHoraInicio.year,
        plantao.dataHoraInicio.month,
        plantao.dataHoraInicio.day,
      );
      map.putIfAbsent(diaNormalizado, () => []);
      map[diaNormalizado]!.add(plantao);
    }
    return map;
  }

  Future<void> adicionarOuEditarPlantao({
    String? id,
    required String localTrabalhoId,
    required double valor,
    required DateTime dataPagamento,
    required bool pago,
    required DateTime dataHoraInicio,
    required DateTime dataHoraFim,
    String? comentarios,
  }) async {
    final novoPlantao = Plantao(
      id: id ?? _uuid.v4(),
      localTrabalhoId: localTrabalhoId,
      valor: valor,
      dataPagamento: dataPagamento,
      pago: pago,
      dataHoraInicio: dataHoraInicio,
      dataHoraFim: dataHoraFim,
      comentarios: comentarios,
    );
    await _plantoesBox.put(novoPlantao.id, novoPlantao);
    notifyListeners();
  }

  Future<void> removerPlantao(String id) async {
    await _plantoesBox.delete(id);
    notifyListeners();
  }

  Future<void> atualizarStatusPagamento(String plantaoId, bool pago) async {
    final plantao = _plantoesBox.get(plantaoId);
    if (plantao != null) {
      plantao.pago = pago;
      await plantao.save();
      notifyListeners();
    }
  }

  Map<String, Map<String, double>> getRelatorioMensal() {
    final Map<String, Map<String, double>> relatorio = {};

    for (var plantao in plantoes) {
      final String mesAno = DateFormat(
        'yyyy-MM',
      ).format(plantao.dataPagamento!);

      relatorio.putIfAbsent(mesAno, () => {'pago': 0.0, 'naoPago': 0.0});

      if (plantao.pago) {
        relatorio[mesAno]!['pago'] =
            (relatorio[mesAno]!['pago'] ?? 0.0) + plantao.valor;
      } else {
        relatorio[mesAno]!['naoPago'] =
            (relatorio[mesAno]!['naoPago'] ?? 0.0) + plantao.valor;
      }
    }

    final sortedKeys = relatorio.keys.toList()..sort((a, b) => b.compareTo(a));
    final Map<String, Map<String, double>> sortedRelatorio = {
      for (var key in sortedKeys) key: relatorio[key]!,
    };
    return sortedRelatorio;
  }

  Map<String, Map<String, Map<String, double>>> getRelatorioMensalPorLocal() {
    final Map<String, Map<String, Map<String, double>>> relatorio = {};

    for (var plantao in plantoes) {
      final String mesAno = DateFormat(
        'yyyy-MM',
      ).format(plantao.dataPagamento!);
      final String local = plantao.localTrabalhoId;

      relatorio.putIfAbsent(mesAno, () => {});
      relatorio[mesAno]!.putIfAbsent(
        local,
        () => {'pago': 0.0, 'naoPago': 0.0},
      );

      if (plantao.pago) {
        relatorio[mesAno]![local]!['pago'] =
            (relatorio[mesAno]![local]!['pago'] ?? 0.0) + plantao.valor;
      } else {
        relatorio[mesAno]![local]!['naoPago'] =
            (relatorio[mesAno]![local]!['naoPago'] ?? 0.0) + plantao.valor;
      }
    }

    final sortedKeys = relatorio.keys.toList()..sort((a, b) => b.compareTo(a));
    final Map<String, Map<String, Map<String, double>>> relatorioOrdenado = {
      for (var k in sortedKeys) k: relatorio[k]!,
    };

    return relatorioOrdenado;
  }
}

// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:intl/intl.dart';
// import 'package:meus_plantoes_app/models/plantao.dart';
// import 'package:uuid/uuid.dart';
// //import 'package:meus_plantoes_app/providers/locais_provider.dart';

// class PlantoesProvider with ChangeNotifier {
//   final Box<Plantao> _plantoesBox = Hive.box<Plantao>('plantoes');
//   final Uuid _uuid = Uuid();

//   List<Plantao> get plantoes {
//     // Ordenar por data de início, do mais recente para o mais antigo
//     var lista = _plantoesBox.values.toList();
//     lista.sort((a, b) => b.dataHoraInicio.compareTo(a.dataHoraInicio));
//     return lista;
//   }

//   List<Plantao> getPlantoesPorDia(DateTime dia) {
//     return plantoes.where((plantao) {
//       return plantao.dataHoraInicio.year == dia.year &&
//           plantao.dataHoraInicio.month == dia.month &&
//           plantao.dataHoraInicio.day == dia.day;
//     }).toList();
//   }

//   Map<DateTime, List<Plantao>> get plantoesAgrupadosPorDia {
//     final Map<DateTime, List<Plantao>> map = {};
//     for (var plantao in plantoes) {
//       final diaNormalizado = DateTime(
//         plantao.dataHoraInicio.year,
//         plantao.dataHoraInicio.month,
//         plantao.dataHoraInicio.day,
//       );
//       if (map[diaNormalizado] == null) {
//         map[diaNormalizado] = [];
//       }
//       map[diaNormalizado]!.add(plantao);
//     }
//     return map;
//   }

//   Future<void> adicionarOuEditarPlantao({
//     String? id,
//     required String localTrabalhoId,
//     required double valor,
//     DateTime? dataPagamento,
//     required bool pago,
//     required DateTime dataHoraInicio,
//     required DateTime dataHoraFim,
//     String? comentarios,
//   }) async {
//     final novoPlantao = Plantao(
//       id: id ?? _uuid.v4(),
//       localTrabalhoId: localTrabalhoId,
//       valor: valor,
//       dataPagamento: dataPagamento,
//       pago: pago,
//       dataHoraInicio: dataHoraInicio,
//       dataHoraFim: dataHoraFim,
//       comentarios: comentarios,
//     );
//     await _plantoesBox.put(novoPlantao.id, novoPlantao);
//     notifyListeners();
//   }

//   Future<void> removerPlantao(String id) async {
//     await _plantoesBox.delete(id);
//     notifyListeners();
//   }

//   Future<void> atualizarStatusPagamento(String plantaoId, bool pago) async {
//     final plantao = _plantoesBox.get(plantaoId);
//     if (plantao != null) {
//       plantao.pago = pago;
//       await plantao.save(); // Salva a alteração no HiveObject
//       // Ou, se não estiver usando HiveObject diretamente para atualização:
//       // await _plantoesBox.put(plantaoId, plantao);
//       notifyListeners();
//     }
//   }

//   // Método para o relatório mensal
//   // Retorna: {"AAAA-MM": {"pago": valor, "naoPago": valor}}
//   Map<String, Map<String, double>> getRelatorioMensal() {
//     final Map<String, Map<String, double>> relatorio = {};

//     for (var plantao in plantoes) {
//       // Usar a data de início do plantão para agrupar mensalmente
//       final String mesAno = DateFormat(
//         'yyyy-MM',
//       ).format(plantao.dataPagamento!);

//       if (!relatorio.containsKey(mesAno)) {
//         relatorio[mesAno] = {'pago': 0.0, 'naoPago': 0.0};
//       }

//       if (plantao.pago) {
//         relatorio[mesAno]!['pago'] =
//             (relatorio[mesAno]!['pago'] ?? 0.0) + plantao.valor;
//       } else {
//         relatorio[mesAno]!['naoPago'] =
//             (relatorio[mesAno]!['naoPago'] ?? 0.0) + plantao.valor;
//       }
//     }
//     // Ordenar o relatório por chave (mês/ano) decrescente
//     var sortedKeys = relatorio.keys.toList()..sort((a, b) => b.compareTo(a));
//     Map<String, Map<String, double>> sortedRelatorio = {};
//     for (var key in sortedKeys) {
//       sortedRelatorio[key] = relatorio[key]!;
//     }
//     return sortedRelatorio;
//   }

//   Map<String, Map<String, Map<String, double>>> getRelatorioMensalPorLocal() {
//     final Map<String, Map<String, Map<String, double>>> relatorio = {};

//     for (var plantao in plantoes) {
//       final String mesAno = DateFormat(
//         'yyyy-MM',
//       ).format(plantao.dataPagamento!);

//       final String local = plantao.localTrabalhoId;

//       relatorio.putIfAbsent(mesAno, () => {});
//       relatorio[mesAno]!.putIfAbsent(
//         local,
//         () => {'pago': 0.0, 'naoPago': 0.0},
//       );

//       if (plantao.pago) {
//         relatorio[mesAno]![local]!['pago'] =
//             (relatorio[mesAno]![local]!['pago'] ?? 0.0) + plantao.valor;
//       } else {
//         relatorio[mesAno]![local]!['naoPago'] =
//             (relatorio[mesAno]![local]!['naoPago'] ?? 0.0) + plantao.valor;
//       }
//     }

//     // Ordenar por mês/ano decrescente
//     final sortedKeys = relatorio.keys.toList()..sort((a, b) => b.compareTo(a));
//     final Map<String, Map<String, Map<String, double>>> relatorioOrdenado = {
//       for (var k in sortedKeys) k: relatorio[k]!,
//     };

//     return relatorioOrdenado;
//   }
// }
