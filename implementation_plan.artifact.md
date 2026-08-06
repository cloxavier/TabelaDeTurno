# Plano de Auditoria - Correção Estrutural do Layout

Este plano visa resolver a falha de autoscroll alterando a estrutura de renderização das visões Anual e Geral, garantindo que todos os elementos da lista sejam processados pelo motor de layout do Flutter.

## User Review Required

> [!IMPORTANT]
> **Mudança de Container**: Substituiremos o `ListView` (que é preguiçoso e não "vê" itens fora da tela) por um `SingleChildScrollView` com `Column`. Isso garantirá que o cabeçalho de Agosto seja renderizado imediatamente, permitindo que o sistema de scroll o localize.
>
> **Performance**: Para uma lista de aproximadamente 400 itens simples, o impacto na performance é insignificante em dispositivos modernos, mas a precisão do scroll será de 100%.

## Proposed Changes

### 1. Reestruturação de Visualização
#### [MODIFY] [lib/visao_anual.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/visao_anual.dart) e [lib/vista_geral.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/vista_geral.dart)
- Trocar `ListView(children: vaa)` por `SingleChildScrollView(child: Column(children: vaa))`.
- Isso elimina o problema do "Contexto Nulo" para itens que começam fora da área visível.

### 2. Confirmação de Auditoria
- Manter os logs `AUDITORIA` temporariamente para confirmar no console: "Contexto encontrado na tentativa 0".

## Verification Plan

### Manual Verification
- [ ] Ao navegar para a aba Anual ou Geral, o scroll deve ocorrer na tentativa 0 ou 1.
- [ ] O console deve exibir "Iniciando scroll..." em vez de "Contexto nulo".
