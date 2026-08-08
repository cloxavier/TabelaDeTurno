# Plano de Estabilização: Importação Direta e Ajuste de Interface

Este plano visa resolver a falha na importação de arquivos via WhatsApp e corrigir o erro de layout (Overflow) na barra de título em dispositivos de alta densidade.

## User Review Required

> [!IMPORTANT]
> **Mudança de Fluxo**: Moveremos o processamento de arquivos externos da tela de Splash para a tela Principal (Tabela). Isso garante que o aplicativo já esteja totalmente carregado antes de tentar exibir o diálogo de importação, resolvendo o problema de "nada acontecer".
>
> **Segurança de Interface**: O erro de "Overflow" na barra de título será corrigido utilizando componentes flexíveis. Isso impede que o texto do título e os controles de ano "briguem" por espaço, adaptando-se automaticamente ao tamanho da tela.

## Proposed Changes

### 1. Configuração Nativa (Android)
#### [MODIFY] [AndroidManifest.xml](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/android/app/src/main/AndroidManifest.xml)
- Alterar `android:launchMode` da `MainActivity` para `singleTask`. Isso garante que novos arquivos clicados no WhatsApp sejam entregues à instância correta do app.

### 2. Migração de Lógica de Importação
#### [MODIFY] [main.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/main.dart)
- Remover o listener do `ReceiveSharingIntent` e a função `_processSharedFile`. A tela de Splash voltará a ser apenas para carregamento inicial.

#### [MODIFY] [tabela.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/tabela.dart)
- Implementar o listener do `ReceiveSharingIntent` no `initState`.
- Adicionar o método `_handleSharedFile` para ler e validar o JSON usando o `LocalStorageService`.
- **Correção de UI**: Envolver o título da AppBar em um widget `Flexible` para evitar o erro de estouro de pixels na horizontal.

### 3. Refinamento de Validação
#### [MODIFY] [local_storage_service.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/local_storage_service.dart)
- Adicionar logs extras para facilitar a depuração caso um arquivo seja rejeitado pela validação de DNA.

## Verification Plan

### Manual Verification
- [ ] Clicar em um arquivo JSON no WhatsApp com o app fechado. Ele deve abrir e mostrar o preview.
- [ ] Clicar em um arquivo JSON com o app já aberto. O preview deve aparecer instantaneamente.
- [ ] Verificar se a barra de título no S24 Ultra parou de exibir as tarjas amarelas de overflow.
