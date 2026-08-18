import 'package:flutter/material.dart';

/// Representa um tópico de ajuda na Central de Ajuda.
class HelpTopic {
  final String titulo;
  final List<TextSpan> spans; // Usado para renderizar texto rico sem marcações amadoras
  final IconData icone;
  final HelpCategory categoria;

  HelpTopic({
    required this.titulo,
    required this.spans,
    required this.icone,
    required this.categoria,
  });
}

enum HelpCategory {
  basico,
  lancamentos,
  compartilhamento,
  personalizacao,
  seguranca,
  sobre
}
