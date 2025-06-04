import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_plantoes_app/providers/plantoes_provider.dart';
import 'package:provider/provider.dart';
import 'package:meus_plantoes_app/providers/locais_provider.dart';

class RelatorioScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Scaffold(
      // AppBar é gerenciado pelo HomeScreen
      body: Consumer<PlantoesProvider>(
        builder: (ctx, plantoesProvider, _) {
          final relatorioData = plantoesProvider.getRelatorioMensalPorLocal();

          if (relatorioData.isEmpty) {
            return Center(
              child: Text(
                'Nenhum plantão cadastrado para gerar relatório.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Meses já vêm ordenados do provider (AAAA-MM)
          final meses = relatorioData.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: meses.length,
            itemBuilder: (ctx, index) {
              final mesAno = meses[index];
              final locaisMap = relatorioData[mesAno]!;
              final locaisProvider = Provider.of<LocaisProvider>(
                context,
                listen: false,
              );

              // Somar totais do mês
              double totalPago = 0;
              double totalNaoPago = 0;
              locaisMap.forEach((local, valores) {
                totalPago += valores['pago'] ?? 0.0;
                totalNaoPago += valores['naoPago'] ?? 0.0;
              });
              final totalMes = totalPago + totalNaoPago;

              // Formatar "AAAA-MM" para "Mês de Ano"
              String mesAnoFormatado;
              try {
                final parsedDate = DateFormat('yyyy-MM').parse(mesAno);
                mesAnoFormatado = DateFormat.yMMMM('pt_BR').format(parsedDate);
              } catch (e) {
                mesAnoFormatado = mesAno; // fallback
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                child: ExpansionTile(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  collapsedBackgroundColor: Theme.of(context).cardColor,
                  leading: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    mesAnoFormatado,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  subtitle: Text(
                    'Total no Mês: ${currencyFormatter.format(totalMes)}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Totais gerais do mês
                          _buildRelatorioRow(
                            context,
                            'Total Recebido:',
                            currencyFormatter.format(totalPago),
                            Colors.green[700]!,
                          ),
                          SizedBox(height: 8),
                          _buildRelatorioRow(
                            context,
                            'Total a Receber:',
                            currencyFormatter.format(totalNaoPago),
                            Colors.orange[700]!,
                          ),
                          Divider(height: 20, thickness: 1),
                          _buildRelatorioRow(
                            context,
                            'Saldo do Mês:',
                            currencyFormatter.format(totalMes),
                            Theme.of(context).colorScheme.primary,
                            isBold: true,
                          ),
                          SizedBox(height: 16),

                          // Agora lista por local
                          Text(
                            'Detalhamento por Local:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 8),

                          ...locaisMap.entries.map((entry) {
                            final local = entry.key;
                            final valores = entry.value;
                            final pagoLocal = valores['pago'] ?? 0.0;
                            final naoPagoLocal = valores['naoPago'] ?? 0.0;
                            final totalLocal = pagoLocal + naoPagoLocal;
                            final nomeLocal =
                                locaisProvider.getLocalById(local)?.nome ??
                                'Local desconhecido';

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Card(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant.withOpacity(0.2),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nomeLocal,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      _buildRelatorioRow(
                                        context,
                                        'Recebido:',
                                        currencyFormatter.format(pagoLocal),
                                        Colors.green[700]!,
                                      ),
                                      SizedBox(height: 4),
                                      _buildRelatorioRow(
                                        context,
                                        'A Receber:',
                                        currencyFormatter.format(naoPagoLocal),
                                        Colors.orange[700]!,
                                      ),
                                      Divider(height: 14, thickness: 1),
                                      _buildRelatorioRow(
                                        context,
                                        'Total Local:',
                                        currencyFormatter.format(totalLocal),
                                        Theme.of(context).colorScheme.primary,
                                        isBold: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRelatorioRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:meus_plantoes_app/providers/plantoes_provider.dart';
// import 'package:provider/provider.dart';

// class RelatorioScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final currencyFormatter = NumberFormat.currency(
//       locale: 'pt_BR',
//       symbol: 'R\$',
//     );

//     return Scaffold(
//       // AppBar é gerenciado pelo HomeScreen
//       body: Consumer<PlantoesProvider>(
//         builder: (ctx, plantoesProvider, _) {
//           final relatorioData = plantoesProvider.getRelatorioMensal();

//           if (relatorioData.isEmpty) {
//             return Center(
//               child: Text(
//                 'Nenhum plantão cadastrado para gerar relatório.',
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//             );
//           }

//           // Chaves já vêm ordenadas do provider (AAAA-MM)
//           final meses = relatorioData.keys.toList();

//           return ListView.builder(
//             padding: const EdgeInsets.all(8.0),
//             itemCount: meses.length,
//             itemBuilder: (ctx, index) {
//               final mesAno = meses[index];
//               final dadosMes = relatorioData[mesAno]!;
//               final totalPago = dadosMes['pago'] ?? 0.0;
//               final totalNaoPago = dadosMes['naoPago'] ?? 0.0;
//               final totalMes = totalPago + totalNaoPago;

//               // Formatar "AAAA-MM" para "Mês de Ano"
//               String mesAnoFormatado;
//               try {
//                 final parsedDate = DateFormat('yyyy-MM').parse(mesAno);
//                 mesAnoFormatado = DateFormat.yMMMM(
//                   'pt_BR',
//                 ).format(parsedDate); // Ex: "junho de 2025"
//               } catch (e) {
//                 mesAnoFormatado = mesAno; // Fallback
//               }

//               return Card(
//                 elevation: 3,
//                 margin: const EdgeInsets.symmetric(
//                   vertical: 8.0,
//                   horizontal: 4.0,
//                 ),
//                 child: ExpansionTile(
//                   backgroundColor: Theme.of(
//                     context,
//                   ).colorScheme.surfaceVariant.withOpacity(0.3),
//                   collapsedBackgroundColor: Theme.of(context).cardColor,
//                   leading: Icon(
//                     Icons.calendar_month,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   title: Text(
//                     mesAnoFormatado,
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
//                   ),
//                   subtitle: Text(
//                     'Total no Mês: ${currencyFormatter.format(totalMes)}',
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Theme.of(context).colorScheme.primary,
//                     ),
//                   ),
//                   children: <Widget>[
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildRelatorioRow(
//                             context,
//                             'Total Recebido:',
//                             currencyFormatter.format(totalPago),
//                             Colors.green[700]!,
//                           ),
//                           SizedBox(height: 8),
//                           _buildRelatorioRow(
//                             context,
//                             'Total a Receber:',
//                             currencyFormatter.format(totalNaoPago),
//                             Colors.orange[700]!,
//                           ),
//                           Divider(height: 20, thickness: 1),
//                           _buildRelatorioRow(
//                             context,
//                             'Saldo do Mês:',
//                             currencyFormatter.format(totalMes),
//                             Theme.of(context).colorScheme.primary,
//                             isBold: true,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildRelatorioRow(
//     BuildContext context,
//     String label,
//     String value,
//     Color valueColor, {
//     bool isBold = false,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             color: valueColor,
//           ),
//         ),
//       ],
//     );
//   }
// }
