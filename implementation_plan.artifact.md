# Plano de Expansão: Central de Ajuda (Novas Funcionalidades)

Este plano visa enriquecer a Central de Ajuda com instruções detalhadas sobre gerenciamento de equipes, uso do menu de eventos e interpretação de indicadores visuais no calendário.

## User Review Required

> [!IMPORTANT]
> **Fidelidade aos Indicadores**: Ajustaremos a descrição dos indicadores visuais (bolinhas no calendário) para que correspondam exatamente às cores e significados definidos no código (Verde para Feriados, Azul para Eventos/Trocas, Laranja para Tarefas/Horas Extras).
>
> **Facilidade de Acesso**: Destacaremos as múltiplas formas de acessar o Gerenciador de Integrantes e o Menu de Eventos, reforçando a agilidade da interface.

## Proposed Changes

### 1. Atualização da Lista de Tópicos
#### [MODIFY] [ajuda_screen.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/screens/ajuda_screen.dart)
- Adicionar novos objetos `HelpTopic` à lista interna:
    - **Gerenciamento de Equipe**: Explicar o acesso via Drawer, Visão Diária e os atalhos nas letras dos grupos na Visão Geral.
    - **Menu de Eventos**: Instruir sobre o botão "Ações para este dia" (Diária) e o clique direto nos dias (Mensal/Anual).
    - **Tipos de Lançamentos**: Detalhar o que são Tarefas, Horas Extras, Férias e Trocas.
    - **Indicadores Visuais**: Explicar o significado das bolinhas coloridas que aparecem nos cards dos dias.

### 2. Refinamento de Texto
- Revisar os textos para garantir um tom profissional e instrutivo, seguindo as descrições fornecidas pelo autor.

## Verification Plan

### Manual Verification
- [ ] Abrir a tela de ajuda e validar se os novos tópicos aparecem nas categorias corretas.
- [ ] Verificar se as cores dos indicadores citados na ajuda batem com o que é renderizado no calendário.
- [ ] Testar a fluidez da leitura no Tema Escuro.

## Git Versioning
1. `git add .`
2. `git commit -m "Fase 3: Expansão da Central de Ajuda com detalhes sobre Equipe, Eventos e Indicadores Visuais"`
3. `git push origin main`
