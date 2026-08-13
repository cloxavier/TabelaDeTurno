# Plano de Estabilização Final: Interface Premium e Build Impecável

Este plano visa resolver o problema dos botões ocultos na notificação e eliminar definitivamente o erro de ciclo de vida do Gradle, consolidando as melhores práticas do Android 15.

## User Review Required

> [!IMPORTANT]
> **Simplificação de Notificação**: Removeremos o `BigTextStyleInformation`. Essa mudança dá "fôlego" para o sistema Android exibir os botões de ação (Desligar/Adiar) imediatamente no banner superior sem que eles fiquem escondidos sob uma seta.
>
> **Reset de Configurações (v9)**: Moveremos o alarme para o canal **`tarefas_alarme_v9`**. É obrigatório desinstalar o app antigo antes de testar para que o Android aceite esta nova configuração de prioridade máxima.

## Proposed Changes

### 1. Refinamento de Notificações (Efeito "Heads-up" Persistente)
#### [MODIFY] [notification_service.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/notification_service.dart)
- Atualizar o ID do canal para `tarefas_alarme_v9`.
- Remover a propriedade `styleInformation`.
- Garantir que `ongoing: true`, `autoCancel: false`, `importance: Importance.max` e `priority: Priority.max` estejam configurados para forçar o banner a ser estático.

### 2. Correção de Build (Gradle 8.14)
#### [MODIFY] [android/build.gradle.kts](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/android/build.gradle.kts)
- Remover o bloco `afterEvaluate` problemático.
- Aplicar a configuração de Java 17 em nível de `allprojects` e `subprojects` utilizando a sintaxe `tasks.withType<JavaCompile>`. Isso garantirá que todos os plugins, inclusive os que geram avisos, usem o Java 17.

### 3. Correção de Compilação Nativa
#### [MODIFY] [MainActivity.kt](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/android/app/src/main/kotlin/com/example/tabela_de_turno/MainActivity.kt)
- Adicionar o import `import android.content.Intent` para estabilizar o método `onNewIntent`.

## Verification Plan

### Automated Tests
1. Executar `flutter clean` e `flutter build apk`.
2. O log deve estar limpo de erros de "evaluated" e avisos de "Java 8 obsolete".

### Manual Verification
1. Instalar o novo APK (v9).
2. Agendar alarme para 1 minuto.
3. Com o celular desbloqueado, verificar se o banner aparece com os botões visíveis de imediato.
