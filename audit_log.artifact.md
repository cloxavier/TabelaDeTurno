# Registro de Auditoria e Controle de Versão Interno

Este documento serve como a memória técnica das modificações realizadas no projeto, detalhando o "porquê" de cada decisão e permitindo rastreabilidade total.

---

## [2026-08-04] - Auditoria e Estabilização Técnica

### 1. Saneamento de `lib/tabela.dart`
- **Problema**: Duplicação de declarações (`ItemMenu`, `atualizaPagina`) após reversão manual.
- **Ação**: Utilizada a ferramenta `write_file` para reconstruir o arquivo com uma versão limpa e unificada.
- **Resultado**: Erros de compilação eliminados.

### 2. Integridade de `lib/screens/event_screens.dart`
- **Ação**: Reescrita integral da análise de viabilidade. Suporte real a múltiplas trocas e horas extras.

### 3. Validação do Scroll Nativo
- **Decisão**: Uso de `ListView` com `ensureVisible` e `GlobalKey`.
- **Ajuste**: Delay aumentado para 600ms para garantir estabilidade da árvore de widgets antes da rolagem.

---

## [2026-08-05] - Fase 2: Compartilhamento e Interatividade

### 1. Motor de Compartilhamento Granular
- **Local**: `lib/local_storage_service.dart` -> `shareSingleExchange`.
- **Ação**: Criada função que gera um "Convite de Troca" (JSON) contendo apenas um registro.
- **Justificativa**: Permite que o usuário envie acordos específicos via WhatsApp sem precisar exportar todo o banco de dados.

### 2. Importação com Preview (Segurança)
- **Local**: `lib/local_storage_service.dart` -> `importData`.
- **Ação**: Implementados diálogos de confirmação que mostram o conteúdo do arquivo antes de aplicar as mudanças.
- **Justificativa**: Evita perda acidental de dados e dá transparência ao processo de restauração.

### 3. Lógica de Reciprocidade (Inversão de Papéis)
- **Local**: `lib/local_storage_service.dart` -> `_showExchangeInvitePreview`.
- **Ação**: O app detecta se o grupo do destinatário corresponde ao colaborador da troca.
- **Diferencial**: Se houver "match", o app oferece o botão "ACEITAR E INVERTER", que troca automaticamente os nomes (Eu <-> Colega) para ajustar a escala do recebedor sem erros manuais.

---

## [Próximos Passos Agendados]

1. **Gestão de Horas Extras Pro (Fase 3)**: Adicionar hora de entrada, saída e percentual (100%/120%) no formulário.
2. **Relatório de Férias (Fase 4)**: Criar visor para listagem anual de períodos de descanso.
