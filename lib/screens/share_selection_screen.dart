import 'package:flutter/material.dart';
import '../dados.dart';
import '../local_storage_service.dart';

/// Tela para seleção e compartilhamento seletivo de grupos de turno.
/// Permite ao usuário escolher quais grupos deseja exportar, facilitando o 
/// envio de dados parciais da equipe tanto em formato técnico quanto visual.
class ShareSelectionScreen extends StatefulWidget {
  const ShareSelectionScreen({super.key});

  @override
  State<ShareSelectionScreen> createState() => _ShareSelectionScreenState();
}

class _ShareSelectionScreenState extends State<ShareSelectionScreen> {
  // Mapa para gerenciar o estado da seleção de cada grupo.
  final Map<String, bool> _selectedGroups = {};

  @override
  void initState() {
    super.initState();
    // Inicializa todos os grupos visíveis como não selecionados
    for (int i = 0; i < numeroDeGrupos; i++) {
      _selectedGroups[grupos[i].toLowerCase()] = false;
    }
  }

  void _toggleAll(bool value) {
    setState(() {
      _selectedGroups.updateAll((key, _) => value);
    });
  }

  List<String> get _selectedList => _selectedGroups.entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compartilhar grupos de turno"),
        backgroundColor: Colors.orange,
        actions: [
          TextButton(
            onPressed: () => _toggleAll(true),
            child: const Text("TUDO", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => _toggleAll(false),
            child: const Text("NADA", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Selecione os grupos que deseja compartilhar. Você pode enviar como arquivo para outro usuário do app ou como texto formatado para WhatsApp.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: numeroDeGrupos,
              itemBuilder: (context, index) {
                String g = grupos[index].toLowerCase();
                return CheckboxListTile(
                  title: Text("Grupo ${g.toUpperCase()}"),
                  value: _selectedGroups[g],
                  onChanged: (val) {
                    setState(() {
                      _selectedGroups[g] = val!;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              top: false, // O SafeArea aqui foca apenas na parte inferior (barra do sistema)
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.file_present),
                      label: const Text("ARQUIVO (App)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _selectedList.isEmpty 
                        ? null 
                        : () => LocalStorageService().shareSelectedGroups(groupLetters: _selectedList, isJson: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text("TEXTO (WhatsApp)"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _selectedList.isEmpty 
                        ? null 
                        : () => LocalStorageService().shareSelectedGroups(groupLetters: _selectedList, isJson: false),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
