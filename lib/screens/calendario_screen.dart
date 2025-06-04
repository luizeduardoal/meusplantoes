import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_plantoes_app/models/plantao.dart';
import 'package:meus_plantoes_app/providers/locais_provider.dart';
import 'package:meus_plantoes_app/providers/plantoes_provider.dart';
import 'package:meus_plantoes_app/screens/cadastro_plantao_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarioScreen extends StatefulWidget {
  @override
  _CalendarioScreenState createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      // isSameDay do table_calendar
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  List<Plantao> _getEventsForDay(BuildContext context, DateTime day) {
    final plantoesProvider = Provider.of<PlantoesProvider>(
      context,
      listen: false,
    );
    return plantoesProvider.getPlantoesPorDia(day);
  }

  Future<void> _confirmarExclusaoPlantao(
    BuildContext context,
    Plantao plantao,
    PlantoesProvider provider,
  ) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder:
              (BuildContext ctx) => AlertDialog(
                title: const Text('Confirmar Exclusão'),
                content: Text(
                  'Deseja realmente excluir este plantão? (${Provider.of<LocaisProvider>(context, listen: false).getLocalById(plantao.localTrabalhoId)?.nome ?? "Local desc."} - ${DateFormat.Hm('pt_BR').format(plantao.dataHoraInicio)})',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirm) {
      try {
        await provider.removerPlantao(plantao.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Plantão removido com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falha ao remover plantão: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locaisProvider = Provider.of<LocaisProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Column(
      children: [
        Consumer<PlantoesProvider>(
          builder:
              (ctx, plantoesData, child) => TableCalendar<Plantao>(
                locale: 'pt_BR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: (day) => _getEventsForDay(context, day),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      final local = locaisProvider.getLocalById(
                        events.first.localTrabalhoId,
                      );
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                local?.cor.withOpacity(0.8) ??
                                Colors.blueGrey.withOpacity(0.8),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Center(
                            child: Text(
                              '${events.length}',
                              style: TextStyle().copyWith(
                                color: Colors.white,
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  defaultBuilder: (context, date, _) {
                    final today = DateTime.now();
                    final isPast = date.isBefore(
                      DateTime(today.year, today.month, today.day),
                    );

                    if (isPast) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    return null; // Usa o estilo padrão para os outros dias
                  },
                ),
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  formatButtonTextStyle: TextStyle(color: Colors.white),
                ),
              ),
        ),
        const SizedBox(height: 8.0),
        Consumer<PlantoesProvider>(
          builder: (ctx, plantoesProvider, _) {
            final selectedDayPlantoes =
                _selectedDay != null
                    ? plantoesProvider.getPlantoesPorDia(_selectedDay!)
                    : <Plantao>[];

            if (selectedDayPlantoes.isEmpty) {
              return Expanded(
                child: Center(
                  child: Text(
                    'Nenhum plantão para este dia.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }
            return Expanded(
              child: ListView.builder(
                itemCount: selectedDayPlantoes.length,
                itemBuilder: (context, index) {
                  final plantao = selectedDayPlantoes[index];
                  final local = locaisProvider.getLocalById(
                    plantao.localTrabalhoId,
                  );
                  final dataPagamento = DateFormat(
                    'dd-MM-yyyy',
                  ).format(plantao.dataPagamento!);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    color:
                        plantao.pago
                            ? Colors.green.withOpacity(
                              0.1,
                            ) // Cor para plantão pago
                            : null, // Usa a cor padrão se não pago
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: local?.cor ?? Colors.grey,
                        child: Icon(
                          Icons.medical_services_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        '${local?.nome ?? "Local Desc."} - ${DateFormat.Hm('pt_BR').format(plantao.dataHoraInicio)} às ${DateFormat.Hm('pt_BR').format(plantao.dataHoraFim)}',
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(
                            context,
                          ).style.copyWith(fontSize: 15),
                          children: [
                            const TextSpan(text: 'Valor: '),
                            TextSpan(
                              text: 'R\$ ${plantao.valor.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' | pagamento em: '),
                            TextSpan(
                              text: dataPagamento,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // subtitle: Text(
                      //   'Valor: R\$ ${plantao.valor.toStringAsFixed(2)}     à pagar no dia $dataPagamento',
                      // ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mudança para Switch
                          Transform.scale(
                            // Para diminuir um pouco o tamanho do Switch se necessário
                            scale: 0.8,
                            child: Switch(
                              value: plantao.pago,
                              onChanged: (bool newValue) {
                                plantoesProvider.atualizarStatusPagamento(
                                  plantao.id,
                                  newValue,
                                );
                              },
                              activeColor: theme.colorScheme.primary,
                              // inactiveThumbColor: Colors.grey, // Opcional
                              // inactiveTrackColor: Colors.grey.withOpacity(0.5), // Opcional
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                            ),
                            onPressed:
                                () => _confirmarExclusaoPlantao(
                                  context,
                                  plantao,
                                  plantoesProvider,
                                ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => CadastroPlantaoScreen(
                                  plantaoParaEditar: plantao,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
