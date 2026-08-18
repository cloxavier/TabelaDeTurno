import 'package:flutter/material.dart';
import '../models/help_topic.dart';

/// Central de Ajuda Profissional
/// 
/// Desenvolvida para ser um guia prático de ensino e produtividade.
/// Utiliza [ExpansionTile] e [RichText] para uma experiência fluida e moderna.
class AjudaScreen extends StatelessWidget {
  const AjudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color boldColor = isDark ? Colors.orange.shade300 : Colors.indigo.shade900;
    final Color normalColor = isDark ? Colors.grey.shade300 : Colors.grey.shade800;

    // Lista de tópicos de ajuda - Estilo Conversacional e Didático Profundo.
    final List<HelpTopic> topicos = [
      // --- CATEGORIA: CONFIGURAÇÃO ---
      HelpTopic(
        categoria: HelpCategory.basico,
        icone: Icons.star_outline,
        titulo: "Como dizer para o app qual é o meu grupo?",
        spans: [
          const TextSpan(text: "Para que as tabelas mostrem sempre a sua escala ao abrir o app, dê um "),
          TextSpan(text: "clique longo", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: " na letra do seu grupo (A, B, C...). Você verá uma "),
          const TextSpan(text: "⭐ na visão diária", style: TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: " e o "),
          const TextSpan(text: "fundo ficará colorido", style: TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: " nas outras telas.\n\nSe clicar rápido, na "),
          const TextSpan(text: "visão diária", style: TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: " você vê os integrantes de cada grupo caso você já os tenha lançado, o mesmo ocorre na "),
          const TextSpan(text: "visão geral", style: TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: ", com uma diferença, nesta você tem um botão de gerenciamento de integrantes. Nas telas de visão semanal, mensal e anual, com um "),
          TextSpan(text: "clique curto", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: ", você apenas espia a tabela de outro grupo temporariamente."),
        ],
      ),

      // --- CATEGORIA: NAVEGAÇÃO ---
      HelpTopic(
        categoria: HelpCategory.basico,
        icone: Icons.map_outlined,
        titulo: "Como navegar entre as telas e datas?",
        spans: [
          const TextSpan(text: "Você pode trocar de visão ("),
          const TextSpan(text: "Dia, Semana, Mês, Ano ou Geral", style: TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: ") usando a barra no fundo da tela ou simplesmente "),
          TextSpan(text: "arrastando o dedo para os lados", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: ".\n\nNa "),
          const TextSpan(text: "visão diária", style: TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: ", você ainda pode tocar na data no topo para escolher um dia específico no calendário."),
        ],
      ),

      // --- CATEGORIA: INTEGRANTES ---
      HelpTopic(
        categoria: HelpCategory.basico,
        icone: Icons.people_outline,
        titulo: "Como organizar os integrantes de cada grupo?",
        spans: [
          const TextSpan(text: "Mantenha a lista de quem trabalha com você atualizada. Você pode lançar integrantes para cada grupo de trabalho, para isto, basta acessar "),
          TextSpan(text: "Gerenciar Integrantes", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: " no menu lateral, ou na vista geral clicar em uma das letras do cabeçalho das escalas.\n\nNo gerenciador de integrante você pode "),
          TextSpan(text: "editar um colega", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: ", clicando no nome dele ou deslizando para a direita para um acesso rápido. Se precisar "),
          TextSpan(text: "remover alguém", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: ", basta deslizar o nome para a esquerda."),
        ],
      ),

      // --- CATEGORIA: INTELIGÊNCIA ---
      HelpTopic(
        categoria: HelpCategory.lancamentos,
        icone: Icons.auto_awesome_outlined,
        titulo: "O aplicativo 'pensa' por você",
        spans: [
          const TextSpan(text: "Ao registrar uma troca, o sistema verifica se você terá o "),
          TextSpan(text: "descanso mínimo de 11h", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: " entre os turnos e se não há férias no caminho entre outros.\n\nAlém disso, ao agendar tarefas, você pode "),
          TextSpan(text: "ativar o alarme", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: " para garantir que o celular desperte mesmo com o app fechado."),
        ],
      ),

      // --- CATEGORIA: COMPARTILHAMENTO ---
      HelpTopic(
        categoria: HelpCategory.compartilhamento,
        icone: Icons.share_outlined,
        titulo: "Sincronização com Colegas",
        spans: [
          const TextSpan(text: "• "),
          TextSpan(text: "Troca Automática", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: ": Envie um convite de troca pelo WhatsApp. Quando seu colega abrir o arquivo, o app dele registrará a troca invertendo os papéis automaticamente 🤝.\n"),
          const TextSpan(text: "• "),
          TextSpan(text: "Dados de Equipe", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: ": Compartilhe a lista de integrantes do seu grupo para que outros não precisem digitar tudo novamente."),
        ],
      ),

      // --- CATEGORIA: PERSONALIZAÇÃO ---
      HelpTopic(
        categoria: HelpCategory.personalizacao,
        icone: Icons.palette_outlined,
        titulo: "Estilos Clássico e Moderno",
        spans: [
          const TextSpan(text: "• "),
          TextSpan(text: "Clássico", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: ": Visual tradicional de calendário, ideal para conferência de datas.\n"),
          const TextSpan(text: "• "),
          TextSpan(text: "Moderno", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: ": Foco nas cores do turno com um visual limpo e elegante 🎨."),
        ],
      ),

      // --- CATEGORIA: SEGURANÇA ---
      HelpTopic(
        categoria: HelpCategory.seguranca,
        icone: Icons.shield_outlined,
        titulo: "Privacidade e Backup",
        spans: [
          const TextSpan(text: "Seus dados pertencem a você e ficam salvos apenas no seu aparelho 🔒. Use a função "),
          TextSpan(text: "Backup", style: TextStyle(fontWeight: FontWeight.bold, color: boldColor)),
          const TextSpan(text: " para gerar um arquivo de segurança e guardá-lo na nuvem ou e-mail."),
        ],
      ),

      // --- CATEGORIA: SOBRE ---
      HelpTopic(
        categoria: HelpCategory.sobre,
        icone: Icons.info_outline,
        titulo: "Sobre o Aplicativo e o Autor",
        spans: [
          const TextSpan(text: "Desenvolvido para facilitar o planejamento de vida de quem trabalha em regimes de escala.\n\n"),
          const TextSpan(text: "• "),
          TextSpan(text: "Autor", style: TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: ": Claudio de Oliveira Xavier 👤\n"),
          const TextSpan(text: "• "),
          TextSpan(text: "Contato", style: TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: ": cdoxavier@hotmail.com 📧\n"),
          const TextSpan(text: "• "),
          TextSpan(text: "Versão", style: TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: ": 1.2.0"),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Central de Ajuda"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildCategoria(context, "Configuração e Ensino", topicos.where((t) => t.categoria == HelpCategory.basico).toList(), normalColor),
          _buildCategoria(context, "Lançamentos e Inteligência", topicos.where((t) => t.categoria == HelpCategory.lancamentos).toList(), normalColor),
          _buildCategoria(context, "Compartilhamento & Dados", topicos.where((t) => t.categoria == HelpCategory.compartilhamento).toList(), normalColor),
          _buildCategoria(context, "Visual e Segurança", topicos.where((t) => [HelpCategory.personalizacao, HelpCategory.seguranca].contains(t.categoria)).toList(), normalColor),
          _buildCategoria(context, "Informações do Sistema", topicos.where((t) => t.categoria == HelpCategory.sobre).toList(), normalColor),
          
          // Espaçamento final para evitar que o último item fique sob a barra de navegação
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCategoria(BuildContext context, String titulo, List<HelpTopic> itens, Color textColor) {
    if (itens.isEmpty) return const SizedBox.shrink();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
          child: Text(
            titulo.toUpperCase(), 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              color: Colors.orange.shade800, 
              letterSpacing: 1.2
            )
          ),
        ),
        ...itens.map((t) => ExpansionTile(
          shape: const Border(), // Remove bordas padrão ao expandir
          leading: Icon(t.icone, color: Colors.indigo.shade400, size: 24),
          title: Text(t.titulo, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Contraste aprimorado para o modo claro
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.blue.shade50.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.blue.shade100),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: textColor, 
                      fontSize: 15,
                      height: 1.6,
                    ),
                    children: t.spans,
                  ),
                ),
              ),
            )
          ],
        )),
      ],
    );
  }
}
