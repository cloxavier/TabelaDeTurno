# Plano de Estabilização de Layout e Fidelidade Visual

Este plano visa eliminar os erros de estouro de pixels (Overflow) nas visões densas (Mensal/Anual) e consolidar o sistema de estilos com comentários profissionais e reatividade total.

## User Review Required

> [!IMPORTANT]
> **Correção de Overflow**: Utilizaremos `Expanded` + `FittedBox` no componente central do card. Isso permite que o Flutter ajuste o tamanho do número do dia dinamicamente para caber no espaço disponível, eliminando os erros de layout em telas menores.
>
> **Estabilidade Vertical**: Agora que os cards possuem altura fixa calculada, o uso de `Expanded` é seguro e não causará o erro de "unbounded height" anterior.

## Proposed Changes

### 1. Refinamento do Motor de Card (DNA)
#### [MODIFY] [lib/rotinas.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/rotinas.dart)
- No Estilo 1 (Moderno):
    - Reduzir `Padding` vertical de 2 para 1 em cards de tabela (`full: false`).
    - Envolver o número do dia em um `Expanded` com `FittedBox`.
    - Adicionar comentários Javadoc-style explicando a lógica de adaptabilidade.
- No Estilo 0 (Clássico):
    - Garantir que a estrutura vertical seja igualmente resiliente.

### 2. Sincronia e Comentários
#### [MODIFY] [lib/config.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/config.dart)
- Adicionar comentários profissionais nas funções de alteração de estado.
- Validar se o preview de interface responde imediatamente a todas as variáveis globais.

## Verification Plan

### Manual Verification
- [ ] Mudar para Estilo Moderno na visão Mensal e verificar se as tarjas de "OVERFLOWED" desapareceram.
- [ ] Verificar se o número do dia permanece legível e centralizado.
- [ ] Confirmar se a mudança de Tema Escuro altera a barra inferior instantaneamente.

## Git Versioning (A ser executado após aprovação)
1. `git add .`
2. `git commit -m "Fix: Estabilização de layout (overflow), implementação de FittedBox e reatividade global de estilos"`
3. `git push origin main`
