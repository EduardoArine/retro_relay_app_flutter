# features/home/

Tela principal do app. Exibe o grid de consoles com controles de liga/desliga.

## Responsabilidade

Apresentar os 16 canais do ESP32 com estado visual (ativo/inativo) e permitir toggle via toque. Também acessa a tela de controle por voz.

## Estrutura

```
home/
  models/
    canal.dart              # Canal(index, nome, ativo) — imutável
  presentation/
    home_screen.dart        # UI: grid + bottom nav + botão mic
    home_notifier.dart      # (Fase 3) CanaisNotifier: toggle logic + modo único
```

> `data/` não existe nesta feature porque `home` não persiste dados próprios.
> O toggle chama `RelayApiService` (via notifier) e lê consoles do `ConsoleRepository`.

## Model principal: `Canal`

```dart
Canal(index: 0, nome: 'Super Nintendo', ativo: false)
```

- `index` — slot físico 0–15 no ESP32
- `nome` — nome exibido (vazio = canal não configurado)
- `ativo` — estado do relé

## Regras de negócio (implementadas no `CanaisNotifier`)

**Modo único (`modoUnico = true`):**
- Ativar um canal desativa todos os outros.
- Clicar no canal já ativo desativa tudo.

**Modo multi (`modoUnico = false`):**
- Toggle simples — múltiplos canais simultâneos.

**Após toggle:** estado local atualizado imediatamente (otimista), chamada HTTP ao ESP32 em background.

## Dependências

- `RelayApiService` — para `toggleCanal()` e `setModo()`
- `ConsoleRepository` — para exibir imagem e nome dos consoles cadastrados
- `settingsProvider` — para ler IP e modoUnico atual
