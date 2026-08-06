import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../local_storage_service.dart';
import '../rotinas.dart';
import '../dados.dart';
import '../models/integrante.dart';

/// Tela para lançamento e edição de Horas Extras.
/// Suporta múltiplos lançamentos por dia através de identificadores únicos.
class HoraExtraScreen extends StatefulWidget {
  final DateTime data;
  final String turno;
  final String? editExtraId; // ID específico para edição, se houver.

  const HoraExtraScreen({super.key, required this.data, required this.turno, this.editExtraId});

  @override
  State<HoraExtraScreen> createState() => _HoraExtraScreenState();
}

class _HoraExtraScreenState extends State<HoraExtraScreen> {
  final TextEditingController _horasController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();
  String? _currentId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentId = widget.editExtraId;
    _loadData();
  }

  /// Carrega os dados da hora extra se for uma edição, caso contrário mantém os campos limpos.
  Future<void> _loadData() async {
    String dateKey = DateFormat('yyyy-MM-dd').format(widget.data);
    
    // Só carrega do armazenamento se tivermos um ID de edição.
    if (_currentId != null) {
      var data = await LocalStorageService().getEventoPorData(dateKey, "hora_extra", id: _currentId);
      if (data != null) {
        setState(() {
          _horasController.text = data["horas"] ?? "";
          _obsController.text = data["obs"] ?? "";
          _currentId = data["id"];
        });
      }
    }
    setState(() => _isLoading = false);
  }

  /// Persiste os dados da hora extra.
  Future<void> _saveData() async {
    String dateKey = DateFormat('yyyy-MM-dd').format(widget.data);
    await LocalStorageService().saveEventoParaData(dateKey, "hora_extra", {
      "id": _currentId,
      "horas": _horasController.text,
      "obs": _obsController.text,
    });
    
    // Atualiza o cache global para que os indicadores no calendário reflitam a mudança.
    await atualizarCache();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hora Extra salva!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hora Extra"), backgroundColor: Colors.orange),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Data: ${DateFormat('dd/MM/yyyy').format(widget.data)}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                TextField(
                  controller: _horasController,
                  decoration: const InputDecoration(labelText: "Quantidade de Horas", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _obsController,
                  decoration: const InputDecoration(labelText: "Observações", border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)),
                  child: const Text("SALVAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
    );
  }
}

/// Tela para lançamento de períodos de Férias.
class FeriasScreen extends StatefulWidget {
  final DateTime data;
  final String turno;
  const FeriasScreen({super.key, required this.data, required this.turno});

  @override
  State<FeriasScreen> createState() => _FeriasScreenState();
}

class _FeriasScreenState extends State<FeriasScreen> {
  DateTime? _dataFim;
  final TextEditingController _obsController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    String dateKey = DateFormat('yyyy-MM-dd').format(widget.data);
    var data = await LocalStorageService().getEventoPorData(dateKey, "ferias");
    if (data != null) {
      if (data["dataFim"] != null) _dataFim = DateTime.parse(data["dataFim"]);
      _obsController.text = data["obs"] ?? "";
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    String dateKey = DateFormat('yyyy-MM-dd').format(widget.data);
    await LocalStorageService().saveEventoParaData(dateKey, "ferias", {
      "dataFim": _dataFim?.toIso8601String(),
      "obs": _obsController.text,
    });
    await atualizarCache();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Férias salvas!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Férias"), backgroundColor: Colors.orange),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Início: ${DateFormat('dd/MM/yyyy').format(widget.data)}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("Fim: ", style: TextStyle(fontSize: 18)),
                    Text(_dataFim == null ? "Não definido" : DateFormat('dd/MM/yyyy').format(_dataFim!), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _dataFim ?? widget.data.add(const Duration(days: 30)),
                          firstDate: widget.data,
                          lastDate: widget.data.add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _dataFim = picked);
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _obsController,
                  decoration: const InputDecoration(labelText: "Observações", border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)),
                  child: const Text("SALVAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
    );
  }
}

/// Tela para gestão de Trocas de Turno.
/// Permite definir quem trabalhará para quem e as datas de compensação.
class TrocasScreen extends StatefulWidget {
  final DateTime data;
  final String turno;
  final String? editSwapId; // ID para edição de uma troca específica em uma lista.

  const TrocasScreen({super.key, required this.data, required this.turno, this.editSwapId});

  @override
  State<TrocasScreen> createState() => _TrocasScreenState();
}

class _TrocasScreenState extends State<TrocasScreen> {
  final TextEditingController _colaboradorController = TextEditingController();
  String _grupoColaborador = 'a';
  late DateTime _dataTrabalho;
  DateTime? _dataCompensacao;
  String? _currentId; 

  List<Integrante> _todosIntegrantes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataTrabalho = widget.data;
    _currentId = widget.editSwapId;
    _loadData();
  }

  Future<void> _loadData() async {
    final integrantes = await LocalStorageService().loadIntegrantes();
    
    if (_currentId != null) {
      final event = await LocalStorageService().getEventoPorData(
        DateFormat('yyyy-MM-dd').format(widget.data), 
        "troca", 
        id: _currentId
      );
      
      if (event != null) {
        setState(() {
          _todosIntegrantes = integrantes.map((e) => Integrante.fromMap(e)).toList();
          _grupoColaborador = event["grupoParceiro"] ?? "a";
          _colaboradorController.text = event["parceiroNome"] ?? "";
          _currentId = event["id"];
          
          if (event["dataTrabalho"] != null) {
            _dataTrabalho = DateTime.parse(event["dataTrabalho"]);
          }
          if (event["dataCompensacao"] != null) {
            _dataCompensacao = DateTime.parse(event["dataCompensacao"]);
          }
          _isLoading = false;
        });
        return;
      }
    }

    setState(() {
      _todosIntegrantes = integrantes.map((e) => Integrante.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  String get _meuGrupoLetra {
    String letra = "a";
    grupo.forEach((key, value) {
      if (value == grupoAtual) letra = key;
    });
    return letra;
  }

  Future<void> _saveData() async {
    if (_colaboradorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Informe com quem irá trocar.")));
      return;
    }

    String originalKey = DateFormat('yyyy-MM-dd').format(widget.data);
    String novaKey = DateFormat('yyyy-MM-dd').format(_dataTrabalho);

    // Se a data de trabalho foi alterada, removemos o registro do dia antigo.
    if (originalKey != novaKey && _currentId != null) {
      await LocalStorageService().deleteEvento(originalKey, "troca", id: _currentId);
      _currentId = null; // Reseta o ID para criar um novo registro na nova data.
    }

    await LocalStorageService().saveEventoParaData(novaKey, "troca", {
      "id": _currentId,
      "parceiroNome": _colaboradorController.text,
      "grupoParceiro": _grupoColaborador,
      "dataTrabalho": _dataTrabalho.toIso8601String(),
      "dataCompensacao": _dataCompensacao?.toIso8601String(),
      "meuHorarioOriginal": widget.turno,
      "horarioParceiroOriginal": getTurnoPorGrupo(_dataTrabalho, _grupoColaborador),
    });
    
    await atualizarCache();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Troca salva com sucesso!")));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final integrantesDoGrupo = _todosIntegrantes
        .where((i) => i.grupo == _grupoColaborador)
        .map((i) => i.nome)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Gestão de Troca"), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Trocar com", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _grupoColaborador,
              decoration: const InputDecoration(labelText: "Grupo do Colaborador", border: OutlineInputBorder()),
              items: ['a', 'b', 'c', 'd', 'e', 'f'].sublist(0, numeroDeGrupos).map((g) {
                return DropdownMenuItem(value: g, child: Text("Grupo ${g.toUpperCase()}"));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _grupoColaborador = val!;
                });
              },
            ),
            const SizedBox(height: 15),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return integrantesDoGrupo;
                }
                return integrantesDoGrupo.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _colaboradorController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                if (controller.text.isEmpty && _colaboradorController.text.isNotEmpty) {
                  controller.text = _colaboradorController.text;
                }
                controller.addListener(() {
                   _colaboradorController.text = controller.text;
                });

                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: "Nome do Colaborador",
                    border: OutlineInputBorder(),
                    hintText: "Selecione ou digite um nome",
                    suffixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (value) => onFieldSubmitted(),
                );
              },
            ),
            
            const SizedBox(height: 25),
            const Text("2. Datas da Troca", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 10),
            ListTile(
              title: const Text("Eu trabalho para ele em:"),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataTrabalho)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dataTrabalho,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _dataTrabalho = picked);
              },
            ),
            ListTile(
              title: const Text("Ele compensa para mim em:"),
              subtitle: Text(_dataCompensacao == null ? "Não definido" : DateFormat('dd/MM/yyyy').format(_dataCompensacao!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dataCompensacao ?? _dataTrabalho.add(const Duration(days: 7)),
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _dataCompensacao = picked);
              },
            ),

            const SizedBox(height: 20),
            _buildIntelligencePanel(),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(double.infinity, 50)),
              child: const Text("SALVAR TROCA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  /// Gera um painel de análise de viabilidade com avisos de descanso, folgas e fadiga.
  Widget _buildIntelligencePanel() {
    List<Widget> alerts = [];
    
    // --- 0. Verificação de Data Passada ---
    if (_dataTrabalho.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
      alerts.add(_alertItem("📅 Registro Retroativo: Esta troca ocorreu no passado.", Colors.blue));
    }

    // --- 1. Verificação de Conflitos de Eventos (Somente para VOCÊ) ---
    List<String> eventosD1 = getEventosNoDia(_dataTrabalho);
    if (eventosD1.isNotEmpty) {
      if (eventosD1.contains("ferias")) {
        alerts.add(_alertItem("❌ Conflito Crítico: Você está de FÉRIAS no dia que pretende trabalhar.", Colors.red));
      }
    }

    if (_dataCompensacao != null) {
      List<String> eventosD2 = getEventosNoDia(_dataCompensacao!);
      if (eventosD2.contains("ferias")) {
        alerts.add(_alertItem("❌ Conflito Crítico: Você está de FÉRIAS na data da compensação.", Colors.red));
      }
    }

    DateTime dTrab = _dataTrabalho;
    DateTime? dComp = _dataCompensacao;

    // Avisos de folga redundante (Lógica corrigida: foca em quem recebe o trabalho)
    String meuOriginalD1 = getTurnoPorGrupo(dTrab, _meuGrupoLetra);
    String deleOriginalD1 = getTurnoPorGrupo(dTrab, _grupoColaborador);
    
    // Se eu trabalho para ele, mas ele já está de folga original.
    if (deleOriginalD1 == "F") {
      alerts.add(_alertItem("ℹ️ Nota: O colaborador já estaria de folga em ${DateFormat('dd/MM').format(dTrab)}. Verifique a real necessidade de render alguém que não trabalha.", Colors.blue));
    }

    if (dComp != null) {
      String meuOriginalD2 = getTurnoPorGrupo(dComp, _meuGrupoLetra);
      // Se ele compensa para mim, mas eu já estaria de folga original.
      if (meuOriginalD2 == "F") {
        alerts.add(_alertItem("ℹ️ Nota: Você já estaria de folga em ${DateFormat('dd/MM').format(dComp)}. Verifique a necessidade de ele trabalhar para você.", Colors.blue));
      }
    }

    /// Projeta o turno de uma pessoa considerando a troca atual na memória.
    String getTurnoProj(DateTime data, bool isMe) {
      String dataS = DateFormat('yyyy-MM-dd').format(data);
      String trabS = DateFormat('yyyy-MM-dd').format(dTrab);
      String compS = dComp != null ? DateFormat('yyyy-MM-dd').format(dComp) : "";

      if (isMe) {
        if (dataS == trabS) return getTurnoPorGrupo(data, _grupoColaborador);
        if (dataS == compS) return "F";
        return getTurnoPorGrupo(data, _meuGrupoLetra);
      } else {
        if (dataS == trabS) return "F";
        if (dataS == compS) return getTurnoPorGrupo(data, _meuGrupoLetra);
        return getTurnoPorGrupo(data, _grupoColaborador);
      }
    }

    // --- 3. Análise Espelhada de Descanso e Jornada ---
    List<DateTime> datasImpactadas = [dTrab];
    if (dComp != null) datasImpactadas.add(dComp);
    datasImpactadas = datasImpactadas.toSet().toList()..sort();

    List<Map<String, dynamic>> todasTrocasD1 = getTodasTrocasNoDia(dTrab);
    if (_currentId != null) {
      todasTrocasD1.removeWhere((t) => t["id"] == _currentId);
    }

    for (bool checkingMe in [true, false]) {
      String prefixo = checkingMe ? "Seu" : "Do Colaborador";
      Color corAlerta = checkingMe ? Colors.orange : Colors.deepOrange;

      for (DateTime d in datasImpactadas) {
        DateTime dAnt = d.subtract(const Duration(days: 1));
        DateTime dProx = d.add(const Duration(days: 1));
        
        String tPrev = getTurnoProj(dAnt, checkingMe);
        String tAtual = getTurnoProj(d, checkingMe);
        String tNext = getTurnoProj(dProx, checkingMe);

        // --- Verificação de Carga Horária (Jornada) ---
        double jornadaBase = (tAtual != "F") ? 8.0 : 0.0;
        double horasExtrasTotal = 0;
        
        if (checkingMe) {
          // Soma todas as horas extras registradas no dia.
          List<Map<String, dynamic>> extras = getTodasHorasExtrasNoDia(d);
          for (var ex in extras) {
            horasExtrasTotal += double.tryParse(ex["horas"]?.toString() ?? "0") ?? 0;
          }
          // Soma outras trocas do mesmo dia para detectar sobrecarga.
          if (DateFormat('yyyy-MM-dd').format(d) == DateFormat('yyyy-MM-dd').format(dTrab)) {
            for (var t in todasTrocasD1) {
              String hor = t["horarioParceiroOriginal"] ?? "F";
              if (hor != "F") jornadaBase += 8.0;
            }
          }
        }

        double hIn = calcularIntervaloHoras(dAnt, tPrev, d, tAtual);
        double hOut = calcularIntervaloHoras(d, tAtual, dProx, tNext);

        double jornadaTotal = jornadaBase + horasExtrasTotal;

        if (jornadaTotal > 16.1) {
          alerts.add(_alertItem("❌ $prefixo Jornada: Excesso (${jornadaTotal.toStringAsFixed(1)}h).", Colors.red));
        } else if (jornadaTotal > 12.1) {
          alerts.add(_alertItem("⚠️ $prefixo Jornada: ${jornadaTotal.toStringAsFixed(1)}h (Acima do limite legal).", Colors.orange));
        } else if (jornadaTotal > 8.1) {
          alerts.add(_alertItem("ℹ️ $prefixo Jornada: ${jornadaTotal.toStringAsFixed(1)}h.", Colors.blue));
        }

        // Descanso entre turnos.
        if (hIn > 0.1 && hIn < 11.0) {
          alerts.add(_alertItem("⚠️ $prefixo Descanso: Apenas ${hIn.toStringAsFixed(1)}h em ${DateFormat('dd/MM').format(d)}.", corAlerta));
        } else if (hIn < -0.1) {
          alerts.add(_alertItem("❌ Erro: Sobreposição de jornada em ${DateFormat('dd/MM').format(d)}!", Colors.red));
        }

        if (hOut > 0.1 && hOut < 11.0) {
          alerts.add(_alertItem("⚠️ $prefixo Descanso: Apenas ${hOut.toStringAsFixed(1)}h após o turno em ${DateFormat('dd/MM').format(d)}.", corAlerta));
        }

        // Detecção de Dobra Crítica (Madrugada -> Manhã).
        bool isDobraIn = hIn <= 0.1 && hIn > -0.1 && tPrev != "F" && tAtual != "F";
        bool isDobraOut = hOut <= 0.1 && hOut > -0.1 && tAtual != "F" && tNext != "F";
        if ((isDobraIn && tPrev == "23" && tAtual == "7") || (isDobraOut && tAtual == "23" && tNext == "7")) {
          alerts.add(_alertItem("💤 Alerta de Fadiga: Dobrar da madrugada para o dia é extremamente exaustivo.", Colors.orange));
        }
      }
    }

    if (alerts.isEmpty) {
      alerts.add(_alertItem("✅ Troca viável para ambos conforme escalas projetadas.", Colors.green));
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Análise de Viabilidade (Escalas Projetadas):", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...alerts,
          ],
        ),
      ),
    );
  }

  /// Constrói um item de alerta no painel de inteligência.
  Widget _alertItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 8, color: color),
          ),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}
