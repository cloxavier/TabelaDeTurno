import 'package:flutter/material.dart';
import '../local_storage_service.dart';
import '../dados.dart';
import '../rotinas.dart';
import 'share_selection_screen.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final TextEditingController _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nomeController.text = nomeUsuario;
  }

  void _saveName() {
    nomeUsuario = _nomeController.text.trim();
    preferencias[0]["nomeUsuario"] = nomeUsuario;
    salvaPreferencia();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Identificação salva!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backup e Colaboração"),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: "Sua Identificação", icon: Icons.person_pin),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: "Nome para envios e arquivos",
                        hintText: "Ex: Claudio, Grupo_C, etc.",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      onSubmitted: (_) => _saveName(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.save, color: Colors.blue),
                    onPressed: _saveName,
                    tooltip: "Salvar Nome",
                  )
                ],
              ),
            ),
          ),
          
          _SectionHeader(title: "Segurança e Recuperação", icon: Icons.security),
          _buildOption(
            context,
            icon: Icons.cloud_upload,
            title: "Backup Total (Dados + Setup)",
            subtitle: "Salva absolutamente tudo: tarefas, eventos, integrantes e suas preferências de interface.",
            onTap: () async {
              try {
                await LocalStorageService().shareFullBackup();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erro ao exportar: $e"), backgroundColor: Colors.red),
                );
              }
            },
          ),
          _buildOption(
            context,
            icon: Icons.restore,
            title: "Restaurar do Arquivo",
            subtitle: "Recupera dados a partir de um backup total ou parcial recebido.",
            onTap: () async {
              try {
                bool success = await LocalStorageService().importData(context);
                if (success) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Importação concluída com sucesso! Algumas mudanças podem exigir reiniciar o app.")),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erro ao importar: $e"), backgroundColor: Colors.red),
                );
              }
            },
          ),
          
          const SizedBox(height: 20),
          _SectionHeader(title: "Ferramentas de Equipe", icon: Icons.group),
          _buildOption(
            context,
            icon: Icons.checklist_rtl,
            title: "Compartilhar grupos de turno",
            subtitle: "Escolha quais grupos da sua equipe deseja enviar (Texto ou Arquivo).",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ShareSelectionScreen()));
            },
          ),
          _buildOption(
            context,
            icon: Icons.settings_suggest,
            title: "Enviar Configurações do App",
            subtitle: "Compartilha seu tema, layout e grupo favorito para padronizar com um colega.",
            onTap: () async {
              try {
                await LocalStorageService().shareAppSetup();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erro ao compartilhar setup: $e"), backgroundColor: Colors.red),
                );
              }
            },
          ),

          const SizedBox(height: 40),
          Card(
            color: Colors.orange.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(height: 8),
                  Text(
                    "Dica Profissional: Utilize o 'Enviar Configurações' para ajudar novos colegas a configurar o app rapidamente com o padrão da equipe.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Colors.orange.shade100,
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              letterSpacing: 1.1,
            ),
          ),
          const Expanded(child: Divider(indent: 10)),
        ],
      ),
    );
  }
}
