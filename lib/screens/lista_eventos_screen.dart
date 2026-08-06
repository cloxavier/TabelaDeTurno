import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../local_storage_service.dart';
import '../rotinas.dart';
import 'event_screens.dart';
import 'tarefas_screen.dart';

/// Tela centralizadora de todos os lançamentos do usuário.
/// Agrega tarefas e eventos (trocas, folgas, etc.) em uma lista cronológica 
/// com suporte a filtragem por categorias e ações rápidas.
class ListaEventosScreen extends StatefulWidget {
  const ListaEventosScreen({super.key});

  @override
  State<ListaEventosScreen> createState() => _ListaEventosScreenState();
}

class _ListaEventosScreenState extends State<ListaEventosScreen> {
  // Lista unificada que armazena diferentes tipos de modelos de dados.
  List<Map<String, dynamic>> _todosLancamentos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final List<Map<String, dynamic>> combined = [];

    try {
      // 1. Carregar Tarefas
      final tarefas = await LocalStorageService().loadTarefas();
      for (var t in tarefas) {
        combined.add({
          ...t,
          'tipo_slug': 'tarefa',
          'tipo_display': 'Tarefa',
          'icone': Icons.task_alt,
          'cor': Colors.orange,
          'data_ordem': DateTime.parse(t['date']),
        });
      }

      // 2. Carregar Eventos (Trocas, Horas Extras, Férias)
      final eventos = await LocalStorageService().loadEventos();
      eventos.forEach((dateKey, value) {
        DateTime dt;
        try {
          dt = DateTime.parse(dateKey);
        } catch (e) {
          return; // Ignora chaves de data inválidas
        }

        Map<String, dynamic> evs = value as Map<String, dynamic>;
        
        evs.forEach((tipo, data) {
          String display = "Evento Desconhecido";
          IconData icone = Icons.help_outline;
          Color cor = Colors.grey;

          if (tipo == "hora_extra") {
            display = "Hora Extra";
            icone = Icons.add_alarm;
            cor = Colors.green;
          } else if (tipo == "ferias") {
            display = "Férias";
            icone = Icons.beach_access;
            cor = Colors.purple;
          } else if (tipo == "troca") {
            display = "Troca";
            icone = Icons.swap_horiz;
            cor = Colors.blue;
          } else if (tipo == "festa") {
            display = "Evento Antigo (Festa)";
            icone = Icons.celebration;
            cor = Colors.grey;
          }

          if ((tipo == "troca" || tipo == "hora_extra") && data is List) {
            for (var item in data) {
              combined.add({
                ...(item is Map ? item : {}),
                'tipo_slug': tipo,
                'date_key': dateKey,
                'tipo_display': display,
                'icone': icone,
                'cor': cor,
                'data_ordem': dt,
              });
            }
          } else {
            combined.add({
              ...(data is Map ? data : {}),
              'tipo_slug': tipo,
              'date_key': dateKey,
              'tipo_display': display,
              'icone': icone,
              'cor': cor,
              'data_ordem': dt,
            });
          }
        });
      });

      // Ordenar por data decrescente
      combined.sort((a, b) => (b['data_ordem'] as DateTime).compareTo(a['data_ordem'] as DateTime));
    } catch (e) {
      debugPrint("Erro ao carregar lançamentos: $e");
    }

    setState(() {
      _todosLancamentos = combined;
      _isLoading = false;
    });
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Lançamento?"),
        content: const Text("Esta ação não pode ser desfeita."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCELAR")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("EXCLUIR", style: TextStyle(color: Colors.red))),
        ],
      )
    );

    if (confirm == true) {
      if (item['tipo_slug'] == 'tarefa') {
        final all = await LocalStorageService().loadTarefas();
        all.removeWhere((element) => element['id'] == item['id']);
        await LocalStorageService().saveTarefas(all);
      } else {
        await LocalStorageService().deleteEvento(
          item['date_key'], 
          item['tipo_slug'], 
          id: item['id']
        );
      }
      await atualizarCache();
      _loadAll();
    }
  }

  void _edit(Map<String, dynamic> item) {
    Widget? screen;
    DateTime dt = item['data_ordem'];

    if (item['tipo_slug'] == 'tarefa') {
      screen = TarefasScreen(data: dt, turno: item['shift'] ?? "", editTaskId: item['id']);
    } else if (item['tipo_slug'] == 'hora_extra') {
      screen = HoraExtraScreen(data: dt, turno: "", editExtraId: item['id']);
    } else if (item['tipo_slug'] == 'ferias') {
      screen = FeriasScreen(data: dt, turno: "");
    } else if (item['tipo_slug'] == 'troca') {
      screen = TrocasScreen(data: dt, turno: "", editSwapId: item['id']);
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen!)).then((_) => _loadAll());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Este tipo de evento não pode mais ser editado. Por favor, exclua-o.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Meus Lançamentos"),
          backgroundColor: Colors.orange,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Tudo", icon: Icon(Icons.list)),
              Tab(text: "Trocas", icon: Icon(Icons.swap_horiz)),
              Tab(text: "Horas Extras", icon: Icon(Icons.add_alarm)),
              Tab(text: "Férias", icon: Icon(Icons.beach_access)),
              Tab(text: "Tarefas", icon: Icon(Icons.task_alt)),
            ],
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              children: [
                _buildList(_todosLancamentos),
                _buildList(_todosLancamentos.where((i) => i['tipo_slug'] == 'troca').toList()),
                _buildList(_todosLancamentos.where((i) => i['tipo_slug'] == 'hora_extra').toList()),
                _buildList(_todosLancamentos.where((i) => i['tipo_slug'] == 'ferias').toList()),
                _buildList(_todosLancamentos.where((i) => i['tipo_slug'] == 'tarefa').toList()),
              ],
            ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(child: Text("Nenhum lançamento nesta categoria."));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        String subtitle = "";
        
        if (item['tipo_slug'] == 'tarefa') {
          subtitle = "${item['time']} - ${item['title']}";
        } else if (item['tipo_slug'] == 'hora_extra') {
          subtitle = "${item['horas']} horas registradas";
        } else if (item['tipo_slug'] == 'troca') {
          subtitle = "Colaborador: ${item['parceiroNome'] ?? 'N/A'}";
        } else if (item['tipo_slug'] == 'ferias') {
          String fim = item['dataFim'] ?? "";
          subtitle = fim.isNotEmpty ? "Até ${DateFormat('dd/MM/yyyy').format(DateTime.parse(fim))}" : "";
        } else {
          subtitle = "Registro antigo ou incompleto.";
        }

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: item['cor'].withOpacity(0.15),
              child: Icon(item['icone'], color: item['cor']),
            ),
            title: Text(
              "${item['tipo_display']} - ${DateFormat('dd/MM/yyyy').format(item['data_ordem'])}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Adiciona botão de compartilhamento especificamente para Trocas
                if (item['tipo_slug'] == 'troca')
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.blue),
                    onPressed: () => LocalStorageService().shareSingleExchange(
                      item, 
                      DateFormat('yyyy-MM-dd').format(item['data_ordem'])
                    ),
                    tooltip: "Compartilhar com colega",
                  ),
                if (item['tipo_slug'] != 'festa')
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _edit(item),
                    tooltip: "Editar",
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _delete(item),
                  tooltip: "Excluir",
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
