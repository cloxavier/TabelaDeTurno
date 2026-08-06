import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../rotinas.dart';
import '../local_storage_service.dart';
import 'event_screens.dart';

class ListaHorasExtrasDiaScreen extends StatefulWidget {
  final DateTime data;
  final String turno;
  const ListaHorasExtrasDiaScreen({super.key, required this.data, required this.turno});

  @override
  State<ListaHorasExtrasDiaScreen> createState() => _ListaHorasExtrasDiaScreenState();
}

class _ListaHorasExtrasDiaScreenState extends State<ListaHorasExtrasDiaScreen> {
  List<Map<String, dynamic>> _extras = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _extras = getTodasHorasExtrasNoDia(widget.data);
    });
  }

  Future<void> _delete(String id) async {
    await LocalStorageService().deleteEvento(DateFormat('yyyy-MM-dd').format(widget.data), "hora_extra", id: id);
    await atualizarCache();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Extras: ${DateFormat('dd/MM').format(widget.data)}"),
        backgroundColor: Colors.orange,
      ),
      body: _extras.isEmpty
          ? const Center(child: Text("Nenhuma hora extra para este dia."))
          : ListView.builder(
              itemCount: _extras.length,
              itemBuilder: (context, index) {
                final e = _extras[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.add_alarm, color: Colors.white)),
                    title: Text("${e['horas']} Horas"),
                    subtitle: Text(e['obs'] ?? ""),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HoraExtraScreen(
                                  data: widget.data,
                                  turno: widget.turno,
                                  editExtraId: e['id'],
                                ),
                              ),
                            ).then((_) => _refresh());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(e['id']),
                        ),
                      ],
                    ),
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
              builder: (context) => HoraExtraScreen(data: widget.data, turno: widget.turno),
            ),
          ).then((_) => _refresh());
        },
      ),
    );
  }
}
