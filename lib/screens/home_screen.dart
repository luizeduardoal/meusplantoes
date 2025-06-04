import 'package:flutter/material.dart';
import 'package:meus_plantoes_app/screens/calendario_screen.dart';
import 'package:meus_plantoes_app/screens/cadastro_plantao_screen.dart';
import 'package:meus_plantoes_app/screens/locais_trabalho_screen.dart';
import 'package:meus_plantoes_app/screens/add_edit_local_trabalho_screen.dart';
import 'package:meus_plantoes_app/screens/relatorio_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    CalendarioScreen(),
    LocaisTrabalhoScreen(),
    RelatorioScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(_selectedIndex)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      floatingActionButton:
          _shouldShowFab(_selectedIndex)
              ? FloatingActionButton(
                onPressed: () {
                  if (_selectedIndex == 0) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CadastroPlantaoScreen(),
                      ),
                    );
                  } else if (_selectedIndex == 1) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddEditLocalTrabalhoScreen(),
                      ),
                    );
                  }
                },
                tooltip: _getFabTooltip(_selectedIndex),
                child: Icon(Icons.add),
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                elevation: 2.0, // Pequena elevação
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Envolver BottomNavigationBar com BottomAppBar para o notch
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(), // Cria o entalhe para o FAB
        notchMargin: 6.0, // Espaçamento entre o FAB e o BottomAppBar
        color:
            theme.bottomAppBarTheme.color ??
            theme.colorScheme.surface, // Cor do BottomAppBar
        elevation: theme.bottomAppBarTheme.elevation ?? 8.0,
        child: Container(
          // Container para definir altura se necessário
          height: 60.0, // Altura padrão ou ajuste conforme necessário
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Itens da esquerda
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      _onItemTapped(0);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          size: 32.0,
                          color:
                              _selectedIndex == 0
                                  ? theme.colorScheme.primary
                                  : Colors.grey[600],
                        ),
                        Text(
                          'Calendário',
                          style: TextStyle(
                            color:
                                _selectedIndex == 0
                                    ? theme.colorScheme.primary
                                    : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      _onItemTapped(1);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.business_outlined,
                          size: 32.0,
                          color:
                              _selectedIndex == 1
                                  ? theme.colorScheme.primary
                                  : Colors.grey[600],
                        ),
                        Text(
                          'Locais',
                          style: TextStyle(
                            color:
                                _selectedIndex == 1
                                    ? theme.colorScheme.primary
                                    : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Espaço para o FAB (se centralizado) - os itens da direita virão depois
              // Itens da direita
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      _onItemTapped(2);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.assessment_outlined,
                          size: 32.0,
                          color:
                              _selectedIndex == 2
                                  ? theme.colorScheme.primary
                                  : Colors.grey[600],
                        ),
                        Text(
                          'Relatório',
                          style: TextStyle(
                            color:
                                _selectedIndex == 2
                                    ? theme.colorScheme.primary
                                    : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Adicione um SizedBox ou outro MaterialButton se tiver mais um item à direita do FAB
                  // Exemplo: Se tivesse 4 itens, 2 à esquerda e 2 à direita do FAB.
                  // SizedBox(width: 40) // Placeholder para alinhar se necessário
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowFab(int index) {
    return index == 0 || index == 1;
  }

  String _getFabTooltip(int index) {
    if (index == 0) return 'Adicionar Plantão';
    if (index == 1) return 'Adicionar Local';
    return '';
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Calendário';
      case 1:
        return 'Locais de Trabalho';
      case 2:
        return 'Relatório Mensal';
      default:
        return 'Meus Plantões';
    }
  }
}
