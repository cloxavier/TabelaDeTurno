# Plano de Implementação: Sincronização e Identidade de Grupos

Este plano visa padronizar a seleção de grupos no aplicativo, introduzindo uma distinção visual entre o grupo favorito (persistente) e o grupo visualizado (temporário), além de garantir a reversão automática para o favorito ao sair do app.

## Auditoria de Design e Comportamento

### 1. Hierarquia Visual (Diferenciação)
- **Grupo Favorito (Persistente)**: Destaque Triplo (Fundo, Borda e Texto de cor diferente).
- **Grupo Visualizado (Temporário)**: Destaque Duplo (Apenas Borda e Texto, como no estado atual).
- **Sublinhado**: Mantido para indicar qual tabela está sendo mostrada no momento.

### 2. Gestos e Ações
- **Clique Curto (Tabela/Anual/Mensal)**: Muda o `grupoAtual` apenas na memória RAM (temporário).
- **Clique Longo (Global)**: Salva no arquivo de preferências e atualiza o estado visual (persistente).

### 3. Mecanismo de Reversão (O Fim da Semi-Persistência)
Utilizaremos um observador de ciclo de vida para garantir que o "Modo Consulta" seja limpo ao sair do aplicativo.

## Proposed Changes (Aguardando Autorização)

### [MODIFY] [main.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/main.dart)
- Implementar `WidgetsBindingObserver` no `AppRoot`.
- No evento `AppLifecycleState.paused`, forçar `grupoAtual = favorito`.

### [MODIFY] [tabela.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/tabela.dart)
- Refatorar `btContainer` para suportar `onLongPress`.
- Implementar a lógica de cores: fundo preenchido apenas se `valorGrupo == favorito`.

### [MODIFY] [visao_diaria.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/visao_diaria.dart)
- Sincronizar o visual dos botões de grupo para que o favorito tenha o fundo preenchido, mantendo a consistência visual em todo o app.

## Verification Plan
1. **Teste Temporário**: Na Visão Mensal, clique na letra C -> Minimize o app -> Volte ao app -> Deve estar na letra do seu grupo Favorito original.
2. **Teste Persistente**: Clique longo na letra B -> SnackBar aparece -> Feche o app completamente (Hard Kill) -> Reabra -> O app deve iniciar na letra B com o fundo colorido.
