# Registro de Evolução e Regras de Ouro

## Regras de Ouro da Aplicação
- [x] Segurança Máxima
- [x] Zero Regressão
- [x] Auditoria de Impacto
- [x] Fidelidade ao Autor
- [x] Pesquisa Multi-IA e Auditoria Cruzada
- [x] Transparência

---

## Status do Projeto e Backlog (Ordem de Prioridade por Risco)

### 🟢 Fase 1: Higiene Visual e Ajustes de Layout (Baixo Risco)
- [x] **Estabilização da Visão Anual (Modo Moderno)**
    - [x] Remover redundância do dia do mês.
    - [x] Centralizar turno.
    - [x] Implementar Layout "Badge" (Indicadores no canto superior esquerdo).
    - [ ] **Ajuste Fino de Alinhamento**: Testar `top: 1, left: 0` com `font: 17` para equilíbrio entre bolinhas e horário.
- [ ] **Expansão da Central de Ajuda (Item 3)**
    - [ ] Mapear e implementar novos tópicos de ajuda solicitados.
    - [ ] Revisar textos de ajuda existentes.

### 🟡 Fase 2: Infraestrutura e Manutenção (Médio Risco)
- [ ] **Auditoria de Flutter Upgrade (Item 1)**
    - [ ] Analisar impacto da nova versão estável do Flutter no motor de alarmes e plugins.

### 🔴 Fase 3: Reformulação de Lançamentos (Alto Risco)
- [ ] **Mudanças em Férias e Horas Extras (Item 2)**
    - [ ] Levantar novos requisitos funcionais.
    - [ ] Auditoria de impacto na persistência de dados.
    - [ ] Implementação linha a linha com garantia de não-regressão.

---

## Histórico de Conquistas Estabilizadas
- [x] Motor de Alarmes Modernizado (Android 15 / S24 Ultra).
- [x] Ressurreição de App após Hard Kill (Cold Start).
- [x] Comunicação Interna via JSON Payload (Resiliência de Dados).
- [x] Modernização Total de Dependências (Versões 2026).
- [x] Fim dos pedidos repetitivos de permissão no boot.
