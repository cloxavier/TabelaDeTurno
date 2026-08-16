# Plano de Debate: Refinamentos de Layout e Estratégia de Evolução

Este documento serve como base para o debate das 5 sugestões de melhoria, classificadas por risco de regressão e impacto funcional.

## Classificação de Risco (Regras de Ouro Aplicadas)

### 🟢 Baixo Risco (Mudanças Visuais e de Texto)
1.  **Item 5: Redundância na Visão Anual**: Remover a exibição do dia do mês dentro do card de turno quando visualizado na tabela anual (`tipo == "aa"`).
2.  **Item 4: Logo no Menu Lateral**: Ajustar o `DrawerHeader` para evitar que o logo apareça cortado.
3.  **Item 3: Central de Ajuda**: Adicionar novos tópicos e realizar ajustes simples em textos existentes.

### 🟡 Médio Risco (Infraestrutura)
4.  **Item 1: Flutter Upgrade**: O sistema sugere atualização. Exige auditoria para confirmar se a versão nova (provavelmente Flutter 3.45+) não quebra o motor de notificações que acabamos de estabilizar.

### 🔴 Alto Risco (Lógica de Negócio e Dados)
5.  **Item 2: Mudanças em Férias e Horas Extras**: Refatoração profunda em telas de lançamento que lidam com cálculos e persistência de arquivos. Exige auditoria linha a linha e backup prévio.

---

## Proposta de Debate: Passo 1 (Higiene Visual)

### Item 5: Tabela Anual (Redundância)
- **Diagnóstico**: O `cardDia` atualmente desenha o dia (`dm`) em todos os modos. Na Visão Anual, essa informação já existe na coluna à esquerda.
- **Sugestão de Solução**: Utilizar a flag `tipo == "aa"` para ocultar o texto do dia, deixando apenas a letra do turno em destaque.

### Item 4: Logo do Menu
- **Diagnóstico**: O logo está dentro de um `Material` com `borderRadius`. Se a imagem não for quadrada ou tiver margens internas pequenas, ela sofre cortes.
- **Sugestão de Solução**: Ajustar o `BoxFit` para `fit: BoxFit.contain` e possivelmente aumentar levemente o `SizedBox` ou remover o `Clip.antiAlias` se o logo original já for arredondado.

---

## Próximos Passos
- [ ] Debate e Aprovação do Passo 1.
- [ ] Auditoria Técnica do Item 1 (Upgrade).
- [ ] Levantamento de Requisitos para o Item 2 (Férias/Extras).
