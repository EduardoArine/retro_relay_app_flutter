# features/novo_console/

Cadastro e edição de consoles vinculados a canais de relé.

## Responsabilidade

Permitir ao usuário associar um nome e uma imagem (CDN ou galeria local) a um canal específico do ESP32. Os dados ficam salvos no ESP32 (compartilhados com a interface web do firmware), com uma cópia local no celular, e são usados pela `home` para exibir o console no grid.

## Dependências de outras features

| Provider | Feature | Uso |
|---|---|---|
| `settingsProvider` | `config` | IP do ESP32, lido a cada salvamento/sincronização |
| `conectadoProvider` | `config` | Gatilho de sincronização quando a conexão volta |

## Sincronização com o ESP32

O firmware expõe o cadastro em `/consoles` (GET lê, POST substitui a lista inteira), no mesmo formato JSON do storage local. As regras ficam em `ConsoleRepository`:

| Situação | Comportamento |
|---|---|
| Salvar/remover com conexão | Envia ao ESP32 e grava localmente |
| Salvar/remover sem conexão (ou firmware sem `/consoles`, HTTP 404) | Grava localmente e marca como pendente (`prefsKeyConsolesPendente`) |
| ESP32 recusa os dados (HTTP 400) | Lança `NetworkException`; nada é gravado e a tela mostra o erro |
| Sincronizar com pendência | Envia o cadastro do celular |
| Primeira sincronização, ESP32 vazio e celular com consoles | Envia o cadastro do celular (migração; `prefsKeyConsolesMigrado`) |
| Sincronizar nos demais casos | O ESP32 é a fonte da verdade: substitui a cópia local |

`ConsolesNotifier` sincroniza quando a conexão volta (inclusive logo após abrir o app) e quando o app volta ao primeiro plano. Operações rodam em fila para que uma resposta antiga não sobrescreva uma alteração recente.

Limites do firmware: nome até 96 bytes UTF-8 (a UI limita a `AppConstants.nomeConsoleMaxLength` = 32 caracteres) e imagem até 256 bytes.

Imagens da galeria são paths locais do celular: na interface web e em outros celulares aparecem como ícone padrão.

## Estrutura

```
novo_console/
  models/
    console_config.dart       # ConsoleConfig(nome, imagem) — config visual
    persisted_console.dart    # PersistedConsole(canal, nome, imagem) — para storage
  data/
    console_storage_service.dart  # Leitura/escrita JSON no SharedPreferences + flags de sync
    console_repository.dart       # getAll(), save(), remove(), sincronizar() — local + ESP32
  presentation/
    novo_console_screen.dart  # UI: form nome + seletor de imagem
    novo_console_notifier.dart  # consolesProvider: estado, fila de operações e gatilhos de sync
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
