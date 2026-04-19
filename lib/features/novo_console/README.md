# features/novo_console/

Cadastro e edição de consoles vinculados a canais de relé.

## Responsabilidade

Permitir ao usuário associar um nome e uma imagem (CDN ou galeria local) a um canal específico do ESP32. Os dados são persistidos localmente e usados pela `home` para exibir o console no grid.

## Estrutura

```
novo_console/
  models/
    console_config.dart       # ConsoleConfig(nome, imagem) — config visual
    persisted_console.dart    # PersistedConsole(canal, nome, imagem) — para storage
  data/
    console_storage_service.dart  # Leitura/escrita JSON no SharedPreferences
    console_repository.dart       # Ponte: getAll(), save(), remove()
  presentation/
    novo_console_screen.dart  # UI: form nome + seletor de imagem
    novo_console_notifier.dart  # (Fase 6) estado do form + chamadas ao repository
```

## Formato de persistência

Os consoles são salvos como uma lista JSON sob a chave `AppConstants.prefsKeyConsoles`:

```json
[
  {"canal": 0, "nome": "Super Nintendo", "imagem": "https://..."},
  {"canal": 2, "nome": "PS1", "imagem": "/data/user/0/.../console_123.jpg"}
]
```

## Distinção de models

| Model | Para que serve |
|---|---|
| `ConsoleConfig` | Exibição na UI. Sem referência de canal. |
| `PersistedConsole` | Serialização. Inclui canal para reconstruir o Map. |

## Imagem local (Fase 6)

Quando o usuário escolher uma imagem da galeria, `ConsoleRepository` copiará o arquivo para `getApplicationDocumentsDirectory()` com nome `console_{timestamp}.jpg` e salvará o path absoluto em `ConsoleConfig.imagem`.

A UI detecta imagem local por `ConsoleConfig.isLocalImage` (`!imagem.startsWith('http')`).
