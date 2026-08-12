# Plano de Implementação: Operação Alarme Real (Consolidado)

Este plano consolida as melhores práticas para Android 14/15, visando restaurar a funcionalidade da tela de alarme sobre o bloqueio com 100% de confiabilidade e zero regressões.

## Auditoria de Impacto e Dependências

1.  **Arquitetura de Navegação**: O uso de `navigatorKey` permitirá que o alarme "salte" sobre qualquer tela aberta. Isso é compatível com o `PageView` da tela de Tabela.
2.  **Estado Global**: O `AppRoot` continuará utilizando o `AnimatedBuilder` e o `AppController`, garantindo que o **Tema Escuro** e os **Estilos de Card** continuem reativos.
3.  **Segurança de Dados**: A migração do payload para JSON torna o sistema resiliente a caracteres especiais nos títulos das tarefas.

## User Review Required

> [!IMPORTANT]
> **Ação no S24 Ultra**: Após esta build, ao abrir o app, o sistema poderá solicitar a permissão **"Permitir notificações em tela cheia"**. É vital conceder para que o banner de topo seja substituído pela tela de alarme.
>
> **Desinstalação Necessária**: Para limpar resquícios de canais de notificação antigos que o Android "decorou", você deverá desinstalar o app antes de testar a nova versão.

## Proposed Changes

### 1. Refinamento do Serviço de Notificações
#### [MODIFY] [notification_service.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/notification_service.dart)
- Implementar `requestFullScreenIntentPermission()` no `init`.
- Alterar `payload` de string simples para `jsonEncode`.
- Corrigir a função `handleSnoozeFromResponse` para decodificar o novo formato JSON.

### 2. Novo Fluxo de Inicialização (Cold Start)
#### [MODIFY] [main.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/main.dart)
- Criar a classe `AppRoot` para gerenciar a navegação inicial e global.
- Adicionar `navigatorKey` para permitir abertura de telas fora do contexto local.
- Usar `getNotificationAppLaunchDetails()` para detectar se o app foi aberto por um alarme.

### 3. Autoridade de Janela Nativa (Kotlin)
#### [MODIFY] [MainActivity.kt](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/android/app/src/main/kotlin/com/example/tabela_de_turno/MainActivity.kt)
- Implementar flags `setShowWhenLocked` e `setTurnScreenOn` com imports corretos para evitar erros de compilação.

### 4. Diagnóstico de Minificação
#### [MODIFY] [build.gradle.kts](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/android/app/build.gradle.kts)
- Temporariamente desativar `isMinifyEnabled` para isolar o problema visual.

## Verification Plan

### Manual Verification
1.  `flutter clean`.
2.  `flutter build apk`.
3.  Instalar no S24 Ultra após desinstalar a versão anterior.
4.  **Teste 1**: Alarme com app aberto (Toque em Adiar/Desligar).
5.  **Teste 2**: Alarme com app fechado e celular bloqueado (Verificar se a tela personalizada aparece).
