# Tarefas: Restauração de Fidelidade e Estabilização do Alarme (Passo a Passo)

- [x] **Passo 1: Blindagem de Dados (JSON Payload)**
    - [x] Atualizar `lib/notification_service.dart` para usar `jsonEncode`.
    - [x] Atualizar `lib/main.dart` para usar `jsonDecode`.
    - [x] Validar funcionamento de caracteres especiais no título/corpo.
- [/] **Passo 2: Autoridade Nativa (Fim do pedido de Digital)**
    - [x] Limpar `android/app/src/main/kotlin/.../MainActivity.kt` (Reversão para classe vazia).
    - [ ] Validar que o alarme não solicita digital/padrão ao disparar bloqueado.
- [ ] **Passo 3: Inteligência de Inicialização (Cold Start)**
    - [ ] Implementar `navigatorKey` e `AppRoot` no `lib/main.dart`.
- [ ] **Passo 4: Auditoria Final e Build**
    - [ ] Executar `dart analyze` para garantir zero erros.
    - [ ] Gerar APK Release para teste de campo.
