import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_plantoes_app/models/local_trabalho.dart';
import 'package:meus_plantoes_app/models/plantao.dart';
import 'package:meus_plantoes_app/models/turno.dart';
import 'package:meus_plantoes_app/providers/locais_provider.dart';
import 'package:meus_plantoes_app/providers/plantoes_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart'; // Para isSameDay
// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroPlantaoScreen extends StatefulWidget {
  final Plantao? plantaoParaEditar;

  CadastroPlantaoScreen({this.plantaoParaEditar});

  @override
  _CadastroPlantaoScreenState createState() => _CadastroPlantaoScreenState();
}

class _CadastroPlantaoScreenState extends State<CadastroPlantaoScreen> {
  final _formKey = GlobalKey<FormState>();

  LocalTrabalho? _localSelecionado;
  double _valor = 0.0;
  DateTime? _dataPagamento;
  bool _pago = false;
  DateTime _dataHoraInicio = DateTime.now();
  DateTime _dataHoraFim = DateTime.now().add(Duration(hours: 12));
  String? _comentarios;

  List<bool> _turnoInicialSelecionado = [false, false, false];
  List<bool> _turnoFinalSelecionado = [false, false, false];
  Turno? _turnoInicial;
  Turno? _turnoFinal;

  final TextEditingController _dataInicioController = TextEditingController();
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _dataFimController = TextEditingController();
  final TextEditingController _horaFimController = TextEditingController();
  final TextEditingController _dataPagamentoController =
      TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  // final _dateMaskFormatter = MaskTextInputFormatter(mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  // final _timeMaskFormatter = MaskTextInputFormatter(mask: '##:##', filter: {"#": RegExp(r'[0-9]')});

  @override
  void initState() {
    super.initState();

    if (widget.plantaoParaEditar != null) {
      final p = widget.plantaoParaEditar!;
      _localSelecionado = Provider.of<LocaisProvider>(
        context,
        listen: false,
      ).getLocalById(p.localTrabalhoId);
      _valor = p.valor;
      _valorController.text = _valor.toStringAsFixed(2);
      _dataPagamento = p.dataPagamento;
      _pago = p.pago;
      _dataHoraInicio = p.dataHoraInicio;
      _dataHoraFim = p.dataHoraFim;
      _comentarios = p.comentarios;

      _turnoInicial = _getTurnoFromTime(
        TimeOfDay.fromDateTime(p.dataHoraInicio),
      );
      if (_turnoInicial != null) {
        _turnoInicialSelecionado = _turnoToListBool(_turnoInicial!);
      }
      _turnoFinal = _getTurnoFromTime(TimeOfDay.fromDateTime(p.dataHoraFim));
      if (_turnoFinal != null) {
        _turnoFinalSelecionado = _turnoToListBool(_turnoFinal!);
      }
    } else {
      _setDefaultDataPagamento();
      _valorController.text = "0.00";
    }
    _updateDateTimeControllers();
  }

  List<bool> _turnoToListBool(Turno turno) {
    List<bool> selection = [false, false, false];
    if (turno == Turno.manha) selection[0] = true;
    if (turno == Turno.tarde) selection[1] = true;
    if (turno == Turno.noite) selection[2] = true;
    return selection;
  }

  Turno? _listBoolToTurno(List<bool> selection) {
    if (selection[0]) return Turno.manha;
    if (selection[1]) return Turno.tarde;
    if (selection[2]) return Turno.noite;
    return null;
  }

  Turno? _getTurnoFromTime(TimeOfDay time) {
    if (time.hour >= 7 && time.hour < 13) return Turno.manha;
    if (time.hour >= 13 && time.hour < 19) return Turno.tarde;
    if (time.hour >= 19 || time.hour < 7) return Turno.noite;
    return null;
  }

  void _updateDateTimeControllers() {
    _dataInicioController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(_dataHoraInicio);
    _horaInicioController.text = DateFormat('HH:mm').format(_dataHoraInicio);
    _dataFimController.text = DateFormat('dd/MM/yyyy').format(_dataHoraFim);
    _horaFimController.text = DateFormat('HH:mm').format(_dataHoraFim);
    if (_dataPagamento != null) {
      _dataPagamentoController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(_dataPagamento!);
    } else {
      _dataPagamentoController.text = '';
    }
  }

  void _setDefaultDataPagamento() {
    final proximoMes = DateTime(
      _dataHoraInicio.year,
      _dataHoraInicio.month + 1,
      1,
    );
    _dataPagamento = DateTime(proximoMes.year, proximoMes.month + 1, 0);
    _updateDateTimeControllers();
  }

  void _applyTurnoHoraInicial(int index) {
    setState(() {
      for (int i = 0; i < _turnoInicialSelecionado.length; i++) {
        _turnoInicialSelecionado[i] = i == index;
      }
      _turnoInicial = _listBoolToTurno(_turnoInicialSelecionado);
      if (_turnoInicial == null) return;

      TimeOfDay novaHora;
      switch (_turnoInicial!) {
        case Turno.manha:
          novaHora = TimeOfDay(hour: 7, minute: 0);
          break;
        case Turno.tarde:
          novaHora = TimeOfDay(hour: 13, minute: 0);
          break;
        case Turno.noite:
          novaHora = TimeOfDay(hour: 19, minute: 0);
          break;
      }
      _dataHoraInicio = DateTime(
        _dataHoraInicio.year,
        _dataHoraInicio.month,
        _dataHoraInicio.day,
        novaHora.hour,
        novaHora.minute,
      );
      _updateDateTimeControllers();
      _setDefaultDataPagamento();
    });
  }

  void _applyTurnoHoraFinal(int index) {
    setState(() {
      for (int i = 0; i < _turnoFinalSelecionado.length; i++) {
        _turnoFinalSelecionado[i] = i == index;
      }
      _turnoFinal = _listBoolToTurno(_turnoFinalSelecionado);
      if (_turnoFinal == null) return;

      TimeOfDay novaHora;
      switch (_turnoFinal!) {
        case Turno.manha:
          novaHora = TimeOfDay(hour: 7, minute: 0);
          break;
        case Turno.tarde:
          novaHora = TimeOfDay(hour: 13, minute: 0);
          break;
        case Turno.noite:
          novaHora = TimeOfDay(hour: 19, minute: 0);
          break;
      }

      DateTime novaDataHoraFinalProvisoria = DateTime(
        _dataHoraFim.year,
        _dataHoraFim.month,
        _dataHoraFim.day,
        novaHora.hour,
        novaHora.minute,
      );

      if (novaDataHoraFinalProvisoria.isBefore(_dataHoraInicio) &&
          isSameDay(_dataHoraInicio, _dataHoraFim)) {
        novaDataHoraFinalProvisoria = novaDataHoraFinalProvisoria.add(
          Duration(days: 1),
        );
      }
      _dataHoraFim = novaDataHoraFinalProvisoria;
      _updateDateTimeControllers();
    });
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime currentDateTime,
    TextEditingController controller,
    Function(DateTime) onDateSelected,
  ) async {
    FocusScope.of(context).unfocus();
    DateTime initialPickerDate;
    try {
      initialPickerDate = DateFormat('dd/MM/yyyy').parseStrict(controller.text);
    } catch (e) {
      initialPickerDate =
          currentDateTime; // Fallback to the state variable if parse fails
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialPickerDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: Locale('pt', 'BR'),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    DateTime currentDateTime,
    TextEditingController controller,
    Function(TimeOfDay) onTimeSelected,
  ) async {
    FocusScope.of(context).unfocus();
    TimeOfDay initialPickerTime;
    try {
      final parsedTime = DateFormat('HH:mm').parseStrict(controller.text);
      initialPickerTime = TimeOfDay(
        hour: parsedTime.hour,
        minute: parsedTime.minute,
      );
    } catch (e) {
      initialPickerTime = TimeOfDay.fromDateTime(currentDateTime); // Fallback
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialPickerTime,
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('pt', 'BR'),
          child: child,
        );
      },
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  void _onDataInicioChanged(String value) {
    try {
      final newDate = DateFormat('dd/MM/yyyy').parseStrict(value);
      setState(() {
        _dataHoraInicio = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          _dataHoraInicio.hour,
          _dataHoraInicio.minute,
        );
        // _updateDateTimeControllers(); // Controller é atualizado pelo próprio TextFormField
        _setDefaultDataPagamento(); // Recalcula data de pagamento
      });
    } catch (e) {
      /* Silencioso durante a digitação */
    }
  }

  void _onHoraInicioChanged(String value) {
    try {
      final newTime = DateFormat('HH:mm').parseStrict(value);
      setState(() {
        _dataHoraInicio = DateTime(
          _dataHoraInicio.year,
          _dataHoraInicio.month,
          _dataHoraInicio.day,
          newTime.hour,
          newTime.minute,
        );
        // _updateDateTimeControllers(); // Controller é atualizado pelo próprio TextFormField
      });
    } catch (e) {
      /* Silencioso */
    }
  }

  void _onDataFimChanged(String value) {
    try {
      final newDate = DateFormat('dd/MM/yyyy').parseStrict(value);
      setState(() {
        _dataHoraFim = DateTime(
          newDate.year,
          newDate.month,
          newDate.day,
          _dataHoraFim.hour,
          _dataHoraFim.minute,
        );
        // _updateDateTimeControllers();
      });
    } catch (e) {
      /* Silencioso */
    }
  }

  void _onHoraFimChanged(String value) {
    try {
      final newTime = DateFormat('HH:mm').parseStrict(value);
      setState(() {
        _dataHoraFim = DateTime(
          _dataHoraFim.year,
          _dataHoraFim.month,
          _dataHoraFim.day,
          newTime.hour,
          newTime.minute,
        );
        // _updateDateTimeControllers();
      });
    } catch (e) {
      /* Silencioso */
    }
  }

  void _onDataPagamentoChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _dataPagamento = null; /* _updateDateTimeControllers(); */
      });
      return;
    }
    try {
      final newDate = DateFormat('dd/MM/yyyy').parseStrict(value);
      setState(() {
        _dataPagamento = newDate; /* _updateDateTimeControllers(); */
      });
    } catch (e) {
      /* Silencioso */
    }
  }

  void _submitForm() {
    // Antes de validar o formulário, sincroniza as variáveis DateTime com os controllers
    // Isso garante que a última entrada manual seja considerada.
    try {
      final parsedDate = DateFormat(
        'dd/MM/yyyy',
      ).parseStrict(_dataInicioController.text);
      final parsedTime = DateFormat(
        'HH:mm',
      ).parseStrict(_horaInicioController.text);
      _dataHoraInicio = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      /* Erro de parse será pego pelo validator */
    }

    try {
      final parsedDate = DateFormat(
        'dd/MM/yyyy',
      ).parseStrict(_dataFimController.text);
      final parsedTime = DateFormat(
        'HH:mm',
      ).parseStrict(_horaFimController.text);
      _dataHoraFim = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      /* Erro de parse será pego pelo validator */
    }

    if (_dataPagamentoController.text.isNotEmpty) {
      try {
        _dataPagamento = DateFormat(
          'dd/MM/yyyy',
        ).parseStrict(_dataPagamentoController.text);
      } catch (e) {
        _dataPagamento = null; /* Erro de parse será pego pelo validator */
      }
    } else {
      _dataPagamento = null;
    }

    if (_formKey.currentState!.validate()) {
      // _formKey.currentState!.save(); // onSaved não são mais usados para campos de data/hora e valor

      // Salvar valor manualmente pois o onSaved foi removido para o campo de valor
      // para permitir atualização em onChanged.
      final valorStr = _valorController.text.replaceAll(',', '.');
      if (double.tryParse(valorStr) != null) {
        _valor = double.parse(valorStr);
      } else {
        // Isso deve ser pego pelo validator, mas como uma segurança extra:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Valor monetário inválido.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // Salvar comentários
      // O TextFormField de comentários ainda usa onSaved, então _formKey.currentState!.save() o afetaria.
      // Para consistência, podemos remover o onSaved dele também e pegar o valor do controller.
      // Ou manter o save() e garantir que _comentarios seja atualizado.
      // Por simplicidade, vamos manter o save para o campo de comentários por enquanto.
      _formKey.currentState!.save();

      if (_localSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor, selecione um local de trabalho.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_dataHoraFim.isBefore(_dataHoraInicio)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'A data/hora final não pode ser anterior à data/hora inicial.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Provider.of<PlantoesProvider>(
        context,
        listen: false,
      ).adicionarOuEditarPlantao(
        id: widget.plantaoParaEditar?.id,
        localTrabalhoId: _localSelecionado!.id,
        valor: _valor,
        dataPagamento: _dataPagamento,
        pago: _pago,
        dataHoraInicio: _dataHoraInicio,
        dataHoraFim: _dataHoraFim,
        comentarios:
            _comentarios, // _comentarios é atualizado pelo onSaved do TextFormField
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, corrija os erros no formulário.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locaisProvider = Provider.of<LocaisProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plantaoParaEditar == null
              ? 'Cadastrar Plantão'
              : 'Editar Plantão',
        ),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _submitForm)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<LocalTrabalho>(
                value: _localSelecionado,
                items:
                    locaisProvider.locais.map((local) {
                      return DropdownMenuItem<LocalTrabalho>(
                        value: local,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: local.cor,
                              radius: 10,
                            ),
                            SizedBox(width: 8),
                            Text(local.nome),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (LocalTrabalho? newValue) {
                  setState(() {
                    _localSelecionado = newValue;
                  });
                },
                decoration: InputDecoration(labelText: 'Local de Trabalho'),
                validator:
                    (value) => value == null ? 'Selecione um local' : null,
              ),

              TextFormField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                  prefixText: "R\$ ",
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o valor';
                  final cleanValue = value.replaceAll(',', '.');
                  if (double.tryParse(cleanValue) == null)
                    return 'Valor inválido';
                  if (double.parse(cleanValue) < 0)
                    return 'Valor não pode ser negativo';
                  return null;
                },
                onChanged: (value) {
                  // Atualiza _valor em tempo real para consistência
                  final cleanValue = value.replaceAll(',', '.');
                  if (double.tryParse(cleanValue) != null) {
                    // Não precisa de setState aqui se _valor só é usado no submit
                    // _valor = double.parse(cleanValue);
                  }
                },
              ),
              SizedBox(height: 15),

              Text(
                "Turno Inicial",
                style: TextStyle(fontSize: 16, color: theme.hintColor),
              ),
              SizedBox(height: 8),
              ToggleButtons(
                isSelected: _turnoInicialSelecionado,
                onPressed: _applyTurnoHoraInicial,
                borderRadius: BorderRadius.circular(8.0),
                selectedBorderColor: theme.colorScheme.primary,
                selectedColor: Colors.white,
                fillColor: theme.colorScheme.primary,
                color: theme.colorScheme.primary,
                constraints: BoxConstraints(
                  minHeight: 40.0,
                  minWidth: (MediaQuery.of(context).size.width - 48) / 3,
                ),
                children:
                    Turno.values
                        .map((turno) => Text(nomeDoTurno(turno)))
                        .toList(),
              ),
              SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dataInicioController,
                      decoration: InputDecoration(
                        labelText: 'Data Início',
                        hintText: 'DD/MM/AAAA',
                      ),
                      keyboardType: TextInputType.datetime,
                      onTap:
                          () => _selectDate(
                            context,
                            _dataHoraInicio,
                            _dataInicioController,
                            (pickedDate) {
                              setState(() {
                                _dataHoraInicio = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  _dataHoraInicio.hour,
                                  _dataHoraInicio.minute,
                                );
                                _updateDateTimeControllers(); // Atualiza o controller
                                _setDefaultDataPagamento();
                              });
                            },
                          ),
                      onChanged:
                          _onDataInicioChanged, // Atualiza _dataHoraInicio
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Obrigatório';
                        try {
                          DateFormat('dd/MM/yyyy').parseStrict(value);
                          return null;
                        } catch (e) {
                          return 'DD/MM/AAAA';
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _horaInicioController,
                      decoration: InputDecoration(
                        labelText: 'Hora Início',
                        hintText: 'HH:MM',
                      ),
                      keyboardType: TextInputType.datetime,
                      onTap:
                          () => _selectTime(
                            context,
                            _dataHoraInicio,
                            _horaInicioController,
                            (pickedTime) {
                              setState(() {
                                _dataHoraInicio = DateTime(
                                  _dataHoraInicio.year,
                                  _dataHoraInicio.month,
                                  _dataHoraInicio.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                _updateDateTimeControllers(); // Atualiza o controller
                              });
                            },
                          ),
                      onChanged:
                          _onHoraInicioChanged, // Atualiza _dataHoraInicio
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Obrigatório';
                        try {
                          DateFormat('HH:mm').parseStrict(value);
                          return null;
                        } catch (e) {
                          return 'HH:MM';
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              Text(
                "Turno Final",
                style: TextStyle(fontSize: 16, color: theme.hintColor),
              ),
              SizedBox(height: 8),
              ToggleButtons(
                isSelected: _turnoFinalSelecionado,
                onPressed: _applyTurnoHoraFinal,
                borderRadius: BorderRadius.circular(8.0),
                selectedBorderColor: theme.colorScheme.primary,
                selectedColor: Colors.white,
                fillColor: theme.colorScheme.primary,
                color: theme.colorScheme.primary,
                constraints: BoxConstraints(
                  minHeight: 40.0,
                  minWidth: (MediaQuery.of(context).size.width - 48) / 3,
                ),
                children:
                    Turno.values
                        .map((turno) => Text(nomeDoTurno(turno)))
                        .toList(),
              ),
              SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dataFimController,
                      decoration: InputDecoration(
                        labelText: 'Data Fim',
                        hintText: 'DD/MM/AAAA',
                      ),
                      keyboardType: TextInputType.datetime,
                      onTap:
                          () => _selectDate(
                            context,
                            _dataHoraFim,
                            _dataFimController,
                            (pickedDate) {
                              setState(() {
                                _dataHoraFim = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  _dataHoraFim.hour,
                                  _dataHoraFim.minute,
                                );
                                _updateDateTimeControllers();
                              });
                            },
                          ),
                      onChanged: _onDataFimChanged,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Obrigatório';
                        try {
                          DateFormat('dd/MM/yyyy').parseStrict(value);
                          return null;
                        } catch (e) {
                          return 'DD/MM/AAAA';
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _horaFimController,
                      decoration: InputDecoration(
                        labelText: 'Hora Fim',
                        hintText: 'HH:MM',
                      ),
                      keyboardType: TextInputType.datetime,
                      onTap:
                          () => _selectTime(
                            context,
                            _dataHoraFim,
                            _horaFimController,
                            (pickedTime) {
                              setState(() {
                                _dataHoraFim = DateTime(
                                  _dataHoraFim.year,
                                  _dataHoraFim.month,
                                  _dataHoraFim.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                _updateDateTimeControllers();
                              });
                            },
                          ),
                      onChanged: _onHoraFimChanged,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Obrigatório';
                        try {
                          DateFormat('HH:mm').parseStrict(value);
                          return null;
                        } catch (e) {
                          return 'HH:MM';
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              TextFormField(
                controller: _dataPagamentoController,
                decoration: InputDecoration(
                  labelText: 'Data Pagamento (Opcional)',
                  hintText: 'DD/MM/AAAA',
                  suffixIcon:
                      _dataPagamento != null
                          ? IconButton(
                            // Corrigido aqui
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _dataPagamento = null;
                                _updateDateTimeControllers();
                              });
                            },
                          )
                          : null,
                ),
                keyboardType: TextInputType.datetime,
                onTap:
                    () => _selectDate(
                      context,
                      _dataPagamento ?? DateTime.now(),
                      _dataPagamentoController,
                      (pickedDate) {
                        setState(() {
                          _dataPagamento = pickedDate;
                          _updateDateTimeControllers();
                        });
                      },
                    ),
                onChanged: _onDataPagamentoChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a data do pagamento';
                  }
                  try {
                    DateFormat('dd/MM/yyyy').parseStrict(value);
                    return null;
                  } catch (e) {
                    return 'DD/MM/AAAA';
                  }
                },
              ),

              SwitchListTile(
                title: Text('Plantão Pago?'),
                value: _pago,
                onChanged: (bool newValue) {
                  setState(() {
                    _pago = newValue;
                  });
                },
                activeColor: theme.colorScheme.primary,
              ),

              TextFormField(
                initialValue:
                    _comentarios, // Mantido com initialValue e onSaved
                decoration: InputDecoration(
                  labelText: 'Comentários (Opcional)',
                ),
                maxLines: 3,
                onSaved: (value) => _comentarios = value,
              ),

              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Salvar Plantão'),
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dataInicioController.dispose();
    _horaInicioController.dispose();
    _dataFimController.dispose();
    _horaFimController.dispose();
    _dataPagamentoController.dispose();
    _valorController.dispose();
    super.dispose();
  }
}
