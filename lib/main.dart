import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meus_plantoes_app/models/local_trabalho.dart';
import 'package:meus_plantoes_app/models/plantao.dart';
import 'package:meus_plantoes_app/providers/locais_provider.dart';
import 'package:meus_plantoes_app/providers/plantoes_provider.dart';
import 'package:meus_plantoes_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Para formatação de datas em pt_BR
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necessário para Hive e outras inicializações async

  // Inicializa o Hive
  await Hive.initFlutter(); // Para web, 'subDirectory' não é necessário aqui

  // Registra os Adapters (gerados pelo build_runner)
  Hive.registerAdapter(LocalTrabalhoAdapter());
  Hive.registerAdapter(PlantaoAdapter());

  // Abre as boxes (como tabelas no SQL)
  await Hive.openBox<LocalTrabalho>('locais_trabalho');
  await Hive.openBox<Plantao>('plantoes');

  // Inicializa a formatação de datas para pt_BR (ou seu local preferido)
  await initializeDateFormatting('pt_BR', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => LocaisProvider()),
        ChangeNotifierProvider(create: (ctx) => PlantoesProvider()),
      ],
      child: MaterialApp(
        title: 'Plantões da Carolzinha 001:)',
        theme: ThemeData(
          primarySwatch: Colors.teal, // Cor principal suave
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Você pode definir aqui um colorScheme para cores mais suaves
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
            primary: Colors.teal[700],
            secondary: Colors.amber[700],
            background: Colors.grey[100], // Fundo suave
            surface: Colors.white, // Cor de superfície para cards, dialogs
          ),
          useMaterial3: true, // Recomendado para novas apps
        ),

        //ADICIONE/VERIFIQUE ESTAS LINHAS:
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations
              .delegate, // Para widgets do Cupertino, se usar
        ],
        supportedLocales: [
          const Locale('pt', 'BR'), // Português do Brasil
          // const Locale('en', 'US'), // Inglês, se quiser suportar
          // Adicione outros locales que você quer suportar
        ],
        locale: const Locale('pt', 'BR'), // Define o locale padrão da aplicação
        // FIM DAS LINHAS A ADICIONAR/VERIFICAR
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
