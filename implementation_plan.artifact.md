# Plano de Auditoria e Modernização Segura: Etapa 1 (JSON Payload)

Este plano foca na modernização da troca de mensagens interna do alarme, substituindo strings frágeis por pacotes JSON robustos. Esta é uma mudança de "infraestrutura de dados" e não altera o comportamento visual ou nativo.

## Auditoria de Impacto e Não-Regressão

1.  **Notification Service**:
    - **Origem**: `scheduleNotification` passará a embalar o título e corpo em JSON.
    - **Reação**: `handleSnoozeFromResponse` será atualizado para decodificar JSON. Isso preserva a função de Adiar 5 Minutos.
2.  **Tabela Principal**:
    - **Escuta**: O listener de notificações em `tabela.dart` será atualizado.
    - **Garantia de Erro**: Se o app receber uma notificação antiga (texto puro), a auditoria prevê um bloco `try-catch` que evita o crash e exibe um texto padrão.

## Proposed Changes (Aguardando Autorização)

### [MODIFY] [notification_service.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/notification_service.dart)
- Implementar `jsonEncode` no envio e `jsonDecode` no retorno do Snooze.

### [MODIFY] [tabela.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/tabela.dart)
- Atualizar o método `_handleNotification` para interpretar o novo formato de dados JSON.

## Verification Plan
- [ ] Validar que alarmes criados após a mudança exibem títulos com caracteres especiais (ex: dois pontos) sem erros.
- [ ] Confirmar que o botão "Adiar" continua reagendando a tarefa corretamente.
- [ ] Executar `dart analyze` para garantir zero erros de tipagem.
