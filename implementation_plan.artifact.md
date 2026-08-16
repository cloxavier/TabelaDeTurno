# Plano de Refinamento: Layout "Badge" Premium (Etapa 5.1)

Este plano visa implementar a Opção 1 de layout para a Visão Anual (Modo Moderno), posicionando os indicadores no canto superior esquerdo e o turno no centro absoluto.

## Auditoria de Design Profissional

A Opção 1 foi selecionada por oferecer a melhor separação entre o conteúdo principal (Turno) e as informações secundárias (Indicadores). Esta assimetria é característica de designs modernos e elimina o conflito de espaço vertical.

## Solução Técnica

1.  **Estrutura**: Uso de `Stack` para permitir que os indicadores "flutuem" sem empurrar o texto.
2.  **Posicionamento**:
    - **Turno**: Centralizado via `Center`, com `fontSize: 18` e `FontWeight.bold`.
    - **Indicadores**: Agrupados em `Row` e posicionados em `top: 2, left: 6`.
3.  **Consistência**: O tamanho da letra será idêntico em todos os dias, garantindo uma grade harmoniosa.

## Proposed Changes (Aguardando Autorização)

### [MODIFY] [rotinas.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/rotinas.dart)
- Refatorar o bloco `tipo == "aa"` no Estilo Moderno para a nova estrutura de `Stack`.

## Verification Plan
1.  Gerar APK e validar visualmente a clareza da grade anual.
2.  Garantir que os indicadores não colidam com a barra lateral esquerda colorida.
