# Plano de Implementação: Gestos Bidirecionais e Interface Ultra-Clean

Este plano visa eliminar a poluição visual no Gerenciador de Integrantes e implementar um sistema de gestos profissional e intuitivo, otimizado para telas de alta densidade como a do S24 Ultra.

## User Review Required

> [!IMPORTANT]
> **Interação Bidirecional**: O usuário poderá deslizar o card para a **DIREITA** para editar e para a **ESQUERDA** para excluir.
>
> **Zero Botões**: Removeremos todos os ícones de ação de dentro dos cards. Isso deixará a interface extremamente limpa e focada no conteúdo (Nome/Cargo).
>
> **Acessibilidade**: Manteremos o "Toque" no card como um atalho para edição, garantindo que usuários que não conhecem o gesto de deslizar consigam operar o app sem dificuldades.

## Proposed Changes

### 1. Modernização Total da Lista de Equipe
#### [MODIFY] [integrantes_screen.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/screens/integrantes_screen.dart)
- **Bidirectional Swipe**:
    - `background`: Azul com ícone `Icons.edit` (aparece ao deslizar para a direita).
    - `secondaryBackground`: Vermelho com ícone `Icons.delete` (aparece ao deslizar para a esquerda).
- **Cleanup**: Remover a `Row` de botões (trailing) do `ListTile`.
- **Redundância Positiva**: Adicionar `onTap: () => _addOrEditIntegrante(item)` diretamente no `ListTile`.
- **Margens**: Aplicar o mesmo arredondamento e margem aos fundos colorido do gesto para manter a continuidade visual.

### 2. Atualização da Documentação de Ajuda
#### [MODIFY] [ajuda_screen.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/screens/ajuda_screen.dart)
- Ajustar o tópico de "Gerenciamento de Equipe" para refletir os novos gestos modernos.

## Verification Plan

### Manual Verification
- [ ] Deslizar para a direita e verificar se a janela de edição abre.
- [ ] Deslizar para a esquerda e verificar se a confirmação de exclusão aparece.
- [ ] Tocar simplesmente no nome e verificar se a edição abre.
- [ ] Validar a estética "limpa" no S24 Ultra e no Pixel 7.
