import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

// Importe das páginas de interfaces, dados e regras de negócios.
import 'config.dart'; // Página de configurações
import 'vista_geral.dart'; // Interface visão anual geral
import 'dados.dart'; // Página de dados
import 'visao_anual.dart'; // Interface visão anual
import 'visao_diaria.dart'; // Interface visão diária
import 'visao_mensal.dart'; // Interface visão mensal
import 'visao_semanal.dart'; // Interface visão semanal
import 'screens/integrantes_screen.dart';
import 'screens/backup_screen.dart';
import 'screens/lista_eventos_screen.dart';
import 'screens/alarme_ringing_screen.dart';
import 'rotinas.dart';

/// [Tabela] é o widget principal que gerencia a navegação entre as diferentes
/// visões do calendário de turno (Diária, Semanal, Mensal, Anual e Geral).
class Tabela extends StatefulWidget {
  const Tabela({super.key});

  @override
  State<Tabela> createState() => _TabelaState();
}

class _TabelaState extends State<Tabela> {
  late PageController _pageController;
  StreamSubscription? _notificationSubscription;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: paginaInicial);
    
    // Inicializa visibilidade das barras conforme a página inicial definida.
    atualizaPagina(paginaInicial);
    
    // Verifica se o aplicativo foi iniciado a partir de uma notificação de alarme.
    _checkInitialNotification();

    // Escuta eventos de notificação/alarme enquanto o aplicativo estiver em execução.
    _notificationSubscription = NotificationService().onNotification.listen((response) {
      _handleNotification(response);
    });

    // Inicia o temporizador para atualização automática na troca de dia (meia-noite).
    _startMidnightTimer();
  }

  /// Gerencia a transição automática de datas quando o relógio atinge a meia-noite.
  void _startMidnightTimer() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    // Calcula o próximo instante de meia-noite.
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    
    // Define a duração até a meia-noite, adicionando 1 segundo de margem de segurança.
    final duration = nextMidnight.difference(now) + const Duration(seconds: 1);

    _midnightTimer = Timer(duration, () {
      if (mounted) {
        setState(() {
          // Atualiza as variáveis globais de referência temporal.
          dataHoje = DateTime.now();
          diaHoje = dataHoje.day;
          mesHoje = dataHoje.month;
          anoHoje = dataHoje.year;
          
          // Sincroniza as variáveis de controle global para garantir a reconstrução correta.
          dataAtual = DateTime(anoHoje, mesHoje, diaHoje);
          anoAtual = anoHoje;
          mesAtual = mesHoje;
          diaAtual = diaHoje;
          
          // Se o seletor de meses estiver visível, sincroniza o valor do dropdown.
          if (mesesAbrev.length >= mesAtual) {
            dropdownValue = mesesAbrev[mesAtual - 1];
          }
          
          // Se o usuário estiver na Visão Diária, força o foco para o novo dia atual.
          if (paginaAtual == 0) {
            dataAtual = DateTime(anoHoje, mesHoje, diaHoje);
          }
        });
        // Reagenda o temporizador para o dia seguinte.
        _startMidnightTimer();
      }
    });
  }

  /// Verifica se houve um lançamento de notificação pendente no início do app.
  Future<void> _checkInitialNotification() async {
    final launchDetails = await NotificationService().flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails?.notificationResponse;
      if (response != null) {
        // Aguarda a renderização inicial para garantir que o Navigator esteja disponível.
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _handleNotification(response);
        });
      }
    }
  }

  /// Encaminha o usuário para a tela de alarme ativo ao receber uma resposta de notificação.
  void _handleNotification(NotificationResponse response) {
    // Ações rápidas via botões de notificação são tratadas no serviço.
    if (response.actionId == 'stop_action') return;

    final parts = (response.payload ?? "Tarefa: Lembrete").split(": ");
    final title = parts[0];
    final desc = parts.length > 1 ? parts[1] : "";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlarmeRingingScreen(
          title: title,
          description: desc,
          notificationId: response.id ?? 0,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notificationSubscription?.cancel();
    _midnightTimer?.cancel();
    super.dispose();
  }

  /// Navega para a aba selecionada no BottomNavigationBar.
  void _onItemTapped(int index) {
    setState(() {
      paginaAtual = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Atualiza dimensões globais para cálculos de layout dinâmico.
    altura = MediaQuery.of(context).size.height;
    largura = MediaQuery.of(context).size.width;

    final List<Widget> paginasList = [
      const VisaoDiaria(),
      VisaoSemanal(grupo: grupoAtual),
      VisaoMensal(ano: anoAtual, mes: mesAtual, grupo: grupoAtual),
      VisaoAnual(ano: anoAtual, grupo: grupoAtual, isVisible: paginaAtual == 3),
      VistaGeral(ano: anoAtual, grupo: grupoAtual, isVisible: paginaAtual == 4)
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text((largura > 350) ? "Tabela de Turno" : "Tabela"),
            const Spacer(),
            // Exibe o controle de ano apenas em abas permitidas.
            Visibility(
              visible: controleAno,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: () => setState(() => anoAtual--),
                  ),
                  Text("$anoAtual"),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () => setState(() => anoAtual++),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade800, Colors.orangeAccent]
                      )
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            borderRadius: const BorderRadius.all(Radius.circular(40)),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                "assets/images/tabela-de-turno-azul.png",
                                width: 60,
                                height: 60,
                              ),
                            )
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Tabela de Turno",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    )
                  ),
                  ItemMenu(Icons.group, "Gerenciar Integrantes", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const IntegrantesScreen())
                    );
                  }),
                  ItemMenu(Icons.event_note, "Meus Lançamentos", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ListaEventosScreen())
                    ).then((_) => setState(() {}));
                  }),
                  ItemMenu(Icons.settings, "Configurações", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Configuracoes())
                    );
                  }),
                  ItemMenu(Icons.sync, "Backup e Sincronização", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BackupScreen())
                    );
                  }),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("v1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          ],
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          // Ajusta a grade conforme a orientação do dispositivo.
          divisoes = (orientation == Orientation.portrait) ? 5 : 7;
          tamanhoFonteData = (orientation == Orientation.portrait)
              ? tamanhoFonteDataP
              : tamanhoFonteDataL;
          orientacao = orientation;
          return corpoPagina(paginasList);
        }
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange.shade800,
        unselectedItemColor: Colors.grey,
        currentIndex: paginaAtual,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.view_headline), label: "Dia"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize_outlined), label: "Semana"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Mes"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_on), label: "Ano"),
          BottomNavigationBarItem(icon: Icon(Icons.view_list), label: "Geral"),
        ],
      ),
    );
  }

  /// Monta a estrutura da página incluindo seletores de grupos e meses.
  Widget corpoPagina(List<Widget> paginasList) {
    double tamBt = (controleMes) ? 75 / numeroDeGrupos : 100 / numeroDeGrupos;
    double margem = 0.005;
    double tamanhoDaFonte = tamanhoFonteDataP;
    Color corTexto = corTxVistaGeral;
    double tmbt = (largura * 0.72) / numeroDeGrupos - margem;

    return Column(
      children: [
        // Barra de seleção de Grupo (A, B, C, D, E) e Mês.
        Visibility(
          visible: (controleMes || botoesVisiveis),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: SizedBox(
              height: largura / divisoes - margem * largura * 2,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        btContainer("a", tamBt),
                        btContainer("b", tamBt),
                        Visibility(
                          visible: (numeroDeGrupos >= 3),
                          child: btContainer("c", tamBt)
                        ),
                        Visibility(
                          visible: (numeroDeGrupos >= 4),
                          child: btContainer("d", tamBt)
                        ),
                        Visibility(
                          visible: (numeroDeGrupos >= 5),
                          child: btContainer("e", tamBt)
                        ),
                        Visibility(
                          visible: (numeroDeGrupos == 6),
                          child: btContainer("f", tamBt)
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: controleMes,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: largura * margem),
                      width: largura * 0.25,
                      alignment: Alignment.center,
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 20,
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 19),
                        underline: Container(height: 2, color: Colors.blueAccent),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              dropdownValue = newValue;
                              mesAtual = mesesAbrev.indexOf(newValue) + 1;
                            });
                          }
                        },
                        items: mesesAbrev.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        // Cabeçalho da Vista Geral (Listagem).
        Visibility(
          visible: visaoGeral,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: (isTemaDark)
                    ? [Colors.black54, Colors.white10]
                    : [Colors.indigo.shade900, Colors.blue.shade300]
              )
            ),
            height: altura * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: largura * 0.15,
                  child: Text("Dia", style: TextStyle(fontSize: tamanhoDaFonte, color: corTexto)),
                ),
                Container(
                  alignment: Alignment.center,
                  width: largura * 0.13,
                  child: Text("DS", style: TextStyle(fontSize: tamanhoDaFonte, color: corTexto)),
                ),
                for (int i = 0; i < numeroDeGrupos; i++)
                  InkWell(
                    onTap: () => mostrarPopupIntegrantes(context, grupos[i]),
                    child: SizedBox(
                      width: tmbt,
                      child: Text(grupos[i], style: TextStyle(fontSize: tamanhoDaFonte, color: corTexto), textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Visualização da aba ativa.
        Expanded(
          child: PageView(
            controller: _pageController,
            children: paginasList,
            onPageChanged: (pagina) {
              setState(() {
                paginaAtual = pagina;
                atualizaPagina(paginaAtual);
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight
                ]);
              });
            },
          ),
        ),
      ],
    );
  }

  /// Constrói o botão de seleção de grupo.
  Widget btContainer(String letra, double perc) {
    String letraMaisucula = letra.toUpperCase();
    return Container(
      width: (perc != 0) ? largura * perc / 100 - mrgn : null,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: (grupoAtual == grupo[letra]) ? corBrdBtTurnoC : corBrdBtTurnoE,
          width: 3
        ),
      ),
      child: TextButton(
        child: Text(
          letraMaisucula,
          style: TextStyle(
            fontSize: 18,
            color: (grupoAtual == grupo[letra]) ? corTxBtTurnoC : corTxBtTurnoE
          ),
        ),
        onPressed: () {
          setState(() {
            grupoAtual = grupo[letra]!;
          });
        },
      )
    );
  }
}

/// Componente customizado para os itens do Drawer lateral.
class ItemMenu extends StatefulWidget {
  final IconData icone;
  final String texto;
  final Function onTap;
  const ItemMenu(this.icone, this.texto, this.onTap, {super.key});
  @override
  State<ItemMenu> createState() => _ItemMenuState();
}

class _ItemMenuState extends State<ItemMenu> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400))
        ),
        child: InkWell(
          splashColor: Colors.orangeAccent.shade400,
          onTap: widget.onTap as void Function()?,
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.icone, size: 25),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.texto, style: const TextStyle(fontSize: 16)),
                    )
                  ],
                ),
                const Icon(Icons.arrow_right)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gerencia a visibilidade de controles globais dependendo da aba ativa.
void atualizaPagina(int pagina) {
  switch (pagina) {
    case 0: // Diária
      botoesVisiveis = false;
      controleAno = false;
      controleMes = false;
      visaoGeral = false;
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      break;
    case 1: // Semanal
      botoesVisiveis = true;
      controleAno = false;
      controleMes = false;
      visaoGeral = false;
      break;
    case 2: // Mensal
      botoesVisiveis = false;
      controleAno = true;
      controleMes = true;
      visaoGeral = false;
      break;
    case 4: // Geral
      botoesVisiveis = false;
      controleAno = true;
      controleMes = false;
      visaoGeral = true;
      break;
    default: // Anual (Case 3)
      botoesVisiveis = true;
      controleAno = true;
      controleMes = false;
      visaoGeral = false;
      break;
  }
}
