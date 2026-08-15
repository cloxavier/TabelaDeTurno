# Plano de Correção: Atualização da Biblioteca de Desugaring (Java 8+)

Este plano visa resolver o erro de compilação causado pela atualização do plugin `flutter_local_notifications` para a versão 22.3.0. Esta versão exige uma biblioteca de suporte a Java moderno mais atualizada para funcionar corretamente em dispositivos Android.

## Causa Raiz do Erro

O erro `requires desugar_jdk_libs version to be 2.1.4 or above` ocorre porque as novas versões do plugin de notificações utilizam recursos avançados do Java que não estavam presentes na versão `2.0.4` que o projeto utilizava. O Android precisa dessa "tradução" (desugaring) para garantir que o alarme funcione de forma estável.

## Proposed Changes

### 1. Atualização do Motor de Compilação Android
#### [MODIFY] [build.gradle.kts](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/android/app/build.gradle.kts)
- Alterar a versão da dependência `coreLibraryDesugaring` de `2.0.4` para **`2.1.4`**.

## Verification Plan

### Automated Tests
1. Executar `flutter run` para garantir que o processo de compilação ultrapasse a fase de verificação de metadados AAR.
2. Executar `flutter build apk` para confirmar que a build final está íntegra.

### Manual Verification
- Validar se o aplicativo abre e se o alarme continua funcionando normalmente (o desugaring é vital para a precisão do agendamento).
