import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'dados.dart';
import 'screens/event_screens.dart';
import 'screens/tarefas_screen.dart';
import 'screens/integrantes_screen.dart';
import 'screens/lista_trocas_dia_screen.dart';
import 'screens/lista_horas_extras_dia_screen.dart';
import 'local_storage_service.dart';
import 'models/integrante.dart';
import 'services/holiday_service.dart';

// Rotinas de salvamento de dados de preferências.
Future<File> getCaminhoArquivo({String? arquivo}) async {
  String arq = arquivo ?? "preferencias";
  final directory = await getApplicationDocumentsDirectory();
  return File("${directory.path}/$arq.json");
}

Future<File> salvaArquivo({String? arquivo, List<dynamic>? dados}) async {
  String arq = arquivo ?? "preferencias";
  List<dynamic> dadosASalvar = dados ?? preferencias;
  String data = json.encode(dadosASalvar);
  final file = await getCaminhoArquivo(arquivo: arq);
  return file.writeAsString(data);
}

Future<String> leArquivo({String? arquivo}) async {
  String arq = arquivo ?? "preferencias";
  try {
    final file = await getCaminhoArquivo(arquivo: arq);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return "";
  } catch (e) {
    return "";
  }
}

Future<File> getPreferencia() async {
  final directory = await getApplicationDocumentsDirectory();
  return File("${directory.path}/preferencias.json");
}

Future<File> salvaPreferencia() async {
  String data = json.encode(preferencias);
  final file = await getPreferencia();
  return file.writeAsString(data);
}

Future<String> lePreferencia() async {
  try {
    final file = await getPreferencia();
    if (await file.exists()) {
      return await file.readAsString();
    }
    return "";
  } catch (e) {
    return "";
  }
}

void defineGrupoFavorito(String letra) {
  grupoAtual = grupo[letra]!;
  preferencias[0]["turnoFavorito"] = grupoAtual;
  salvaPreferencia();
}

int ps(DateTime dt) {
  return dt.difference(DateTime(1, 1, 1)).inDays;
}

int indiceGr(String grp) {
  int qdias = ps(DateTime(anoAtual, mesAtual, diaAtual)) + grupo[grp]!;
  return qdias % tamanhoDaSequencia;
}

int indiceDtGr(DateTime dt, String grp) {
  int qdias = ps(dt) + grupo[grp]!;
  return qdias % tamanhoDaSequencia;
}

void mostrarMenuEventos(BuildContext context, DateTime data, String turno) {
  String? feriadoNome = HolidayService.getHolidayName(data);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(feriadoNome != null ? Icons.celebration : Icons.access_time, 
                 color: feriadoNome != null ? Colors.green : Colors.blue, size: 40),
            const SizedBox(height: 10),
            if (feriadoNome != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  feriadoNome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            const Text(
              "Ações para o dia:",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(data),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _botaoMenu(context, "Tarefas", Colors.orange, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => TarefasScreen(data: data, turno: turno)
              ));
            }),
            _botaoMenu(context, "Hora Extra", Colors.orange, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ListaHorasExtrasDiaScreen(data: data, turno: turno)
              ));
            }),
            _botaoMenu(context, "Férias", Colors.orange, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => FeriasScreen(data: data, turno: turno)
              ));
            }),
            _botaoMenu(context, "Trocas", Colors.orange, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ListaTrocasDiaScreen(data: data, turno: turno)
              ));
            }),
            const Divider(),
            _botaoMenu(context, "Compartilhar Escala", Colors.blue, () {
              String texto = gerarEscalaTexto(data);
              SharePlus.instance.share(
                ShareParams(
                  text: texto, 
                  subject: "Escala de Turno - ${DateFormat('dd/MM').format(data)}"
                )
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Fechar", style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

Widget _botaoMenu(BuildContext context, String titulo, Color cor, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
        child: Text(titulo),
      ),
    ),
  );
}

void mostrarPopupIntegrantes(BuildContext context, String grupoLetra) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Integrantes - Grupo ${grupoLetra.toUpperCase()}"),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: LocalStorageService().loadIntegrantes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            final todos = (snapshot.data ?? []).map((e) => Integrante.fromMap(e)).toList();
            final filtrados = todos.where((i) => i.grupo == grupoLetra.toLowerCase()).toList();

            if (filtrados.isEmpty) {
              return const Text("Nenhum integrante cadastrado para este grupo.");
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtrados.length,
                itemBuilder: (context, index) {
                  final item = filtrados[index];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person, color: Colors.orange),
                    title: Text(item.nome, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(item.cargo),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const IntegrantesScreen()));
            },
            child: const Text("GERENCIAR"),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("FECHAR")),
        ],
      );
    },
  );
}

/// Retorna a cor do turno adaptada ao tema atual (Claro ou Escuro)
/// Garante conforto visual e contraste adequado em ambos os modos.
Color getCorTurno(String turno) {
  if (isTemaDark) {
    switch (turno) {
      case "F": return Colors.blue.shade300;
      case "7": return Colors.green.shade400;
      case "15": return Colors.orange.shade300;
      case "23": return Colors.red.shade300;
      default: return Colors.grey;
    }
  } else {
    return coresHorarios[turno] ?? Colors.grey;
  }
}

/// [cardDia] é o componente central da tabela, responsável por renderizar 
/// cada célula do calendário. Possui dois estilos visuais e é altamente 
/// adaptável ao contexto de visualização (Diária, Semanal, Mensal, Anual, Geral).
/// [cardDia] é o componente central da tabela, responsável por renderizar 
/// cada célula do calendário. Possui dois estilos visuais e é altamente 
/// adaptável ao contexto de visualização (Diária, Semanal, Mensal, Anual, Geral).
/// 
/// [indice] - Posição do dia na sequência de turnos.
/// [dm] - Dia do mês (texto).
/// [ds] - Dia da semana abreviado.
/// [full] - Se verdadeiro, renderiza o card em destaque (ex: Preview ou Semanal).
Widget cardDia(int indice, String dm, String ds, Color corDaBarra,
    {int? mes, int? an, bool full = false, String tipo = "", VoidCallback? onTap, 
     bool hasHoliday = false, bool hasEvent = false, bool hasTask = false}) {
  
  Color cor = getCorTurno(tabela[indice]);
  Color fs = corFs[ds]!;
  double mrg = largura * 0.001;

  // --- DNA DE DIMENSÕES (Preserva a adaptabilidade nativa do projeto) ---
  double cardWidth = (full != true) 
      ? (tipo == "aa" ? (largura * 0.72 / numeroDeGrupos) - mrg : (largura / divisoes) - mrg) 
      : largura / 2;
  
  double cardMinHeight = (full != true) 
      ? (tipo == "aa" ? largura / divisoes / 2 : largura / divisoes) 
      : largura / 2;

  // --- ESTILO 1: MODERNO ---
  if (estiloCard == 1) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          width: cardWidth,
          // Definir height fixo evita o erro 'unbounded height' em Column(spaceBetween) 
          // quando o card está dentro de uma ScrollView (DNA de estabilidade).
          height: cardMinHeight, 
          decoration: BoxDecoration(
            color: isTemaDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: Border.all(
              color: isTemaDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
              width: 0.5,
            ),
            boxShadow: (flat || isTemaDark) ? null : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(1, 1)
              )
            ],
          ),
          child: Stack(
            children: [
              // Faixa Lateral do Turno (Identidade do Estilo Moderno)
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(
                  width: (full) ? 10 : 5, 
                  color: (corDaBarra == desabilitado) ? desabilitado : cor,
                ),
              ),
              // Conteúdo do Card distribuído verticalmente
              Padding(
                padding: EdgeInsets.fromLTRB((full) ? 15 : 8, 1, 4, 1),
                child: (tipo == "aa") 
                  ? Stack(
                      children: [
                        // Camada de Indicadores (Bolinhas) no canto superior esquerdo (Opção 1)
                        if (hasHoliday || hasEvent || hasTask)
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Row(
                              children: [
                                if (hasHoliday) _dot(Colors.green, full),
                                if (hasEvent) _dot(Colors.blue, full),
                                if (hasTask) _dot(Colors.orange, full),
                              ],
                            ),
                          ),
                        // Camada de Texto do Turno (Tamanho 18 e Centro Absoluto)
                        Center(
                          child: Text(
                            tabela[indice], 
                            style: TextStyle(
                              color: (corDaBarra == desabilitado) ? desabilitado : cor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18, 
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Topo: Dia da Semana e Indicadores
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (diaSemanVisivel)
                              Text(ds, style: TextStyle(
                                color: fs, 
                                fontSize: (full != true) ? 11 : 22, 
                                fontWeight: FontWeight.bold
                              )),
                            if (hasHoliday || hasEvent || hasTask)
                              Row(
                                children: [
                                  if (hasHoliday) _dot(Colors.green, full),
                                  if (hasEvent) _dot(Colors.blue, full),
                                  if (hasTask) _dot(Colors.orange, full),
                                ],
                              ),
                          ],
                        ),
                        // Centro: Número do Dia (Foco Principal)
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Text(dm, textAlign: TextAlign.center, style: TextStyle(
                                color: (corDaBarra == Colors.amber) 
                                    ? Colors.amber 
                                    : (corDaBarra == desabilitado) 
                                        ? corDaBarra 
                                        : (isTemaDark ? Colors.white : Colors.black),
                                fontWeight: FontWeight.bold,
                                fontSize: (full != true) ? tamanhoFonteData : 60,
                              )),
                            ),
                          ),
                        ),
                        // Rodapé: Letra do Turno
                        Container(
                          alignment: Alignment.bottomRight,
                          child: Text(tabela[indice], style: TextStyle(
                            color: (corDaBarra == desabilitado) ? corDaBarra : cor,
                            fontWeight: FontWeight.bold,
                            fontSize: (full != true) ? 12 : 30,
                          )),
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ESTILO 0: CLÁSSICO (Original Restaurado com Estabilidade) ---
  bool dsv = false;
  bool dmv = false;
  bool hc = true;
  bool bctv = false;
  bool bv = false;

  if (tipo == "aa") {
    dsv = false;
    dmv = false;
    hc = (barraVisivel) ? true : false;
    bctv = (barraVisivel) ? false : true;
    bv = false;
  }

  return InkWell(
    onTap: onTap,
    child: Container(
      width: cardWidth,
      // Usamos constraints em vez de height fixo para o modo Clássico.
      // Isso permite que o card cresça se o conteúdo for maior que o minHeight,
      // evitando o erro de 'BOTTOM OVERFLOWED' em telas pequenas.
      constraints: BoxConstraints(minHeight: cardMinHeight),
      padding: const EdgeInsets.fromLTRB(2, 2, 4, 0),
      decoration: BoxDecoration(
        border: (flat) ? Border.all(color: Colors.grey) : Border.all(color: Colors.white54),
        boxShadow: (flat || isTemaDark) ? null : [const BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 10)],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: (isTemaDark) ? null : Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Visibility(
            visible: (tipo == "aa") ? dsv : diaSemanVisivel,
            child: Text(ds, textAlign: TextAlign.center, style: TextStyle(color: fs, fontSize: (full != true) ? 15 : 30)),
          ),
          
          if (hasHoliday || hasEvent || hasTask)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasHoliday) _dot(Colors.green, full),
                if (hasEvent) _dot(Colors.blue, full),
                if (hasTask) _dot(Colors.orange, full),
              ],
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: (tipo == "aa") ? dmv : diaMesVisivel,
                child: Expanded(
                  child: Text(dm, textAlign: TextAlign.center, style: TextStyle(
                    color: (corDaBarra == Colors.amber && !barraVisivel) ? Colors.amber : (corDaBarra == desabilitado) ? corDaBarra : (isTemaDark) ? null : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: (full != true) ? tamanhoFonteData : 40,
                  )),
                ),
              ),
              Visibility(
                visible: (tipo == "aa") ? hc : horarioCentro,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(tabela[indice], textAlign: TextAlign.center, style: TextStyle(
                    color: (corDaBarra == desabilitado) ? corDaBarra : cor,
                    decoration: (tipo == "aa") ? TextDecoration.none : TextDecoration.underline,
                    fontSize: tamanhoFonteDataR,
                    fontWeight: (tabela[indice] == "F") ? FontWeight.bold : FontWeight.normal,
                  )),
                ),
              ),
            ],
          ),
          Visibility(
            visible: (tipo == "aa") ? bctv : barraComTabelaVisivel,
            child: Container(
              margin: const EdgeInsets.only(bottom: 5),
              width: double.maxFinite,
              color: (isTemaDark) ? cor.withValues(alpha: 0.4) : cor,
              child: Text(tabela[indice], textAlign: TextAlign.center, style: TextStyle(
                color: Colors.white,
                fontSize: (full != true) ? 15 : 35,
                fontWeight: (tabela[indice] == "F") ? FontWeight.bold : FontWeight.normal,
              )),
            ),
          ),
          Visibility(
            visible: (tipo == "aa") ? bv : barraVisivel,
            child: Divider(color: corDaBarra, thickness: (full != true) ? 3 : 10),
          )
        ],
      ),
    ),
  );
}

Widget _dot(Color color, bool isFull) {
  double size = isFull ? 8 : 4;
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 1),
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

Widget mes(int mes, {Key? key}) {
  return Container(
    key: key,
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
    padding: const EdgeInsets.all(2),
    width: double.infinity,
    decoration: BoxDecoration(
      color: (isTemaDark) ? Colors.black : Colors.blue.shade800,
      border: Border.all(color: corBordaMes, width: 2),
      borderRadius: const BorderRadius.all(Radius.circular(10)),
    ),
    child: Text(meses[mes], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20)),
  );
}

dynamic corpoTabela(String tipo, BuildContext context, {int? pAno, int? pMes, int? pGrupo, Key? pKeyAlvo, int? pMesAlvo}) {
  int a = pAno ?? anoAtual;
  int m = pMes ?? mesAtual;
  int g = pGrupo ?? grupoAtual;

  divisoes = 7;
  int dias = 42;
  int deslocSegunda = 0;
  int qdiasB = 0;
  int indiceB = 0;
  int qdiasC = 0;
  int indiceC = 0;
  int qdiasD = 0;
  int indiceD = 0;
  int qdiasE = 0;
  int indiceE = 0;
  int qdiasF = 0;
  int indiceF = 0;
  int diaAux = 1;

  if (tipo == "a") {
    dias = DateTime(a + 1, 1, 1).difference(DateTime(a, 1, 1)).inDays;
  } else if (tipo == "aa") {
    dias = 378;
  } else if (tipo == "m") {
    dias = 42;
  }

  List<Widget> diasCard = [];
  List<Widget> diasCardAux = [];

  var dS = (tipo == "a" || tipo == "aa") ? DateTime(a, 1, 1) : DateTime(a, m, 1);
  var aux = dS;

  if (tipo == "m" || tipo == "aa") {
    deslocSegunda = dS.weekday - 1;
    aux = dS.subtract(Duration(days: deslocSegunda));
    dS = aux;
  }

  int qdias = (tipo == "aa") ? ps(dS) + grupo["a"]! : ps(dS) + g;
  int indice = qdias % tamanhoDaSequencia;

  if (tipo == "aa") {
    qdiasB = ps(dS) + grupo["b"]!;
    indiceB = qdiasB % tamanhoDaSequencia;
    qdiasC = ps(dS) + grupo["c"]!;
    indiceC = qdiasC % tamanhoDaSequencia;
    qdiasD = ps(dS) + grupo["d"]!;
    indiceD = qdiasD % tamanhoDaSequencia;
    qdiasE = ps(dS) + grupo["e"]!;
    indiceE = qdiasE % tamanhoDaSequencia;
    qdiasF = ps(dS) + grupo["f"]!;
    indiceF = qdiasF % tamanhoDaSequencia;
  }

  int esteMes = aux.month;
  Color corDaBarra;

  if (tipo == "a" || tipo == "aa") {
    diasCard.add(mes(aux.month - 1, key: (aux.month == pMesAlvo && aux.year == a) ? pKeyAlvo : null));
  }

  for (int dia = 1; dia <= dias; dia++) {
    if (esteMes != aux.month && (tipo == "a" || tipo == "aa")) {
      if (tipo == "a") {
        diasCard.add(Row(children: diasCardAux));
        diasCardAux = [];
        diaAux = 1;
      }
      diasCard.add(mes(aux.month - 1, key: (aux.month == pMesAlvo && aux.year == a) ? pKeyAlvo : null));
      esteMes = aux.month;
    }

    corDaBarra = (diaHoje == aux.day && mesHoje == aux.month && anoHoje == aux.year) ? corBarraBtTurnoC : corBarraBtTurnoE;
    if (tipo == "m" && (mesAtual != aux.month)) {
      corDaBarra = desabilitado;
    }

    final DateTime dateSnapshot = aux;
    final int indexSnapshot = indice;
    final int indexBSnapshot = indiceB;
    final int indexCSnapshot = indiceC;
    final int indexDSnapshot = indiceD;
    final int indexESnapshot = indiceE;
    final int indexFSnapshot = indiceF;

    bool hasH = HolidayService.getHolidayName(aux) != null;
    bool hasE = temEventoNoDia(aux);
    bool hasT = temTarefaNoDia(aux);

    if (tipo == "aa") {
      diasCard.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: largura * 0.15,
            alignment: Alignment.center,
            child: Text("${aux.day}-${mesesAbrev[aux.month - 1]}", style: TextStyle(color: corDaBarra)),
          ),
          Container(
            width: largura * 0.13,
            alignment: Alignment.center,
            child: Text(diaSemana[aux.weekday - 1], style: TextStyle(color: corFs[diaSemana[aux.weekday - 1]])),
          ),
          cardDia(indice, aux.day.toString(), diaSemana[aux.weekday - 1], corDaBarra, tipo: tipo, onTap: () => mostrarMenuEventos(context, dateSnapshot, tabela[indexSnapshot]), hasHoliday: hasH, hasEvent: hasE, hasTask: hasT),
          cardDia(indiceB, aux.day.toString(), diaSemana[aux.weekday - 1], corDaBarra, tipo: tipo, onTap: () => mostrarMenuEventos(context, dateSnapshot, tabela[indexBSnapshot]), hasHoliday: hasH, hasEvent: hasE, hasTask: hasT),
          if (numeroDeGrupos >= 3) cardDia(indiceC, aux.day.toString(), diaSemana[aux.weekday - 1], corDaBarra, tipo: tipo, onTap: () => mostrarMenuEventos(context, dateSnapshot, tabela[indexCSnapshot]), hasHoliday: hasH, hasEvent: hasE, hasTask: hasT),
          if (numeroDeGrupos >= 4) cardDia(indiceD, aux.day.toString(), diaSemana[aux.weekday - 1], corDaBarra, tipo: tipo, onTap: () => mostrarMenuEventos(context, dateSnapshot, tabela[indexDSnapshot]), hasHoliday: hasH, hasEvent: hasE, hasTask: hasT),
          if (numeroDeGrupos >= 5) cardDia(indiceE, aux.day.toString(), diaSemana[aux.weekday - 1], corDaBarra, tipo: tipo, onTap: () => mostrarMenuEventos(context, dateSnapshot, tabela[indexESnapshot]), hasHoliday: hasH, hasEvent: hasE, hasTask: hasT),
          if (numeroDeGrupos == 6) cardDia(indiceF, aux.day.toString(), diaSemana[aux.weekday - 1], corDaBarra, tipo: tipo, onTap: () => mostrarMenuEventos(context, dateSnapshot, tabela[indexFSnapshot]), hasHoliday: hasH, hasEvent: hasE, hasTask: hasT),
        ],
      ));
    } else if (tipo == "a") {
      diasCardAux.add(cardDia(indice, aux.day.toString(), diaSemana[aux.weekday - 1], corDaBarra, tipo: tipo, onTap: () => mostrarMenuEventos(context, dateSnapshot, tabela[indexSnapshot]), hasHoliday: hasH, hasEvent: hasE, hasTask: hasT));
      if (diaAux % divisoes == 0 || esteMes != aux.month || dia == dias) {
        diasCard.add(Row(children: diasCardAux));
        diasCardAux = [];
        diaAux = 0;
      }
      diaAux++;
    } else {
      diasCard.add(cardDia(indice, aux.day.toString(), diaSemana[aux.weekday - 1], corDaBarra, tipo: tipo, onTap: () => mostrarMenuEventos(context, dateSnapshot, tabela[indexSnapshot]), hasHoliday: hasH, hasEvent: hasE, hasTask: hasT));
    }

    indice = (indice < tamanhoDaSequencia - 1) ? indice + 1 : 0;
    if (tipo == "aa") {
      indiceB = (indiceB < tamanhoDaSequencia - 1) ? indiceB + 1 : 0;
      if (numeroDeGrupos >= 3) indiceC = (indiceC < tamanhoDaSequencia - 1) ? indiceC + 1 : 0;
      if (numeroDeGrupos >= 4) indiceD = (indiceD < tamanhoDaSequencia - 1) ? indiceD + 1 : 0;
      if (numeroDeGrupos >= 5) indiceE = (indiceE < tamanhoDaSequencia - 1) ? indiceE + 1 : 0;
      if (numeroDeGrupos == 6) indiceF = (indiceF < tamanhoDaSequencia - 1) ? indiceF + 1 : 0;
    }
    aux = dS.add(Duration(days: dia));
  }
  return (tipo == "aa" || tipo == "a") ? diasCard : Wrap(children: diasCard);
}

Widget cardSemana(int indice, String dm, String ds, Color corDaBarra, {int? mes, int? ano, VoidCallback? onTap, bool hasHoliday = false, bool hasEvent = false, bool hasTask = false}) {
  Color cor = coresHorarios[tabela[indice]]!;
  Color fs = corFs[ds]!;
  double mrg = largura * 0.001;
  double larTxt = ((largura / divisoes) - mrg) * 0.38;
  return InkWell(
    onTap: onTap,
    child: Container(
      width: largura / divisoes - mrg,
      height: largura / divisoes,
      padding: const EdgeInsets.fromLTRB(2, 2, 4, 0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54),
        boxShadow: isTemaDark ? null : [const BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 10)],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: (isTemaDark) ? null : Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ds, textAlign: TextAlign.center, style: TextStyle(color: fs, fontSize: 14)),
              Row(
                children: [
                  if (hasHoliday) _dot(Colors.green, false),
                  if (hasEvent) _dot(Colors.blue, false),
                  if (hasTask) _dot(Colors.orange, false),
                ],
              )
            ],
          ),
          Row(
            children: [
              Expanded(child: Text(dm, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: tamanhoFonteData * 2.0))),
              Container(
                width: larTxt,
                color: cor,
                child: Text(tabela[indice], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Text("${mesesAbrev[mes! - 1]}/$ano", style: TextStyle(color: (isTemaDark) ? null : cor, fontSize: 10)),
          Divider(color: corDaBarra, thickness: 4)
        ],
      ),
    ),
  );
}

Widget semanaWrap(BuildContext context, {int? pGrupo}) {
  int g = pGrupo ?? grupoAtual;
  divisoes = 3;
  List<Widget> diasCard = [];
  var dS = dataHoje.subtract(Duration(days: (dataHoje.weekday - 1) + semanas));
  var aux = dS;
  int qdias = ps(dS) + g;
  int indice = qdias % 35;
  Color corDaBarra;

  for (int dia = 1; dia <= 7; dia++) {
    corDaBarra = (diaHoje == aux.day && mesHoje == aux.month && anoHoje == aux.year) ? corBarraBtTurnoC : corBarraBtTurnoE;
    final DateTime dateSnapshot = aux;
    final int indexSnapshot = indice;
    
    bool hasH = HolidayService.getHolidayName(aux) != null;
    bool hasE = temEventoNoDia(aux);
    bool hasT = temTarefaNoDia(aux);

    diasCard.add(cardSemana(indice, aux.day.toString(), diaSemana[aux.weekday - 1], corDaBarra, mes: aux.month, ano: aux.year, onTap: () => mostrarMenuEventos(context, dateSnapshot, tabela[indexSnapshot]), hasHoliday: hasH, hasEvent: hasE, hasTask: hasT));
    indice = (indice < tamanhoDaSequencia - 1) ? indice + 1 : 0;
    aux = dS.add(Duration(days: dia));
  }
  return Wrap(children: diasCard);
}

String dataIsoParaLocal(String data) {
  List<String> dataLocal = data.split('-');
  return "${dataLocal[2]}/${dataLocal[1]}/${dataLocal[0]}";
}

Future<void> atualizarCache() async {
  cacheEventos = await LocalStorageService().loadEventos();
  cacheTarefas = await LocalStorageService().loadTarefas();
}

bool temEventoNoDia(DateTime dt) {
  String key = DateFormat('yyyy-MM-dd').format(dt);
  return cacheEventos.containsKey(key);
}

bool temTarefaNoDia(DateTime dt) {
  String key = DateFormat('yyyy-MM-dd').format(dt);
  return cacheTarefas.any((t) => t['date'].startsWith(key));
}

/// Retorna os tipos de eventos já cadastrados em uma data específica
List<String> getEventosNoDia(DateTime dt) {
  String key = DateFormat('yyyy-MM-dd').format(dt);
  if (cacheEventos.containsKey(key)) {
    Map<String, dynamic> evs = cacheEventos[key] as Map<String, dynamic>;
    return evs.keys.toList();
  }
  return [];
}

/// Retorna os dados de um evento específico em uma data
Map<String, dynamic>? getDadosEventoNoDia(DateTime dt, String tipo, {String? id}) {
  String key = DateFormat('yyyy-MM-dd').format(dt);
  if (cacheEventos.containsKey(key)) {
    Map<String, dynamic> evs = cacheEventos[key] as Map<String, dynamic>;
    if (evs.containsKey(tipo)) {
      var data = evs[tipo];
      if ((tipo == "troca" || tipo == "hora_extra") && data is List) {
        if (id != null) {
          return data.firstWhere((t) => t["id"] == id, orElse: () => null) as Map<String, dynamic>?;
        }
        return data.isNotEmpty ? data.first as Map<String, dynamic> : null;
      }
      return data as Map<String, dynamic>;
    }
  }
  return null;
}

/// Retorna uma lista de todos os eventos de um tipo específico no dia
List<Map<String, dynamic>> getTodosEventosTipoNoDia(DateTime dt, String tipo) {
  String key = DateFormat('yyyy-MM-dd').format(dt);
  if (cacheEventos.containsKey(key)) {
    Map<String, dynamic> evs = cacheEventos[key] as Map<String, dynamic>;
    if (evs.containsKey(tipo)) {
      var data = evs[tipo];
      if (data is List) return data.cast<Map<String, dynamic>>();
      return [data as Map<String, dynamic>];
    }
  }
  return [];
}

/// Retorna uma lista de todas as trocas de um dia
List<Map<String, dynamic>> getTodasTrocasNoDia(DateTime dt) {
  return getTodosEventosTipoNoDia(dt, "troca");
}

/// Retorna uma lista de todas as horas extras de um dia
List<Map<String, dynamic>> getTodasHorasExtrasNoDia(DateTime dt) {
  return getTodosEventosTipoNoDia(dt, "hora_extra");
}

/// Retorna o turno ("7", "15", "23", "F") de um grupo específico em uma data
String getTurnoPorGrupo(DateTime data, String letraGrupo) {
  int idx = indiceDtGr(data, letraGrupo.toLowerCase());
  return tabela[idx];
}

/// Calcula o intervalo em horas entre o fim do turno 1 e o início do turno 2
double calcularIntervaloHoras(DateTime d1, String t1, DateTime d2, String t2) {
  // Se um dos dias é folga, o intervalo é considerado seguro (ex: 99h)
  if (t1 == "F" || t2 == "F") return 99.0;

  final h1 = horariosTurnos[t1]!;
  final h2 = horariosTurnos[t2]!;

  // Horário de término do primeiro turno
  DateTime fimT1 = DateTime(d1.year, d1.month, d1.day).add(Duration(minutes: h1["fim"]!));
  if (t1 == "23") {
    // Turno da noite termina no dia seguinte
    fimT1 = fimT1.add(const Duration(days: 1));
  }

  // Horário de início do segundo turno
  DateTime inicioT2 = DateTime(d2.year, d2.month, d2.day).add(Duration(minutes: h2["inicio"]!));

  return inicioT2.difference(fimT1).inMinutes / 60.0;
}

/// Gera um texto formatado da escala para compartilhamento
String gerarEscalaTexto(DateTime data) {
  String dataFormatada = DateFormat('dd/MM/yyyy (EEEE)', 'pt_BR').format(data);
  String buffer = "📅 *ESCALA DE TURNO - $dataFormatada*\n";
  buffer += "--------------------------------------\n";

  for (int i = 0; i < numeroDeGrupos; i++) {
    String letra = grupos[i].toLowerCase();
    String turno = getTurnoPorGrupo(data, letra);
    String emoji = "🔵"; // Folga
    String desc = "Folga";

    if (turno == "7") {
      emoji = "🟢";
      desc = "07:00 às 15:00";
    } else if (turno == "15") {
      emoji = "🟠";
      desc = "15:00 às 23:00";
    } else if (turno == "23") {
      emoji = "🔴";
      desc = "23:00 às 07:00";
    }

    buffer += "$emoji *Grupo ${grupos[i]}*: $desc\n";
  }

  buffer += "--------------------------------------\n";
  buffer += "_Gerado pelo App Tabela de Turno_";
  return buffer;
}

/// Gera um texto formatado com os integrantes dos grupos selecionados.
/// 
/// Utiliza os metadados dos integrantes salvos no [LocalStorageService] para 
/// construir uma mensagem legível para WhatsApp, organizada por grupo.
Future<String> gerarTextoEquipe(List<String> gruposSelecionados) async {
  List<Map<String, dynamic>> integrantesRaw = await LocalStorageService().loadIntegrantes();
  List<Integrante> todos = integrantesRaw.map((e) => Integrante.fromMap(e)).toList();

  String buffer = "👥 *EQUIPE DE TRABALHO*\n";
  buffer += "--------------------------------------\n";

  for (String g in gruposSelecionados) {
    buffer += "\n*GRUPO ${g.toUpperCase()}*\n";
    var filtrados = todos.where((i) => i.grupo == g.toLowerCase()).toList();
    if (filtrados.isEmpty) {
      buffer += "_Nenhum integrante cadastrado_\n";
    } else {
      for (var it in filtrados) {
        buffer += "• ${it.nome} (${it.cargo})\n";
      }
    }
  }

  buffer += "\n--------------------------------------\n";
  buffer += "_Gerado pelo App Tabela de Turno_";
  return buffer;
}
