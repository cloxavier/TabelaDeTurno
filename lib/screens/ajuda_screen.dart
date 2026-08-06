import 'package:flutter/material.dart';
import '../models/help_topic.dart';
import '../dados.dart';

/// Central de Ajuda Profissional
/// 
/// Desenvolvida para ser expansível e organizada por categorias.
/// Utiliza [ExpansionTile] para uma navegação limpa e eficiente.
class AjudaScreen extends StatelessWidget {
  const AjudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de tópicos de ajuda - Fácil de adicionar novos itens aqui.
    final List<HelpTopic> topicos = [
      HelpTopic(
        categoria: HelpCategory.basico,
        icone: Icons.calendar_today,
        titulo: "Como navegar entre as visões?",
        conteudo: "Utilize a barra inferior para alternar entre as visões Diária, Semanal, Mensal, Anual e Geral. A rolagem automática levará você sempre ao mês ou dia atual.",
      ),
      HelpTopic(
        categoria: HelpCategory.basico,
        icone: Icons.group,
        titulo: "Gerenciamento de Equipe",
        conteudo: "Você pode lançar integrantes em cada turno utilizando o gerenciador. O acesso pode ser feito pelo menu lateral, na visão diária ou na visão geral (clicando na letra de cada grupo para ver quem faz parte e chamar o gerenciador).",
      ),
      HelpTopic(
        categoria: HelpCategory.basico,
        icone: Icons.event_available,
        titulo: "Menu de Eventos e Lançamentos",
        conteudo: "Acesse o Menu de Eventos clicando no botão 'Ações para este dia' (na visão diária) ou clicando diretamente em qualquer dia no calendário. Lá você pode agendar Tarefas, Horas Extras, Férias e Trocas.",
      ),
      HelpTopic(
        categoria: HelpCategory.basico,
        icone: Icons.lens,
        titulo: "O que significam as bolinhas coloridas?",
        conteudo: "No calendário, as datas com agendamentos são marcadas com ícones circulares: Verde (Feriados), Azul (Eventos ou Trocas) e Laranja (Tarefas ou Horas Extras).",
      ),
      HelpTopic(
        categoria: HelpCategory.compartilhamento,
        icone: Icons.share,
        titulo: "Como compartilhar minha escala?",
        conteudo: "Você pode compartilhar sua escala como texto formatado para WhatsApp ou como um arquivo JSON para que outros colegas importem em seus aplicativos.",
      ),
      HelpTopic(
        categoria: HelpCategory.compartilhamento,
        icone: Icons.swap_horiz,
        titulo: "Como funcionam as trocas inteligente?",
        conteudo: "Ao importar um 'Convite de Troca' de um colega, o aplicativo inverte automaticamente as funções, facilitando o registro mútuo da troca de turnos.",
      ),
      HelpTopic(
        categoria: HelpCategory.estilos,
        icone: Icons.palette,
        titulo: "Layout Clássico vs. Moderno",
        conteudo: "O estilo Clássico mantém a robustez tradicional. O estilo Moderno oferece uma visualização mais limpa com destaque lateral por cores de turno.",
      ),
      HelpTopic(
        categoria: HelpCategory.seguranca,
        icone: Icons.security,
        titulo: "Meus dados estão seguros?",
        conteudo: "Sim. Seus dados são salvos localmente no seu dispositivo. Utilize a função de Backup para exportar suas configurações e tarefas para segurança extra.",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Central de Ajuda"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildCategoria(context, "Uso do Aplicativo", topicos.where((t) => t.categoria == HelpCategory.basico).toList()),
          _buildCategoria(context, "Compartilhamento & Trocas", topicos.where((t) => t.categoria == HelpCategory.compartilhamento).toList()),
          _buildCategoria(context, "Interface & Estilos", topicos.where((t) => t.categoria == HelpCategory.estilos).toList()),
          _buildCategoria(context, "Segurança", topicos.where((t) => t.categoria == HelpCategory.seguranca).toList()),
          
          const Divider(height: 40),
          
          // Seção Sobre - Destaque Profissional
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.info_outline, size: 40, color: Colors.orange),
                const SizedBox(height: 10),
                Text("Sobre o Aplicativo", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Text(
                  "A Tabela de Turno surgiu para suprir uma necessidade prática: a programação de eventos e compromissos cruzando as datas com o regime de escalas. Criado originalmente em 2022 e reconstruído em 2026 utilizando a tecnologia Flutter, o aplicativo permite que o usuário e seus colegas consultem a tabela para marcar férias, viagens e festas de forma rápida, identificando sempre o melhor período de acordo com os turnos de trabalho.",
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.person, "Autor", "Claudio de Oliveira Xavier"),
                _buildInfoRow(Icons.email, "Contato", "cdoxavier@hotmail.com"),
                _buildInfoRow(Icons.code, "Tecnologia", "Flutter / Dart"),
                const SizedBox(height: 30),
                const Text("Versão 1.1.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoria(BuildContext context, String titulo, List<HelpTopic> itens) {
    if (itens.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(titulo.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange)),
        ),
        ...itens.map((t) => ExpansionTile(
          leading: Icon(t.icone, color: Colors.blueAccent),
          title: Text(t.titulo, style: const TextStyle(fontWeight: FontWeight.w500)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(t.conteudo, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            )
          ],
        )),
      ],
    );
  }

  Widget _buildInfoRow(IconData icone, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icone, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 5),
          Expanded(child: Text(valor, style: const TextStyle(color: Colors.blueAccent))),
        ],
      ),
    );
  }
}
