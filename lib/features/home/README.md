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

## Estado real dos relés (`GET /estado`)

Os relés também mudam pela interface web do ESP32, pelo widget Android e por outros celulares. O `CanaisNotifier` lê o estado real (bitmask dos 16 canais + modo) e aplica na lista:

- ao reconectar (inclusive logo após abrir o app) e ao voltar ao primeiro plano
- a cada `AppConstants.estadoPollSeconds` (5 s) com o app aberto e conectado
- após a resposta de cada toggle

Enquanto houver toggle sem resposta, ou se as configurações mudarem durante a leitura, o resultado é descartado para não desfazer a atualização otimista. O modo do ESP32 é aplicado em `settingsProvider`. Firmware sem `/estado` (404): mantém o estado local.

## Dependências cross-feature (por provider — permitido pelas regras do projeto)

| Provider externo | Feature de origem | Como é usado |
|---|---|---|
| `settingsProvider` | `config` | IP e modoUnico lidos via `ref.read` em cada toggle; modo do ESP32 gravado via `save` |
| `conectadoProvider` | `config` | Lê o estado real ao reconectar; polling só roda conectado |
| `consolesProvider` | `novo_console` | Grid exibe imagem e nome de cada canal via `ref.watch` |

Acesso direto a `data/` ou `models/` de outras features **não é permitido**.
