# Plano de Implementação: Central de Ajuda e Identidade Visual (Fase 3)

Este plano estabelece a criação de uma Central de Ajuda profissional e expansível, além da seção "Sobre", consolidando a identidade do aplicativo e fornecendo suporte claro ao usuário.

## User Review Required

> [!IMPORTANT]
> **Arquitetura Expansível**: A Central de Ajuda será baseada em uma lista de objetos de dados. Isso significa que adicionar um novo tópico de ajuda no futuro será tão simples quanto adicionar uma linha de código em uma lista, sem precisar mexer no layout da tela.
>
> **Seção Sobre**: Criamos um texto profissional que valoriza sua trajetória como desenvolvedor autodidata e a origem prática do projeto, conforme os dados fornecidos.

## Proposed Changes

### 1. Modelo de Dados de Ajuda
#### [NEW] [help_topic.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/models/help_topic.dart)
- Criar a classe `HelpTopic` com campos: `titulo`, `conteudo`, `icone` e `categoria`.

### 2. Tela de Ajuda Profissional
#### [NEW] [ajuda_screen.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/screens/ajuda_screen.dart)
- Implementar uma `SliverList` ou `ListView` que renderiza `ExpansionTile` para cada tópico.
- Organizar por categorias: **Uso Básico**, **Compartilhamento & Trocas**, **Configurações & Estilos** e **Segurança**.
- Incluir no final o item **Sobre o Aplicativo** com o design que valoriza sua autoria.

### 3. Integração no Menu Lateral (Drawer)
#### [MODIFY] [tabela.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/tabela.dart)
- Adicionar o `ItemMenu` da "Central de Ajuda" com ícone de suporte.

### 4. Registro de Futuro (Log de Evolução)
#### [MODIFY] [task.artifact.md](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/.artifacts/task.artifact.md)
- Adicionar a tarefa de "Unificação de DNA" para permitir múltiplos layouts em todas as visões (incluindo Semanal).

## Verification Plan

### Manual Verification
- [ ] Validar a navegação Drawer -> Ajuda.
- [ ] Testar a expansão dos tópicos e legibilidade.
- [ ] Conferir se os dados na seção "Sobre" estão corretos (Nome, E-mail, Data).
- [ ] Verificar a adaptação ao Tema Escuro.

## Git Versioning (Executado após conclusão)
1. `git add .`
2. `git commit -m "Fase 3: Implementação da Central de Ajuda expansível e seção Sobre o Autor"`
3. `git push origin main`
