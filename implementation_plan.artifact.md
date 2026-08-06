# Plano de Restauração de DNA e Correção de Overflow (Clássico)

Este plano visa restaurar a flexibilidade original do Estilo Clássico (0), eliminando os erros de "Overflow" sem perder a estabilidade do Estilo Moderno (1).

## User Review Required

> [!IMPORTANT]
> **Restauração da Flexibilidade**: O Estilo Clássico voltará a utilizar `constraints (minHeight)` em vez de `height` fixo. Isso permite que o card cresça sutilmente se o conteúdo for maior que o esperado, evitando a tarja de erro "OVERFLOWED".
>
> **Manutenção do Moderno**: O Estilo Moderno continuará usando `height` fixo para garantir que a barra lateral de turno ocupe toda a altura do card e que o alinhamento `spaceBetween` funcione de forma profissional, agora protegido pelo `FittedBox`.

## Proposed Changes

### 1. Ajuste no Motor de Card (DNA)
#### [MODIFY] [lib/rotinas.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/rotinas.dart)
- No Estilo 0 (Clássico):
    - Alterar o `Container` para usar `constraints: BoxConstraints(minHeight: cardMinHeight)` e remover a propriedade `height`.
    - Isso restaura o comportamento original onde o card "respira" conforme o conteúdo.
- No Estilo 1 (Moderno):
    - Manter `height: cardMinHeight` para garantir a estética da barra lateral.
    - Reforçar o uso de `FittedBox` no número do dia para evitar qualquer overflow residual.

### 2. Documentação e Comentários
- Adicionar comentários no código explicando por que o Clássico usa `constraints` e o Moderno usa `height`, facilitando futuras manutenções sem quebrar o layout novamente.

## Verification Plan

### Manual Verification
- [ ] Verificar se o Estilo Clássico na visão "Geral" e "Ano" parou de exibir o erro "OVERFLOWED".
- [ ] Confirmar se o Estilo Moderno continua centralizado e com a barra lateral correta.
- [ ] Validar a alternância entre estilos nas Configurações.
