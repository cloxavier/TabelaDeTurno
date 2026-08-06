import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../rotinas.dart';
import '../local_storage_service.dart';
import 'event_screens.dart';

class ListaTrocasDiaScreen extends StatefulWidget {
  final DateTime data;
  final String turno;
  const ListaTrocasDiaScreen({super.key, required this.data, required this.turno});

  @override
  State<ListaTrocasDiaScreen> createState() => _ListaTrocasDiaScreenState();
}

class _ListaTrocasDiaScreenState extends State<ListaTrocasDiaScreen> {
  List<Map<String, dynamic>> _trocas = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  /// Inicializa os dados da tela garantindo que o cache global esteja sincronizado
  /// com o armazenamento físico. Isso resolve problemas de trocas recém-criadas
  /// ou importadas que não apareciam imediatamente.
  Future<void> _initData() async {
    await atualizarCache();
    _refresh();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _trocas = getTodasTrocasNoDia(widget.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trocas: ${DateFormat('dd/MM').format(widget.data)}"),
        backgroundColor: Colors.orange,
      ),
      body: _trocas.isEmpty
          ? const Center(child: Text("Nenhuma troca para este dia."))
          : ListView.builder(
              itemCount: _trocas.length,
              itemBuilder: (context, index) {
                final t = _trocas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
                    title: Text("Com: ${t['parceiroNome']}"),
                    subtitle: Text("Turno dele: ${t['horarioParceiroOriginal']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.blue),
                          tooltip: "Compartilhar com colega",
                          onPressed: () => LocalStorageService().shareSingleExchange(t, DateFormat('yyyy-MM-dd').format(widget.data)),
                        ),
                        const Icon(Icons.edit, color: Colors.blue),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrocasScreen(
                            data: widget.data,
                            turno: widget.turno,
                            editSwapId: t['id'],
                          ),
                        ),
                      ).then((_) => _refresh());
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrocasScreen(data: widget.data, turno: widget.turno),
            ),
          ).then((_) => _refresh());
        },
      ),
    );
  }
}
