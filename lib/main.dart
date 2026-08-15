import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tabela_de_turno/dados.dart';
import 'package:tabela_de_turno/rotinas.dart';
import 'package:tabela_de_turno/tabela.dart';
import 'package:tabela_de_turno/temas.dart';
import 'package:tabela_de_turno/notification_service.dart';
import 'package:tabela_de_turno/screens/alarme_ringing_screen.dart';

// Semáforo global para priorizar a tela de alarme sobre a Splash Screen
bool isAlarmActive = false;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  
  // Inicializa o serviço de notificações/alarmes
  await notificationService.init();
  
  // Inicializa formatação de datas em português
  await initializeDateFormatting('pt_BR', null);

  // Verifica se o aplicativo foi iniciado através de um alarme (Cold Start)
  final NotificationAppLaunchDetails? launchDetails = 
      await notificationService.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  NotificationResponse? initialNotification;
  if (launchDetails?.didNotificationLaunchApp == true) {
    initialNotification = launchDetails?.notificationResponse;
  }

  // Anima mudanças de estado no App ex.: Tema escuro/claro
  runApp(AppRoot(initialNotification: initialNotification));
}

class AppRoot extends StatefulWidget {
  final NotificationResponse? initialNotification;
  const AppRoot({super.key, this.initialNotification});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  StreamSubscription<NotificationResponse>? _notificationSubscription;

  @override
  void initState() {
    super.initState();

    // Escuta novas notificações enquanto o app está aberto
    _notificationSubscription = NotificationService().onNotification.listen(_handleNotification);

    // Se o app foi aberto por um alarme, processa a navegação após a build inicial
    if (widget.initialNotification != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotification(widget.initialNotification!);
      });
    }
  }

  /// Auditoria de Etapa 1: Decodifica o JSON para abrir a tela de alarme.
  void _handleNotification(NotificationResponse response) {
    // Se for ação de botão, o service já tratou ou tratará
    if (response.actionId == 'stop_action' || response.actionId == 'snooze_action') return;

    String title = 'Alarme';
    String body = '';
    int id = response.id ?? 0;

    try {
      final data = jsonDecode(response.payload ?? '{}');
      title = data['title'] ?? 'Alarme';
      body = data['body'] ?? '';
      id = data['id'] ?? id;
    } catch (e) {
      debugPrint('Erro lendo payload no AppRoot: $e. Tentando ler como texto simples.');
      // Fallback para notificações antigas que ainda usavam texto simples
      if (response.payload != null && response.payload!.contains(": ")) {
        final parts = response.payload!.split(": ");
        title = parts[0];
        body = parts.length > 1 ? parts[1] : "";
      }
    }

    // Marca o semáforo para bloquear o cronômetro da Splash Screen
    isAlarmActive = true;

    // Salta direto para a tela de alarme sobre qualquer tela atual
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => AlarmeRingingScreen(
          title: title,
          description: body,
          notificationId: id,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Tabela de Turno',
          theme: ThemeData(
            brightness: AppController.instance.temaDark ? Brightness.dark : Brightness.light,
            primarySwatch: Colors.orange,
          ),
          home: const Home(),
        );
      },
    );
  }
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

    // Executa a inicialização de alarmes silenciosa e permissões se necessário.
    Future.delayed(const Duration(seconds: 1)).then((value) async {
      if (!mounted) return;
      
      // Carrega preferências primeiro para saber se já pedimos permissão
      String prefData = await leArquivo();
      bool jaPediu = false;
      if (prefData.isNotEmpty) {
        final dt = jsonDecode(prefData);
        jaPediu = (dt[0]["askedPermissions"] == true);
      }

      // Prepara o motor (silencioso)
      await NotificationService().init();

      // Pede permissões invasivas APENAS na primeira vez (ou se não pediu ainda)
      if (!jaPediu) {
        await NotificationService().requestSpecialPermissions();
        // Marca que já pedimos para não incomodar no próximo boot
        if (preferencias.isNotEmpty) {
          preferencias[0]["askedPermissions"] = true;
          await salvaArquivo();
        }
      }

      if (!mounted) return;
      
      // Inicializa variáveis globais com a data de hoje
      dataHoje = DateTime.now();
      anoHoje = dataHoje.year;
      mesHoje = dataHoje.month;
      diaHoje = dataHoje.day;
      
      // Sincroniza estado inicial da navegação
      dataAtual = DateTime(anoHoje, mesHoje, diaHoje);
      anoAtual = anoHoje;
      mesAtual = mesHoje;
      diaAtual = diaHoje;
      
      if (mesesAbrev.length >= mesAtual) {
        dropdownValue = mesesAbrev[mesAtual - 1];
      }
      
      // Carrega eventos e tarefas antes de abrir a tabela principal
      await atualizarCache();
      
      if (!mounted) return;

      // Auditoria de Etapa 3: Só abre a Tabela se não houver um alarme em andamento.
      // Isso impede que a grade de turnos "atropele" a tela de reconhecimento.
      if (!isAlarmActive) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Tabela())
        );
      } else {
        debugPrint("🚦 Navegação da Splash bloqueada: Alarme detectado como prioridade.");
      }
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
          estiloCard = (preferencias[0]["estiloCard"] != null) ? preferencias[0]["estiloCard"] : 0;
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
            Positioned(
              // Ajusta a posição para flutuar acima da barra de navegação do Android (SafeArea).
              bottom: MediaQuery.of(context).padding.bottom + 10,
              right: 20,
              child: const Text(
                "por Claudio Xavier",
                style: TextStyle(
                  color: Color(0xFF0D47A1),
                  fontWeight: FontWeight.bold,
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
