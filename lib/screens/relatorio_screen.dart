import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:meus_plantoes_app/providers/plantoes_provider.dart';
import 'package:provider/provider.dart';
import 'package:meus_plantoes_app/providers/locais_provider.dart';

class RelatorioScreen extends StatelessWidget {
  static const kEspacamentoPequeno = SizedBox(height: 8);
  static const kEspacamentoMinimo = SizedBox(height: 4);
  static final kCorRecebido = Colors.green[700]!;
  static final kCorNaoRecebido = Colors.orange[700]!;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final locaisProvider = Provider.of<LocaisProvider>(context, listen: false);

    return Scaffold(
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

          final meses = relatorioData.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: meses.length,
            itemBuilder: (ctx, index) {
              final mesAno = meses[index];
              final locaisMap = relatorioData[mesAno]!;

              double totalPago = 0;
              double totalNaoPago = 0;
              locaisMap.forEach((_, valores) {
                totalPago += valores['pago'] ?? 0.0;
                totalNaoPago += valores['naoPago'] ?? 0.0;
              });
              final totalMes = totalPago + totalNaoPago;

              String mesAnoFormatado;
              try {
                final parsedDate = DateFormat('yyyy-MM').parse(mesAno);
                mesAnoFormatado =
                    toBeginningOfSentenceCase(
                      DateFormat.yMMMM('pt_BR').format(parsedDate),
                    )!;
              } catch (e) {
                mesAnoFormatado = mesAno;
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
                          _buildRelatorioRow(
                            context,
                            'Total Recebido:',
                            currencyFormatter.format(totalPago),
                            kCorRecebido,
                          ),
                          kEspacamentoPequeno,
                          _buildRelatorioRow(
                            context,
                            'Total a Receber:',
                            currencyFormatter.format(totalNaoPago),
                            kCorNaoRecebido,
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

                          Text(
                            'Detalhamento por Local:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          kEspacamentoPequeno,

                          ...locaisMap.entries.map((entry) {
                            final localId = entry.key;
                            final valores = entry.value;
                            final pagoLocal = valores['pago'] ?? 0.0;
                            final naoPagoLocal = valores['naoPago'] ?? 0.0;
                            final totalLocal = pagoLocal + naoPagoLocal;

                            final nomeLocal =
                                locaisProvider.getLocalById(localId)?.nome ??
                                'Local $localId (desconhecido)';

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
                                      kEspacamentoMinimo,
                                      _buildRelatorioRow(
                                        context,
                                        'Recebido:',
                                        currencyFormatter.format(pagoLocal),
                                        kCorRecebido,
                                      ),
                                      kEspacamentoMinimo,
                                      _buildRelatorioRow(
                                        context,
                                        'A Receber:',
                                        currencyFormatter.format(naoPagoLocal),
                                        kCorNaoRecebido,
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
