import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:io';
import 'notification_service.dart';
import 'local_storage_service.dart';

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
import 'screens/ajuda_screen.dart';
import 'rotinas.dart';
import 'temas.dart';

/// [Tabela] é o widget principal que gerencia a navegação entre as diferentes
/// visões do calendário de turno (Diária, Semanal, Mensal, Anual e Geral).
class Tabela extends StatefulWidget {
  const Tabela({super.key});

  @override
  State<Tabela> createState() => _TabelaState();
}

class _TabelaState extends State<Tabela> with WidgetsBindingObserver {
  late PageController _pageController;
  StreamSubscription? _intentSub;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: paginaInicial);
    
    // Registra o observador para detectar o retorno do app do background
    WidgetsBinding.instance.addObserver(this);
    
    // Escuta por compartilhamento de arquivos JSON enquanto o app está aberto.
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _handleSharedFile(value.first.path);
      }
    }, onError: (err) {
      debugPrint("Erro no stream de compartilhamento: $err");
    });

    // Verifica compartilhamento em 'Cold Start' (App estava fechado).
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        // Pequeno atraso para garantir que a interface da Tabela esteja estável.
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleSharedFile(value.first.path);
        });
      }
      ReceiveSharingIntent.instance.reset();
    });

    // Inicializa visibilidade das barras conforme a página inicial definida.
    atualizaPagina(paginaInicial);
    
    // Inicia o temporizador para atualização automática na troca de dia (meia-noite).
    _startMidnightTimer();

    // Auditoria de Permissões: Verifica se o alarme tem autoridade para aparecer sobre o bloqueio.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAlarmPermissions());
  }

  /// Verifica se as permissões vitais para o alarme sobre o bloqueio estão ativas.
  /// Só exibe o aviso se realmente houver algo pendente que impeça o alarme de funcionar.
  Future<void> _checkAlarmPermissions() async {
    if (Platform.isAndroid) {
      // Pequeno atraso para dar tempo ao sistema operacional de processar as permissões da Splash Screen
      await Future.delayed(const Duration(milliseconds: 500));
      
      bool hasOverlay = await NotificationService().hasFullScreenPermission();
      bool hasBatteryIgnored = await NotificationService().isBatteryOptimizationIgnored();

      if (!hasOverlay || !hasBatteryIgnored) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.grey.shade900,
            content: const Text("Aviso: O alarme pode falhar sobre o bloqueio sem permissão de sobreposição."),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: "CONFIGURAR",
              textColor: Colors.orange,
              onPressed: () => NotificationService().requestSpecialPermissions(),
            ),
          ),
        );
      }
    }
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

  @override
  void dispose() {
    _pageController.dispose();
    _intentSub?.cancel();
    _midnightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Quando o app volta do background (resumed), o 'main.dart' já resetou o grupoAtual.
    // Disparamos o setState aqui para que a Tabela reflita essa mudança visualmente.
    if (state == AppLifecycleState.resumed) {
      setState(() {
        debugPrint("✨ Tabela atualizada: Voltando para o grupo favorito.");
      });
    }
  }

  /// Processa o arquivo JSON compartilhado vindo do WhatsApp ou Gestor de Arquivos.
  Future<void> _handleSharedFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (mounted) {
          await LocalStorageService().handleExternalJson(context, content);
        }
      }
    } catch (e) {
      debugPrint("Erro ao ler arquivo compartilhado: $e");
    }
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

    return AnimatedBuilder(
      animation: AppController.instance,
      builder: (context, child) {
        final List<Widget> paginasList = [
          const VisaoDiaria(),
          VisaoSemanal(key: ValueKey("S_${AppController.instance.cardStyle}_$isTemaDark"), grupo: grupoAtual),
          VisaoMensal(key: ValueKey("M_${AppController.instance.cardStyle}_$isTemaDark"), ano: anoAtual, mes: mesAtual, grupo: grupoAtual),
          VisaoAnual(key: ValueKey("A_${AppController.instance.cardStyle}_$isTemaDark"), ano: anoAtual, grupo: grupoAtual, isVisible: paginaAtual == 3),
          VistaGeral(key: ValueKey("G_${AppController.instance.cardStyle}_$isTemaDark"), ano: anoAtual, grupo: grupoAtual, isVisible: paginaAtual == 4)
        ];

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    (largura > 350) ? "Tabela de Turno" : "Tabela",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                // Exibe o controle de ano apenas em abas permitidas.
                Visibility(
                  visible: controleAno,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      ItemMenu(Icons.help_outline, "Central de Ajuda", () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AjudaScreen())
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
            backgroundColor: isTemaDark ? const Color(0xFF1E1E1E) : Colors.white,
            selectedItemColor: Colors.orange.shade800,
            unselectedItemColor: isTemaDark ? Colors.white60 : Colors.grey,
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
      },
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

  /// Constrói o botão de seleção de grupo com suporte a favorito e visualização temporária.
  Widget btContainer(String letra, double perc) {
    String letraMaisucula = letra.toUpperCase();
    int valorGrupo = grupo[letra]!;
    bool isFavorito = (preferencias[0]["turnoFavorito"] == valorGrupo);
    bool isSelecionado = (grupoAtual == valorGrupo);

    return InkWell(
      onTap: () {
        setState(() {
          grupoAtual = valorGrupo;
        });
      },
      onLongPress: () {
        setState(() {
          grupoAtual = valorGrupo;
          preferencias[0]["turnoFavorito"] = grupoAtual;
          salvaArquivo();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Grupo $letraMaisucula definido como favorito!"),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      },
      child: Container(
        width: (perc != 0) ? largura * perc / 100 - mrgn : null,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          // Destaque Triplo: Fundo colorido apenas para o favorito
          color: isFavorito ? (isTemaDark ? Colors.orange.withValues(alpha: 0.15) : Colors.orange.shade50) : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(
            color: isSelecionado ? corBrdBtTurnoC : corBrdBtTurnoE,
            width: 3
          ),
        ),
        child: Text(
          letraMaisucula,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: isSelecionado ? corTxBtTurnoC : corTxBtTurnoE,
            fontWeight: isSelecionado ? FontWeight.bold : FontWeight.normal,
            decoration: isSelecionado ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
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
