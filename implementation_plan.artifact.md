# Plano de Auditoria e Modernização Segura: Etapa 2 (Fim da Digital)

Este plano foca na restauração do comportamento nativo do Android para exibir o alarme sobre a tela de bloqueio sem solicitar biometria (digital ou padrão), retornando à simplicidade estrutural do commit `aa58ce4`.

## Auditoria de Impacto e Não-Regressão

1.  **MainActivity (Nativo)**:
    - **Ação**: Remover o código Kotlin customizado, especificamente o `requestDismissKeyguard`.
    - **Por que**: Este comando solicita o "destrancamento" do sistema, o que obriga o Android 15 a pedir a digital. Voltaremos ao modo "Overlay" puro, onde o app apenas se sobrepõe ao bloqueio.
2.  **Zero Impacto Lateral**:
    - Esta mudança é restrita ao arquivo `.kt`. Não afeta o JSON Payload (Etapa 1), a Central de Ajuda, os Estilos ou a persistência de dados.

## Proposed Changes (Aguardando Autorização)

### [MODIFY] [MainActivity.kt](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/android/app/src/main/kotlin/com/example/tabela_de_turno/MainActivity.kt)
- Reverter para a estrutura original de classe vazia:
  `class MainActivity : FlutterActivity()`

## Verification Plan
- [ ] Validar que no Cenário A (App em background + Bloqueado), a tela de alarme surge sem pedir senha.
- [ ] Confirmar que o clique em "DESLIGAR" ou "ADIAR" funciona direto da tela de bloqueio.
- [ ] Executar `flutter build apk` para garantir que o script de build permanece íntegro.
