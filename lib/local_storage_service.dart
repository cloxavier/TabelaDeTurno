import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'rotinas.dart';
import 'dados.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  // Nomes dos arquivos
  static const String _tarefasFile = "tarefas";
  static const String _eventosFile = "eventos";
  static const String _integrantesFile = "integrantes";

  // --- TAREFAS ---

  Future<List<Map<String, dynamic>>> loadTarefas() async {
    String data = await leArquivo(arquivo: _tarefasFile);
    if (data.isEmpty) return [];
    try {
      List<dynamic> list = json.decode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTarefas(List<Map<String, dynamic>> tarefas) async {
    await salvaArquivo(arquivo: _tarefasFile, dados: tarefas);
  }

  // --- EVENTOS (Férias, Trocas, etc.) ---

  Future<Map<String, dynamic>> loadEventos() async {
    String data = await leArquivo(arquivo: _eventosFile);
    if (data.isEmpty) return {};
    try {
      Map<String, dynamic> todos = json.decode(data) as Map<String, dynamic>;
      
      bool changed = false;
      todos.forEach((dateKey, events) {
        if (events is Map) {
          // Migração: Se "troca" existe mas não é uma lista, converte para lista
          if (events.containsKey("troca") && events["troca"] is! List) {
            var oldTroca = events["troca"];
            if (oldTroca != null) {
              if (oldTroca is Map && !oldTroca.containsKey("id")) {
                oldTroca["id"] = "legacy_${DateTime.now().millisecondsSinceEpoch}";
              }
              events["troca"] = [oldTroca];
              changed = true;
            }
          }

          // Migração: Se "hora_extra" existe mas não é uma lista, converte para lista
          if (events.containsKey("hora_extra") && events["hora_extra"] is! List) {
            var oldExtra = events["hora_extra"];
            if (oldExtra != null) {
              if (oldExtra is Map && !oldExtra.containsKey("id")) {
                oldExtra["id"] = "he_legacy_${DateTime.now().millisecondsSinceEpoch}";
              }
              events["hora_extra"] = [oldExtra];
              changed = true;
            }
          }
          
          if (events.containsKey("festa")) {
            events.remove("festa");
            changed = true;
          }
        }
      });
      if (changed) {
        todos.removeWhere((key, value) => (value as Map).isEmpty);
        await saveEventos(todos);
      }
      return todos;
    } catch (e) {
      return {};
    }
  }

  Future<void> saveEventos(Map<String, dynamic> eventos) async {
    String data = json.encode(eventos);
    final file = await getCaminhoArquivo(arquivo: _eventosFile);
    await file.writeAsString(data);
  }

  Future<void> deleteEvento(String dateKey, String type, {String? id}) async {
    Map<String, dynamic> todos = await loadEventos();
    if (todos.containsKey(dateKey)) {
      Map<String, dynamic> evs = todos[dateKey] as Map<String, dynamic>;
      
      if ((type == "troca" || type == "hora_extra") && id != null) {
        // Remove um item específico da lista
        if (evs.containsKey(type)) {
          List<dynamic> items = List.from(evs[type]);
          items.removeWhere((t) => t["id"] == id);
          if (items.isEmpty) {
            evs.remove(type);
          } else {
            evs[type] = items;
          }
        }
      } else {
        // Remove o tipo inteiro (Férias)
        evs.remove(type);
      }

      if (evs.isEmpty) {
        todos.remove(dateKey);
      } else {
        todos[dateKey] = evs;
      }
      await saveEventos(todos);
    }
  }

  Future<void> saveEventoParaData(String dateKey, String type, Map<String, dynamic> eventData) async {
    Map<String, dynamic> todosEventos = await loadEventos();
    
    // Cleanup preventivo
    todosEventos.removeWhere((key, value) => value == null || (value is Map && value.isEmpty));
    
    if (!todosEventos.containsKey(dateKey)) {
      todosEventos[dateKey] = {};
    }

    if (type == "troca" || type == "hora_extra") {
      // Gerencia lista de eventos (Trocas ou Horas Extras)
      List<dynamic> items = [];
      if (todosEventos[dateKey].containsKey(type)) {
        items = List.from(todosEventos[dateKey][type]);
      }

      // Se o item já tem um ID, é uma edição. Se não, é novo.
      String? targetId = eventData["id"];
      if (targetId != null) {
        int idx = items.indexWhere((t) => t["id"] == targetId);
        if (idx != -1) {
          items[idx] = eventData;
        } else {
          items.add(eventData);
        }
      } else {
        // Gera um ID novo se não existir
        String prefix = type == "troca" ? "tr" : "he";
        eventData["id"] = "${prefix}_${DateTime.now().millisecondsSinceEpoch}";
        items.add(eventData);
      }
      todosEventos[dateKey][type] = items;
    } else {
      // Tipos únicos (Férias)
      todosEventos[dateKey][type] = eventData;
    }

    await saveEventos(todosEventos);
  }

  Future<Map<String, dynamic>?> getEventoPorData(String dateKey, String type, {String? id}) async {
    Map<String, dynamic> todosEventos = await loadEventos();
    if (todosEventos.containsKey(dateKey) && todosEventos[dateKey].containsKey(type)) {
      var data = todosEventos[dateKey][type];
      if ((type == "troca" || type == "hora_extra") && data is List) {
        if (id != null) {
          return data.firstWhere((t) => t["id"] == id, orElse: () => null) as Map<String, dynamic>?;
        }
        return data.isNotEmpty ? data.first as Map<String, dynamic> : null;
      }
      return data as Map<String, dynamic>;
    }
    return null;
  }

  // --- INTEGRANTES ---

  Future<List<Map<String, dynamic>>> loadIntegrantes() async {
    String data = await leArquivo(arquivo: _integrantesFile);
    if (data.isEmpty) return [];
    try {
      List<dynamic> list = json.decode(data);
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveIntegrantes(List<Map<String, dynamic>> integrantes) async {
    await salvaArquivo(arquivo: _integrantesFile, dados: integrantes);
  }

  // --- BACKUP & COMPARTILHAMENTO ---

  /// Retorna o prefixo do arquivo baseado no nome do usuário ou padrão
  String _getFilePrefix() {
    return nomeUsuario.isNotEmpty ? "TabelaTurno_${nomeUsuario.replaceAll(' ', '_')}" : "TabelaTurno";
  }

  /// Compartilha uma troca específica como um "Convite de Troca" para um colega.
  /// 
  /// O [package] gerado contém metadados que permitem ao destinatário realizar a 
  /// inversão automática de papéis ao importar o arquivo.
  Future<void> shareSingleExchange(Map<String, dynamic> exchangeData, String dateKey) async {
    // Determina o grupo do remetente para inclusão no pacote.
    final String myGroup = grupos[grupos.indexWhere((g) => grupo[g.toLowerCase()] == grupoAtual)];
    
    Map<String, dynamic> package = {
      "type": "exchange_invite",
      "version": 1,
      "senderGroup": myGroup,
      "dateKey": dateKey,
      "data": exchangeData,
    };

    String jsonString = json.encode(package);
    final tempDir = await getTemporaryDirectory();
    final String groupLabel = exchangeData["grupoParceiro"]?.toString().toUpperCase() ?? "X";
    final String prefix = _getFilePrefix();
    final file = File('${tempDir.path}/${prefix}_Troca_${dateKey}_Grupo$groupLabel.json');
    await file.writeAsString(jsonString);

    // Texto amigável para o WhatsApp
    String userIdText = nomeUsuario.isNotEmpty ? "*Remetente*: $nomeUsuario\n" : "";
    String compensationText = exchangeData['dataCompensacao'] != null 
        ? "\n🔄 *Compensação*: ${dataIsoParaLocal(exchangeData['dataCompensacao'].toString().substring(0, 10))}" 
        : "";

    String friendlyText = "🤝 *Convite de Troca de Turno*\n\n"
        "Oi! Registrei nossa troca no app:\n"
        "$userIdText"
        "📅 *Trabalho*: ${dataIsoParaLocal(dateKey)}$compensationText\n"
        "🔄 *Meu Grupo*: $myGroup\n"
        "👤 *Colaborador*: ${exchangeData['parceiroNome']}\n\n"
        "Segue o arquivo anexo para você importar no seu aplicativo e atualizar sua escala automaticamente!";

    await Share.shareXFiles(
      [XFile(file.path)],
      text: friendlyText,
    );
  }

  /// Cria um backup completo em um único objeto JSON
  Future<Map<String, dynamic>> createFullBackupData() async {
    List<Map<String, dynamic>> tarefas = await loadTarefas();
    Map<String, dynamic> eventos = await loadEventos();
    List<Map<String, dynamic>> integrantes = await loadIntegrantes();
    String prefData = await leArquivo(arquivo: "preferencias");
    dynamic prefs = prefData.isNotEmpty ? json.decode(prefData) : null;

    return {
      "version": 2, // Incremented version
      "exportDate": DateTime.now().toIso8601String(),
      "data": {
        "tarefas": tarefas,
        "eventos": eventos,
        "integrantes": integrantes,
        "preferencias": prefs,
        "grupoAtual": grupoAtual,
        "numeroDeGrupos": numeroDeGrupos,
      }
    };
  }

  /// Compartilha o backup completo via Share do sistema
  Future<void> shareFullBackup() async {
    Map<String, dynamic> backup = await createFullBackupData();
    String jsonString = json.encode(backup);
    
    final tempDir = await getTemporaryDirectory();
    String dateSuffix = DateFormat('yyyyMMdd').format(DateTime.now());
    final String prefix = _getFilePrefix();
    final file = File('${tempDir.path}/${prefix}_Backup_Total_$dateSuffix.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)]);
  }

  /// Compartilha as configurações de interface e o grupo de trabalho favorito.
  /// Ideal para padronizar o uso do aplicativo entre membros da mesma equipe.
  Future<void> shareAppSetup() async {
    String prefData = await leArquivo(arquivo: "preferencias");
    dynamic prefs = prefData.isNotEmpty ? json.decode(prefData) : null;
    
    Map<String, dynamic> package = {
      "type": "app_setup",
      "version": 1,
      "preferences": prefs,
      "grupoAtual": grupoAtual,
      "numeroDeGrupos": numeroDeGrupos,
    };
    
    String jsonString = json.encode(package);
    final tempDir = await getTemporaryDirectory();
    final String prefix = _getFilePrefix();
    final file = File('${tempDir.path}/${prefix}_Config_App.json');
    await file.writeAsString(jsonString);

    String shareText = nomeUsuario.isNotEmpty ? "Configurações do App de $nomeUsuario" : "Minhas configurações do App Tabela de Turno";
    await Share.shareXFiles([XFile(file.path)], text: shareText);
  }

  /// Restaura dados a partir de um arquivo JSON selecionado pelo usuário.
  /// Implementa o Preview de Importação e detecção de diferentes tipos de pacotes.
  Future<bool> importData(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      try {
        Map<String, dynamic> package = json.decode(content);
        
        // --- CASO 1: Convite de Troca Única ---
        if (package["type"] == "exchange_invite") {
          if (!context.mounted) return false;
          return await _showExchangeInvitePreview(context, package);
        }
        
        // --- CASO 2: Backup Geral (Dados + Configurações) ---
        if (package.containsKey("data")) {
          if (!context.mounted) return false;
          return await _showBackupPreview(context, package);
        }

        // --- CASO 3: Grupos Selecionados ---
        if (package["type"] == "selective_groups" || package["type"] == "work_groups_and_people") {
          if (!context.mounted) return false;
          return await _showSelectiveGroupsPreview(context, package);
        }

        // --- CASO 4: Setup do App ---
        if (package["type"] == "app_setup") {
          if (!context.mounted) return false;
          return await _showAppSetupPreview(context, package);
        }
        
        throw Exception("Este arquivo não é um formato de dados reconhecido pelo aplicativo.");
      } catch (e) {
        throw Exception("Erro ao processar o arquivo: $e");
      }
    }
    return false;
  }

  /// Processa um JSON vindo de fora do aplicativo (ex: clicado no WhatsApp).
  /// Realiza uma validação rigorosa de "DNA" para garantir a segurança dos dados.
  Future<void> handleExternalJson(BuildContext context, String jsonContent) async {
    debugPrint("📥 Processando JSON externo...");
    try {
      Map<String, dynamic> package = json.decode(jsonContent);
      debugPrint("📦 Pacote decodificado. Tipo detectado: ${package["type"]}");
      
      // Validação de DNA: O arquivo deve conter o campo 'type' conhecido ou a chave 'data' de backup.
      bool isValid = false;
      if (package.containsKey("type")) {
        final String type = package["type"];
        if (["exchange_invite", "selective_groups", "work_groups_and_people", "app_setup"].contains(type)) {
          isValid = true;
        }
      } else if (package.containsKey("data") && package.containsKey("version")) {
        // Provável backup completo
        isValid = true;
      }

      if (!isValid) {
        debugPrint("❌ Validação de DNA falhou.");
        throw Exception("O arquivo não possui uma assinatura digital válida da Tabela de Turno.");
      }

      if (!context.mounted) {
        debugPrint("⚠️ Contexto não montado, abortando diálogo.");
        return;
      }

      debugPrint("✅ DNA válido. Abrindo diálogo de preview para tipo: ${package["type"] ?? 'Backup'}");

      // Encaminha para os mesmos diálogos de preview que o botão "Importar" utiliza.
      if (package["type"] == "exchange_invite") {
        await _showExchangeInvitePreview(context, package);
      } else if (package.containsKey("data")) {
        await _showBackupPreview(context, package);
      } else if (package["type"] == "selective_groups" || package["type"] == "work_groups_and_people") {
        await _showSelectiveGroupsPreview(context, package);
      } else if (package["type"] == "app_setup") {
        await _showAppSetupPreview(context, package);
      }
      
    } catch (e) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("Arquivo Inválido"),
            ],
          ),
          content: Text(
            "O arquivo selecionado não é um formato de dados reconhecido pelo Tabela de Turno ou está corrompido.\n\n"
            "Erro técnico: ${e.toString().replaceAll("Exception: ", "")}"
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("ENTENDI")),
          ],
        ),
      );
    }
  }

  /// Mostra um Preview antes de importar uma troca de um colega.
  Future<bool> _showExchangeInvitePreview(BuildContext context, Map<String, dynamic> package) async {
    final String senderGroup = package["senderGroup"];
    final String dateKey = package["dateKey"];
    final Map<String, dynamic> exchangeData = package["data"];
    
    // Detecta se o destinatário é o colaborador mencionado na troca
    final String myGroup = grupos[grupos.indexWhere((g) => grupo[g.toLowerCase()] == grupoAtual)];
    bool isReciprocal = (exchangeData["grupoParceiro"].toString().toUpperCase() == myGroup);

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Convite de Troca Recebido"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🗓️ Data: ${dataIsoParaLocal(dateKey)}"),
            Text("👤 Remetente: Grupo $senderGroup"),
            Text("👥 Colaborador Original: ${exchangeData['parceiroNome']}"),
            const SizedBox(height: 15),
            if (isReciprocal)
              const Card(
                color: Colors.greenAccent,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("✅ Identificamos que este convite é para o SEU grupo! Se aceitar, a troca será invertida para sua escala."),
                ),
              )
            else
              const Card(
                color: Colors.orangeAccent,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("⚠️ Este convite parece ser para outro grupo. Deseja importar mesmo assim?"),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(isReciprocal ? "ACEITAR E INVERTER" : "IMPORTAR"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Map<String, dynamic> finalData = Map.from(exchangeData);
      String finalDateKey = dateKey;
      
      if (isReciprocal) {
        // --- LÓGICA DE INVERSÃO INTELIGENTE ---
        // Quando um convite é recíproco, os papéis devem ser trocados:
        // 1. O remetente do convite passa a ser o 'parceiro' de quem recebe.
        // 2. A data em que o remetente trabalha passa a ser a data em que o 
        //    destinatário recebe o benefício (folga).
        // 3. A data de compensação é invertida para refletir a nova escala.
        
        finalData["parceiroNome"] = "Colega do Grupo $senderGroup"; 
        finalData["grupoParceiro"] = senderGroup.toLowerCase();
        
        if (exchangeData["dataCompensacao"] != null) {
          finalData["dataTrabalho"] = exchangeData["dataCompensacao"];
          finalData["dataCompensacao"] = exchangeData["dataTrabalho"];
          finalDateKey = exchangeData["dataCompensacao"].toString().substring(0, 10);
        } else {
          finalData["dataTrabalho"] = exchangeData["dataTrabalho"];
        }
      }

      await saveEventoParaData(finalDateKey, "troca", finalData);
      return true;
    }
    return false;
  }

  /// Mostra um Preview antes de restaurar um Backup Geral.
  /// Detalha a presença de configurações de sistema no pacote.
  Future<bool> _showBackupPreview(BuildContext context, Map<String, dynamic> package) async {
    Map<String, dynamic> data = package["data"];
    int tarefasCount = (data["tarefas"] as List?)?.length ?? 0;
    int eventosCount = (data["eventos"] as Map?)?.length ?? 0;
    int integrantesCount = (data["integrantes"] as List?)?.length ?? 0;
    bool hasSettings = data.containsKey("preferencias");

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Preview do Backup"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Deseja substituir seus dados atuais pelos seguintes itens do backup?"),
            const SizedBox(height: 10),
            Text("📝 Tarefas: $tarefasCount"),
            Text("📅 Dias com Eventos: $eventosCount"),
            Text("👥 Integrantes: $integrantesCount"),
            if (hasSettings)
              const Text("⚙️ Inclui Configurações de Interface"),
            const SizedBox(height: 15),
            const Text("⚠️ ATENÇÃO: Seus dados atuais serão apagados!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("RESTAURAR TUDO"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (data.containsKey("tarefas")) {
        await saveTarefas((data["tarefas"] as List).cast<Map<String, dynamic>>());
      }
      if (data.containsKey("eventos")) {
        await saveEventos(data["eventos"] as Map<String, dynamic>);
      }
      if (data.containsKey("integrantes")) {
        await saveIntegrantes((data["integrantes"] as List).cast<Map<String, dynamic>>());
      }
      if (data.containsKey("preferencias")) {
        await salvaArquivo(arquivo: "preferencias", dados: data["preferencias"]);
      }
      if (data.containsKey("grupoAtual")) {
        grupoAtual = data["grupoAtual"];
      }
      if (data.containsKey("numeroDeGrupos")) {
        numeroDeGrupos = data["numeroDeGrupos"];
      }
      return true;
    }
    return false;
  }

  /// Mostra um Preview antes de importar grupos e integrantes selecionados.
  Future<bool> _showSelectiveGroupsPreview(BuildContext context, Map<String, dynamic> package) async {
    List<dynamic> groupLetters = package["selectedGroups"] ?? [];
    List<dynamic> integrantes = package["integrantes"] ?? [];

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Importar Equipe"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Grupos: ${groupLetters.join(', ').toUpperCase()}"),
            Text("Integrantes a importar: ${integrantes.length}"),
            const SizedBox(height: 10),
            const Text("⚠️ Isso adicionará os novos integrantes à sua lista atual."),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("IMPORTAR"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      List<Map<String, dynamic>> current = await loadIntegrantes();
      
      // Evita duplicatas básicas por nome no mesmo grupo
      for (var novo in integrantes) {
        bool exists = current.any((i) => 
          i["nome"] == novo["nome"] && i["grupo"] == novo["grupo"]);
        if (!exists) {
          current.add(Map<String, dynamic>.from(novo));
        }
      }

      await saveIntegrantes(current);
      return true;
    }
    return false;
  }

  /// Mostra um Preview antes de importar apenas o Setup do App.
  Future<bool> _showAppSetupPreview(BuildContext context, Map<String, dynamic> package) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Importar Setup do App"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Deseja aplicar as seguintes configurações recebidas?"),
            SizedBox(height: 10),
            Text("• Tema (Claro/Escuro)"),
            Text("• Layout e Botões"),
            Text("• Grupo de Trabalho Favorito"),
            Text("• Página Inicial padrão"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("APLICAR"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (package.containsKey("preferences")) {
        await salvaArquivo(arquivo: "preferencias", dados: package["preferences"]);
      }
      if (package.containsKey("grupoAtual")) {
        grupoAtual = package["grupoAtual"];
      }
      if (package.containsKey("numeroDeGrupos")) {
        numeroDeGrupos = package["numeroDeGrupos"];
      }
      return true;
    }
    return false;
  }

  /// Compartilha grupos selecionados via Arquivo ou Texto Visual.
  /// 
  /// Esta função é o motor do compartilhamento seletivo, filtrando integrantes
  /// pelo grupo antes de gerar o pacote de exportação.
  Future<void> shareSelectedGroups({required List<String> groupLetters, required bool isJson}) async {
    if (isJson) {
      List<Map<String, dynamic>> allIntegrantes = await loadIntegrantes();
      List<Map<String, dynamic>> filtrados = allIntegrantes
          .where((i) => groupLetters.contains(i["grupo"].toString().toLowerCase()))
          .toList();

      Map<String, dynamic> data = {
        "type": "selective_groups",
        "version": 1,
        "selectedGroups": groupLetters,
        "integrantes": filtrados,
      };

      String jsonString = json.encode(data);
      final tempDir = await getTemporaryDirectory();
      String groupsLabel = groupLetters.join('').toUpperCase();
      final String prefix = _getFilePrefix();
      final file = File('${tempDir.path}/${prefix}_Equipe_$groupsLabel.json');
      await file.writeAsString(jsonString);

      String shareText = nomeUsuario.isNotEmpty ? "Dados de equipe enviados por $nomeUsuario" : "Dados de equipe do App Tabela de Turno";
      await Share.shareXFiles([XFile(file.path)], text: shareText);
    } else {
      String text = await gerarTextoEquipe(groupLetters);
      if (nomeUsuario.isNotEmpty) {
        text = "👤 *Enviado por*: $nomeUsuario\n\n$text";
      }
      await Share.share(text);
    }
  }
}
