import 'package:flutter/material.dart';

/// Representa um tópico de ajuda na Central de Ajuda.
/// Esta estrutura permite que a ajuda seja expansível e fácil de manter.
class HelpTopic {
  final String titulo;
  final String conteudo;
  final IconData icone;
  final HelpCategory categoria;

  HelpTopic({
    required this.titulo,
    required this.conteudo,
    required this.icone,
    required this.categoria,
  });
}

enum HelpCategory {
  basico,
  compartilhamento,
  estilos,
  seguranca,
  sobre
}
