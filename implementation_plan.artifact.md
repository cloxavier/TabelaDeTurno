# Plano de Auditoria e Modernização Segura: Etapa 3 (Inteligência de Prioridade)

Este plano visa eliminar o conflito de navegação onde a tela de Tabela "atropela" a tela de Alarme durante a inicialização (Cold Start), garantindo que o usuário consiga reconhecer o alarme sem interrupções.

## Auditoria Técnica: O "Atropelamento" de Telas

O problema ocorre porque dois processos de navegação iniciam simultaneamente:
1.  **Processo A (Alarme)**: O `AppRoot` detecta a notificação inicial e abre a `AlarmeRingingScreen`.
2.  **Processo B (Splash)**: A classe `Home` inicia seu timer de 1 segundo para carregar o cache e abrir a `Tabela`.

Atualmente, o **Processo B** sempre vence, pois ele executa um `pushReplacement`, substituindo qualquer tela que o alarme tenha aberto.

## Proposed Changes (Aguardando Autorização)

### [MODIFY] [lib/main.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/main.dart)
- **NavigatorKey**: Implementar a chave global de navegação para permitir saltos de tela seguros.
- **Semaforização**: Criar a variável `bool isAlarmActive = false`.
- **Filtro de Navegação**: Na função `initState` da classe `Home`, adicionar uma verificação: se `isAlarmActive` for verdadeiro, o timer da Splash Screen será cancelado ou ignorado.
- **Resultado**: A tela de alarme ganha prioridade absoluta no boot.

### [MODIFY] [lib/notification_service.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/notification_service.dart)
- Adicionar uma pequena função para resetar o estado `isAlarmActive` quando o alarme for desligado ou adiado.

## Verification Plan
- [ ] Validar que no Hard Kill + Bloqueio, a tela de alarme aparece e **não é substituída** pela Tabela.
- [ ] Confirmar que o fluxo normal (abrir o app pelo ícone) continua funcionando em 1 segundo.
- [ ] Verificar se após desligar o alarme, o usuário consegue navegar para a Tabela normalmente.
