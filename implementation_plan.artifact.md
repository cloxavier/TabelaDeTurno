# Plano de Otimização: Lista de Integrantes (Popup)

Este plano visa tornar a visualização da equipe mais compacta e eficiente, permitindo ver mais integrantes sem a necessidade de rolar a tela, mantendo a clareza visual.

## User Review Required

> [!TIP]
> **Outras Informações**: Respondendo à sua pergunta, o modelo de dados de `Integrante` também possui um campo de **Telefone**. Atualmente ele não é exibido no popup para economizar espaço, mas está salvo no banco de dados.

## Proposed Changes

### 1. Compactação da Lista
#### [MODIFY] [lib/rotinas.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/rotinas.dart)
- Na função `mostrarPopupIntegrantes`:
    - Ativar a propriedade `dense: true` no `ListTile`.
    - Ajustar a `visualDensity` para `VisualDensity.compact`.
    - Isso reduzirá o espaçamento vertical entre os nomes e cargos, permitindo que grupos maiores caibam na tela.

### 2. Refinamento de Layout
- Manter o ícone laranja e as cores atuais para preservar a amizade visual da interface.

## Verification Plan

### Manual Verification
- [ ] Clicar na letra de um grupo na Vista Geral.
- [ ] Verificar se a lista de integrantes está mais "justa" verticalmente.
- [ ] Confirmar se a legibilidade continua boa em dispositivos com fontes grandes.
