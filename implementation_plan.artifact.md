# Plano de Auditoria e Correção: Alarme e Persistência de Tarefas

Este plano detalha a investigação técnica e as correções necessárias para resolver a regressão nos alarmes e a duplicidade de tarefas no banco de dados.

## Auditoria Técnica (Causa Raiz)

Identificamos que a falha ocorre devido a um **acoplamento frágil** na função de salvamento. O aplicativo tenta salvar o dado em disco e agendar a notificação na mesma sequência. Caso o Android bloqueie o agendamento do alarme (comum em Android 14/15 por restrições de economia de bateria ou permissões de alarme exato), uma exceção é lançada.

**Consequências observadas:**
1.  **Falha no fechamento**: O comando `Navigator.pop(context)` nunca é alcançado porque o código trava no erro do alarme.
2.  **Duplicidade**: O usuário, vendo que a tela não fechou, clica em "Salvar" novamente, gerando novos registros com IDs diferentes no arquivo JSON.
3.  **Inconsistência de UI**: As telas de listagem não são atualizadas porque o fluxo foi interrompido antes de chamar o recarregamento dos dados.

## User Review Required

> [!IMPORTANT]
> **Resiliência de Dados**: O salvamento da tarefa será priorizado. Se o alarme falhar por restrição do sistema, a tarefa ainda assim será salva com sucesso e o usuário será avisado via alerta na tela sobre a permissão de notificação.
>
> **Permissões de Alarme**: Em aparelhos modernos (Android 14/15), o sistema pode exigir que o usuário habilite manualmente a opção "Alarmes e Lembretes" nas configurações do Android. Adicionaremos um aviso caso isso seja detectado.

## Proposed Changes

### 1. Robustez no Gerenciador de Tarefas
#### [MODIFY] [lib/screens/tarefas_screen.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/screens/tarefas_screen.dart)
- Isolar o `NotificationService().scheduleNotification` em um bloco `try-catch` próprio.
- Garantir que `Navigator.pop(context)` e `_loadData()` ocorram imediatamente após o sucesso do `LocalStorageService().saveTarefas`.
- Desabilitar visualmente o botão de salvar durante o processamento para evitar cliques duplos.

### 2. Diagnóstico de Notificações
#### [MODIFY] [lib/notification_service.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/notification_service.dart)
- Adicionar logs de erro mais detalhados para capturar falhas de segurança do Android 15.
- Melhorar a validação de data para garantir que alarmes agendados para o "limite" da hora atual não falhem.

### 3. Sincronização de Cache
#### [MODIFY] [lib/local_storage_service.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/local_storage_service.dart)
- Adicionar uma pequena margem de segurança nas operações de escrita para evitar conflitos de leitura simultânea em telas diferentes.

## Verification Plan

### Manual Verification
- [ ] Criar uma nova tarefa com alarme para 1 minuto no futuro.
- [ ] Forçar um erro de alarme (desabilitando permissões no Android) e verificar se a tarefa é salva mesmo assim.
- [ ] Verificar se a duplicidade de tarefas (como na imagem enviada) parou de ocorrer ao clicar rapidamente em salvar.
- [ ] Testar a edição de uma tarefa existente e confirmar se o registro original é atualizado em vez de duplicado.
