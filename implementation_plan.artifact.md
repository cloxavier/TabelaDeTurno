# Plano de Refinamento: Tipografia Adaptativa e Higiene Visual

Este plano foca na robustez da interface contra textos longos e na manutenção do design ultra-clean, seguindo os padrões de usabilidade das grandes empresas de tecnologia.

## User Review Required

> [!IMPORTANT]
> **Controle de Texto**: Nomes ou cargos muito extensos passarão a usar o efeito "Ellipsis" (...). Isso impede que o texto invada áreas indesejadas ou empurre os limites do cartão, mantendo a grade visual perfeita em qualquer dispositivo.
>
> **Decisão sobre Indicadores**: Seguindo a tendência de design moderno, **não utilizaremos símbolos fixos** como `<>`. A descoberta do gesto de deslizar será confiada à Central de Ajuda e à intuição do usuário, evitando a poluição visual que símbolos extras causariam.

## Proposed Changes

### 1. Blindagem de Tipografia
#### [MODIFY] [integrantes_screen.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/screens/integrantes_screen.dart)
- Adicionar `overflow: TextOverflow.ellipsis` e `maxLines: 1` ao widget de Nome.
- Adicionar `overflow: TextOverflow.ellipsis` e `maxLines: 1` (ou 2) ao widget de Cargo/Telefone.
- Isso garante que a interface seja resiliente a entradas de dados exageradas.

### 2. Consistência de Altura
- Garantir que todos os cards da lista tenham a mesma altura visual, independentemente do tamanho do nome, o que transmite uma sensação de ordem e profissionalismo.

## Verification Plan

### Manual Verification
- [ ] Visualizar o integrante com nome longo ("Rita de Cassia...") e verificar se ele termina elegantemente em `...`.
- [ ] Confirmar se o alinhamento lateral permanece intacto mesmo com nomes curtos.
- [ ] Testar a rolagem da lista para garantir que a performance continua fluida.
