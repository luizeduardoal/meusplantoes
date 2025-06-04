import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:meus_plantoes_app/models/local_trabalho.dart';
import 'package:meus_plantoes_app/providers/locais_provider.dart';
import 'package:provider/provider.dart';

class AddEditLocalTrabalhoScreen extends StatefulWidget {
  final LocalTrabalho? localTrabalho; // Para edição

  AddEditLocalTrabalhoScreen({this.localTrabalho});

  @override
  _AddEditLocalTrabalhoScreenState createState() =>
      _AddEditLocalTrabalhoScreenState();
}

class _AddEditLocalTrabalhoScreenState
    extends State<AddEditLocalTrabalhoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  Color _corSelecionada = Colors.blue; // Cor padrão

  @override
  void initState() {
    super.initState();
    if (widget.localTrabalho != null) {
      _nome = widget.localTrabalho!.nome;
      _corSelecionada = widget.localTrabalho!.cor;
    }
  }

  void _salvarFormulario() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Provider.of<LocaisProvider>(
        context,
        listen: false,
      ).adicionarOuEditarLocal(
        widget.localTrabalho?.id, // Passa ID se estiver editando
        _nome,
        _corSelecionada,
      );
      Navigator.of(context).pop();
    }
  }

  void _escolherCor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escolha uma cor'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _corSelecionada,
              onColorChanged: (Color color) {
                setState(() => _corSelecionada = color);
              },
              // showLabel: true, // Descomente para mostrar labels RGB/HSV
              // pickerAreaHeightPercent: 0.8, // Ajuste a área
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.localTrabalho == null ? 'Adicionar Local' : 'Editar Local',
        ),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _salvarFormulario),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // Usar ListView para evitar overflow com teclado
            children: <Widget>[
              TextFormField(
                initialValue: _nome,
                decoration: InputDecoration(labelText: 'Nome do Local'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nome = value!;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Cor de Destaque:'),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: _escolherCor,
                    child: CircleAvatar(
                      backgroundColor: _corSelecionada,
                      radius: 20,
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: _escolherCor,
                    child: Text('Selecionar Cor'),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Salvar Local'),
                onPressed: _salvarFormulario,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
