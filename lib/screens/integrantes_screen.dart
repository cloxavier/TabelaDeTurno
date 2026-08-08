import 'package:flutter/material.dart';
import '../local_storage_service.dart';
import '../models/integrante.dart';
import '../dados.dart';

class IntegrantesScreen extends StatefulWidget {
  const IntegrantesScreen({super.key});

  @override
  State<IntegrantesScreen> createState() => _IntegrantesScreenState();
}

class _IntegrantesScreenState extends State<IntegrantesScreen> with SingleTickerProviderStateMixin {
  List<Integrante> _integrantes = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: numeroDeGrupos, vsync: this);
    _loadIntegrantes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadIntegrantes() async {
    try {
      final data = await LocalStorageService().loadIntegrantes();
      if (!mounted) return;
      setState(() {
        _integrantes = data.map((e) => Integrante.fromMap(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar integrantes: $e")),
      );
    }
  }

  Future<void> _saveIntegrantes() async {
    await LocalStorageService().saveIntegrantes(_integrantes.map((e) => e.toMap()).toList());
  }

  void _addOrEditIntegrante([Integrante? integrante]) {
    final nomeController = TextEditingController(text: integrante?.nome);
    final cargoController = TextEditingController(text: integrante?.cargo);
    final telefoneController = TextEditingController(text: integrante?.telefone);
    
    // Se for novo, usa o grupo da aba atual. Se for edição, usa o grupo do integrante.
    String selectedGrupo = integrante?.grupo ?? String.fromCharCode(97 + _tabController.index);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(integrante == null ? "Adicionar Integrante" : "Editar Integrante"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nomeController, decoration: const InputDecoration(labelText: "Nome")),
                    TextField(controller: cargoController, decoration: const InputDecoration(labelText: "Cargo")),
                    TextField(controller: telefoneController, decoration: const InputDecoration(labelText: "Telefone (Opcional)"), keyboardType: TextInputType.phone),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedGrupo,
                      decoration: const InputDecoration(labelText: "Grupo"),
                      items: ['a', 'b', 'c', 'd', 'e', 'f'].sublist(0, numeroDeGrupos).map((g) {
                        return DropdownMenuItem(value: g, child: Text("Grupo ${g.toUpperCase()}"));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedGrupo = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                ElevatedButton(
                  onPressed: () {
                    if (nomeController.text.isEmpty || cargoController.text.isEmpty) return;
                    
                    final newIntegrante = Integrante(
                      id: integrante?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      nome: nomeController.text,
                      cargo: cargoController.text,
                      grupo: selectedGrupo,
                      telefone: telefoneController.text.isEmpty ? null : telefoneController.text,
                    );

                    setState(() {
                      if (integrante == null) {
                        _integrantes.add(newIntegrante);
                      } else {
                        final index = _integrantes.indexWhere((e) => e.id == integrante.id);
                        _integrantes[index] = newIntegrante;
                      }
                    });
                    _saveIntegrantes();
                    Navigator.pop(context);
                  },
                  child: const Text("Salvar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Integrantes dos Grupos"),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: ['A', 'B', 'C', 'D', 'E', 'F'].sublist(0, numeroDeGrupos).map((g) => Tab(text: "Grupo $g")).toList(),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _integrantes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_add, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text("Nenhum integrante cadastrado.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const Text("Clique no botão + para adicionar.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : TabBarView(
            controller: _tabController,
            children: ['a', 'b', 'c', 'd', 'e', 'f'].sublist(0, numeroDeGrupos).map((g) {
              final list = _integrantes.where((i) => i.grupo == g).toList();
                return list.isEmpty 
                  ? Center(child: Text("Nenhum integrante no Grupo ${g.toUpperCase()}"))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          child: ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            leading: CircleAvatar(child: Text(item.nome[0])),
                            title: Text(item.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${item.cargo}${item.telefone != null ? ' - ${item.telefone}' : ''}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20), 
                                  onPressed: () => _addOrEditIntegrante(item)
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20), 
                                  onPressed: () {
                                    setState(() => _integrantes.removeWhere((e) => e.id == item.id));
                                    _saveIntegrantes();
                                  }
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
              }).toList(),
            ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () => _addOrEditIntegrante(),
          child: const Icon(Icons.add),
        ),
    );
  }
}
