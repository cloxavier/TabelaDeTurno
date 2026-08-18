# Plano de Refinamento: Didática Profissional na Central de Ajuda

Este plano visa aplicar os refinamentos finais de texto na Central de Ajuda, tornando-a mais profunda, precisa e verdadeiramente instrutiva para o usuário final.

## Auditoria de Conteúdo (Ensino Profissional)

Ajustaremos os tópicos para refletir a profundidade real das funcionalidades:

### 1. Identidade de Grupo
- **Novo Texto**: Detalhar que o clique longo salva o favorito (Estrela/Fundo) e o clique curto tem funções diferentes (Integrantes na Diária/Geral vs. Consulta na Semanal/Anual).

### 2. Navegação e Atalhos
- **Novo Texto**: Incluir a visão "Geral" e detalhar que o atalho de data no topo é específico da Visão Diária.

### 3. Organização de Integrantes
- **Novo Texto**: Explicar os dois caminhos para o gerenciador: Menu Lateral ou Clique nos cabeçalhos da Vista Geral.

### 4. Inteligência de Lançamentos
- **Novo Texto**: Reforçar as validações de segurança (descanso de 11h, conflitos de férias) e o alarme para tarefas.

## Proposed Changes (Aguardando Autorização)

### [MODIFY] [ajuda_screen.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/screens/ajuda_screen.dart)
- Atualizar a lista de tópicos com os textos conversacionais e profundos sugeridos pelo Autor.
- Manter o uso de `RichText` e a paleta de cores premium (Azul Marinho/Claríssimo).

## Verification Plan
1. Validar a inclusão da visão "Geral" em todos os tópicos pertinentes.
2. Confirmar se a explicação sobre os integrantes diferencia o clique curto na Diária e na Geral.
3. Garantir a ausência de marcações técnicas (**) no resultado visual final.
