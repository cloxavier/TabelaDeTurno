# Plano de Implementação: Otimização da Splash Screen

Este plano visa melhorar a experiência de inicialização do aplicativo, reduzindo o tempo de espera e corrigindo o posicionamento visual em dispositivos modernos com barras de navegação por gestos (como o S24 Ultra).

## User Review Required

> [!IMPORTANT]
> **Tempo de Splash**: Reduziremos o atraso artificial de 3 segundos para 1 segundo. Isso mantém o logo visível por um breve momento para carregar as preferências, mas torna a abertura do app muito mais ágil.
>
> **Ajuste de Margem (S24 Ultra)**: Utilizaremos a propriedade `MediaQuery` para detectar a altura da barra de navegação do sistema. O texto "por Claudio Xavier" será elevado automaticamente para não ficar escondido sob os botões do Android.

## Proposed Changes

### 1. Ajuste de Delay e Layout
#### [MODIFY] [lib/main.dart](file:///F:/Claudio/Flutter/Projeto%20Tabela%20de%20turno/tabelar_de_turno-editada/lib/main.dart)
- Alterar `Duration(seconds: 3)` para `Duration(seconds: 1)`.
- Atualizar a posição do texto do autor para respeitar a `SafeArea` do dispositivo.

## Verification Plan

### Manual Verification
- [ ] Abrir o aplicativo e sentir se a transição para a tabela está mais rápida.
- [ ] Verificar no S24 Ultra se o texto "por Claudio Xavier" agora aparece acima da barra de navegação (gestos ou botões).
