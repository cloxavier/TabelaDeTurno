import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../notification_service.dart';
import '../local_storage_service.dart';
import '../rotinas.dart';

class TarefasScreen extends StatefulWidget {
  final DateTime data;
  final String turno;
  final String? editTaskId; // ID opcional para abrir direto em modo edição

  const TarefasScreen({super.key, required this.data, required this.turno, this.editTaskId});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _hasAlarm = false;
  int _antecedenciaMinutos = 0;
  bool _isSaving = false;
  
  List<Map<String, dynamic>> _tarefas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      if (widget.editTaskId != null) {
        final task = _tarefas.firstWhere((t) => t['id'] == widget.editTaskId, orElse: () => {});
        if (task.isNotEmpty) {
          _showAddDialog(task);
        }
      }
    });
  }

  Future<void> _loadData() async {
    final allTarefas = await LocalStorageService().loadTarefas();
    // Filtra as tarefas para o dia específico
    final filtered = allTarefas.where((t) {
      final date = DateTime.parse(t['date']);
      return date.year == widget.data.year &&
             date.month == widget.data.month &&
             date.day == widget.data.day;
    }).toList();
    
    setState(() {
      _tarefas = filtered;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciador de Tarefas"),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Tarefas para: ${DateFormat('dd/MM/yyyy').format(widget.data)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _tarefas.isEmpty
                ? const Center(child: Text("Nenhuma tarefa para este dia."))
                : ListView.builder(
                    itemCount: _tarefas.length,
                    itemBuilder: (context, index) {
                      final data = _tarefas[index];
                      final id = data['id'];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(data['title'] ?? ""),
                          subtitle: Text("${data['time']} - ${data['description']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showAddDialog(data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTarefa(id, data['notificationId']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(),
      ),
    );
  }

  void _showAddDialog([Map<String, dynamic>? editTask]) {
    if (editTask != null) {
      _tituloController.text = editTask['title'] ?? "";
      _descController.text = editTask['description'] ?? "";
      _hasAlarm = editTask['hasAlarm'] ?? false;
      _antecedenciaMinutos = editTask['antecedencia'] ?? 0;
      
      // Parse time
      try {
        final timeStr = editTask['time'] as String;
        final format = DateFormat.jm(); // generic am/pm format
        final dt = format.parse(timeStr);
        _selectedTime = TimeOfDay.fromDateTime(dt);
      } catch (e) {
        _selectedTime = TimeOfDay.now();
      }
    } else {
      _tituloController.clear();
      _descController.clear();
      _selectedTime = TimeOfDay.now();
      _hasAlarm = false;
      _antecedenciaMinutos = 0;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(editTask == null ? "Nova Tarefa" : "Editar Tarefa"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: _tituloController, decoration: const InputDecoration(labelText: "Título")),
                    TextField(controller: _descController, decoration: const InputDecoration(labelText: "Descrição")),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Hora: ${_selectedTime.format(context)}"),
                        TextButton(
                          onPressed: () async {
                            final time = await showTimePicker(context: context, initialTime: _selectedTime);
                            if (time != null) setDialogState(() => _selectedTime = time);
                          },
                          child: const Text("Alterar"),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text("Ativar Alarme"),
                      value: _hasAlarm,
                      onChanged: (val) => setDialogState(() => _hasAlarm = val),
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: _antecedenciaMinutos,
                      decoration: const InputDecoration(labelText: "Tocar alarme antes:"),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text("Na hora exata")),
                        DropdownMenuItem(value: 5, child: Text("5 minutos antes")),
                        DropdownMenuItem(value: 10, child: Text("10 minutos antes")),
                        DropdownMenuItem(value: 15, child: Text("15 minutos antes")),
                        DropdownMenuItem(value: 30, child: Text("30 minutos antes")),
                      ],
                      onChanged: (val) => setDialogState(() => _antecedenciaMinutos = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveTarefa(editTask?['id'], editTask?['notificationId']), 
                  child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Salvar")
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveTarefa(String? existingId, int? oldNotificationId) async {
    if (_tituloController.text.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      final String id = existingId ?? DateTime.now().millisecondsSinceEpoch.toString();
      final int notificationId = oldNotificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);
      
      final DateTime taskDateTime = DateTime(
        widget.data.year, widget.data.month, widget.data.day,
        _selectedTime.hour, _selectedTime.minute,
      );

      final DateTime alarmDateTime = taskDateTime.subtract(Duration(minutes: _antecedenciaMinutos));

      final novaTarefa = {
        'id': id,
        'title': _tituloController.text,
        'description': _descController.text,
        'date': DateTime(widget.data.year, widget.data.month, widget.data.day).toIso8601String(),
        'time': _selectedTime.format(context),
        'shift': widget.turno,
        'hasAlarm': _hasAlarm,
        'antecedencia': _antecedenciaMinutos,
        'notificationId': notificationId,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 1. Prioridade Máxima: Salvar no Disco
      final allTarefas = await LocalStorageService().loadTarefas();
      
      if (existingId != null) {
        final index = allTarefas.indexWhere((t) => t['id'] == existingId);
        if (index != -1) allTarefas[index] = novaTarefa;
      } else {
        allTarefas.add(novaTarefa);
      }

      await LocalStorageService().saveTarefas(allTarefas);
      await atualizarCache();

      // 2. Gerenciar notificações em bloco isolado para não interromper o salvamento
      try {
        if (oldNotificationId != null) {
          await NotificationService().cancelNotification(oldNotificationId);
        }

        if (_hasAlarm && alarmDateTime.isAfter(DateTime.now())) {
          String body = _descController.text;
          if (_antecedenciaMinutos > 0) {
            body = "Em $_antecedenciaMinutos min: $body";
          }
          await NotificationService().scheduleNotification(
            notificationId,
            _tituloController.text,
            body,
            alarmDateTime,
          );
        }
      } catch (notifErr) {
        debugPrint("⚠️ Aviso: Falha ao agendar alarme (Provável restrição do Android): $notifErr");
        // A tarefa já foi salva, apenas notificamos o erro silenciosamente ou via snackbar futuro.
      }

      // 3. Sucesso: Fecha a interface e recarrega a lista
      if (!mounted) return;
      Navigator.pop(context); 
      _loadData();
    } catch (e) {
      debugPrint("❌ Erro Crítico ao salvar tarefa: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao salvar. Verifique se há espaço no disco.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteTarefa(String id, int? notificationId) async {
    final allTarefas = await LocalStorageService().loadTarefas();
    allTarefas.removeWhere((t) => t['id'] == id);
    await LocalStorageService().saveTarefas(allTarefas);
    await atualizarCache();
    
    if (notificationId != null) {
      await NotificationService().cancelNotification(notificationId);
    }
    _loadData();
  }
}
