# Plano de Implementação: Loop de Sincronia Inteligente (Fase 4.2)

Este plano visa dar fluidez total ao aplicativo após o reconhecimento do alarme, utilizando uma técnica de "Espera Ativa Assíncrona" que garante que o app retome a navegação para a Tabela assim que o alarme for resolvido.

## Auditoria de Segurança e Performance

1.  **Não-Bloqueante**: O loop utilizará `await Future.delayed`, o que libera a Thread principal do Flutter para manter o celular fluido e economizar bateria enquanto aguarda.
2.  **Fim do Estado Estático**: Resolvemos o problema de o app ficar parado na Splash Screen após o Hard Kill, pois o código agora tem ordens explícitas para "checar e seguir viagem".
3.  **Não-Regressão**: Manteremos a `MainActivity.kt` limpa e o JSON Payload íntegro, preservando as conquistas das etapas anteriores.

## Proposed Changes (Aguardando Autorização)

### [MODIFY] [lib/main.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/main.dart)
- Manter o semáforo `bool isAlarmActive = false`.
- Na classe `Home`, implementar um loop de verificação assíncrona dentro do `initState`.
- Adicionar uma trava de segurança (timeout) para que o loop não dure mais de 10 minutos em caso de erro.

### [MODIFY] [lib/notification_service.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/notification_service.dart)
- Garantir que as ações de "Desligar" e "Adiar" resetem o semáforo global para liberar o fluxo do app.

## Verification Plan
1. `flutter build apk`.
2. Instalação limpa no S24 Ultra.
3. Teste Alarme (App Morto + Bloqueado) -> Clicar em DESLIGAR -> Verificar se a Tabela abre sozinha após a interação.
4. Validar se o consumo de CPU permanece normal durante o alarme.
