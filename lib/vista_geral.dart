import 'package:flutter/material.dart';
import 'rotinas.dart';
import 'dados.dart';

class VistaGeral extends StatefulWidget {
  final int ano;
  final int grupo;
  final bool isVisible;
  const VistaGeral({super.key, required this.ano, required this.grupo, this.isVisible = false});

  @override
  State<VistaGeral> createState() => _VistaGeralState();
}

class _VistaGeralState extends State<VistaGeral> {
  final GlobalKey _mesAtualKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Se o ano visualizado for o atual e a aba já estiver visível na criação
    if (widget.ano == DateTime.now().year && widget.isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _safeScrollToMonth());
    }
  }

  @override
  void didUpdateWidget(covariant VistaGeral oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Dispara o scroll se a página acaba de se tornar visível ou se o ano mudou para o atual
    if ((widget.isVisible && !oldWidget.isVisible) || 
        (widget.isVisible && widget.ano != oldWidget.ano)) {
      if (widget.ano == DateTime.now().year) {
        _safeScrollToMonth();
      }
    }
  }

  /// Tenta realizar o scroll para o mês atual de forma segura e resiliente.
  /// Caso o layout ainda não esteja pronto, realiza novas tentativas com pequenos delays.
  void _safeScrollToMonth({int attempts = 0}) {
    if (!mounted || !widget.isVisible) {
      debugPrint("AUDITORIA (VistaGeral): Abortando scroll - Aba não visível ou desmontada.");
      return; 
    }
    
    if (attempts > 15) {
      debugPrint("AUDITORIA (VistaGeral): Falha definitiva após 15 tentativas. Contexto não encontrado.");
      return; 
    }

    // Delay inicial maior para aguardar a animação do PageView (300ms) terminar
    int delay = (attempts == 0) ? 500 : 150;

    Future.delayed(Duration(milliseconds: delay), () {
      if (_mesAtualKey.currentContext != null) {
        debugPrint("AUDITORIA (VistaGeral): Contexto encontrado na tentativa $attempts. Iniciando scroll...");
        Scrollable.ensureVisible(
          _mesAtualKey.currentContext!,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
          alignment: 0.0, // Posiciona o cabeçalho no topo exato da tela
        );
      } else {
        debugPrint("AUDITORIA (VistaGeral): Contexto nulo na tentativa $attempts. Reagendando...");
        _safeScrollToMonth(attempts: attempts + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> vaa = corpoTabela(
      "aa", 
      context, 
      pAno: widget.ano, 
      pGrupo: widget.grupo,
      pKeyAlvo: _mesAtualKey,
      pMesAlvo: DateTime.now().month
    );
    
    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        children: vaa,
      ),
    );
  }
}
