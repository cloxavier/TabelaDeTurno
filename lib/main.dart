import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabela_de_turno/dados.dart';
import 'package:tabela_de_turno/rotinas.dart';
import 'package:tabela_de_turno/tabela.dart';
import 'package:tabela_de_turno/temas.dart';
import 'package:tabela_de_turno/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  
  // Inicializa o serviço de notificações/alarmes
  await NotificationService().init();
  
  // Inicializa formatação de datas em português
  await initializeDateFormatting('pt_BR', null);

  // Anima mudanças de estado no App ex.: Tema escuro/claro
  runApp(AnimatedBuilder(
    animation: AppController.instance,
    builder: (context, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tabela de Turno',
        theme: ThemeData(
          brightness: AppController.instance.temaDark ? Brightness.dark : Brightness.light,
          primarySwatch: Colors.orange,
        ),
        home: const Home(),
      );
    },
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    Future.delayed(const Duration(seconds: 3)).then((value) {
      if (!mounted) return;
      
      // Inicializa variáveis globais com a data de hoje
      dataHoje = DateTime.now();
      anoAtual = dataHoje.year;
      mesAtual = dataHoje.month;
      diaAtual = dataHoje.day;
      dataAtual = DateTime(anoAtual, mesAtual, diaAtual);
      dropdownValue = mesesAbrev[mesAtual - 1]; // Sincroniza o seletor de meses
      
      atualizarCache().then((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Tabela())
        );
      });
    });

    // Lê e define as preferências salvas
    leArquivo().then((value) {
      if (value != "") {
        final dt = jsonDecode(value);
        preferencias = dt;
        setState(() {
          grupoAtual = (preferencias[0]["turnoFavorito"] != null) ? preferencias[0]["turnoFavorito"] : grupo["a"];
          barraVisivel = (preferencias[0]["interface"] != null) ? preferencias[0]["interface"] : true;
          isTemaDark = (preferencias[0]["temaEscuro"] != null) ? preferencias[0]["temaEscuro"] : isTemaDark;
          flat = (preferencias[0]["botaoFlat"] != null) ? preferencias[0]["botaoFlat"] : flat;
          paginaInicial = (preferencias[0]["pgInicial"] != null) ? preferencias[0]["pgInicial"] : 0;
          nomeUsuario = (preferencias[0]["nomeUsuario"] != null) ? preferencias[0]["nomeUsuario"] : "";
          paginaAtual = paginaInicial;
          AppController.instance.changeTheme(escuro: isTemaDark);
        });
      }
    }).catchError((e) {
      // Erro ao ler arquivo
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade100,
              Colors.orange.shade500,
              Colors.orange.shade100,
            ]
          )
        ),
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                "assets/images/tabela-de-turno-azul_tranparente.png",
                width: 200,
                height: 200,
              ),
            ),
            const Positioned(
              bottom: 20,
              right: 20,
              child: Text(
                "por Claudio Xavier",
                style: TextStyle(color: Color(0xFF0D47A1)),
              )
            )
          ],
        ),
      ),
    );
  }
}
