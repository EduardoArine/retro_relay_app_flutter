# CLAUDE.md — retro_relay_app_flutter

> Regras gerais de trabalho estão em `../CLAUDE.md` (workspace).
> Este arquivo cobre apenas o que é específico do projeto Flutter.

---

## Arquitetura obrigatória

```
lib/
  main.dart               # entry point — ProviderScope envolve o app
  app/                    # widget raiz, rotas, tema
  core/                   # infraestrutura compartilhada — sem features aqui
    constants/            # só const — sem lógica
    network/              # Dio, RelayApiService, NetworkException
    utils/
  features/{feature}/
    data/                 # services + repositories
    models/               # classes imutáveis com copyWith
    presentation/         # screens + notifiers
  shared/widgets/         # widgets usados por 2+ features
```

**Stack:** `flutter_riverpod` · `dio` · `shared_preferences`
Nova dependência → justifique antes de adicionar.

---

## Convenções de nomenclatura

| Elemento | Padrão | Exemplo |
|---|---|---|
| Arquivos Dart | `snake_case` | `canal_notifier.dart` |
| Classes | `PascalCase` | `CanaisNotifier` |
| Providers | sufixo `Provider` | `canaisProvider` |
| Notifiers | sufixo `Notifier` | `CanaisNotifier` |
| Services | sufixo `Service` | `RelayApiService` |
| Repositories | sufixo `Repository` | `ConsoleRepository` |
| Screens | sufixo `Screen` | `HomeScreen` |
| Widgets shared | nome descritivo sem sufixo | `ConsoleCard`, `AppHeader` |

---

## Contratos que não se quebram

| Regra | Motivo |
|---|---|
| UI não acessa Dio | Fluxo: Screen → Notifier → Repository → Service |
| `core/` não importa `features/` | Evita acoplamento circular |
| Feature não importa `data/` ou `models/` de outra feature | Evita acoplamento de implementação |
| Feature pode usar provider de outra feature via `ref.watch/read` | Provider é a interface pública entre features |
| Dependência entre features deve ser documentada no README | Rastreabilidade — quem depende de quem |
| `shared/widgets/` só para 2+ features | Evita over-sharing prematuro |
| Models imutáveis com `copyWith` | Compatibilidade com Riverpod |
| IP do ESP32 como parâmetro no service | IP muda em runtime (mDNS / config) |

---

## Controle de escopo por etapa

Antes de gerar código, liste os arquivos que serão criados ou alterados.
Não crie mais de ~5 arquivos sem confirmação explícita.
Prefira entregas pequenas e verificáveis — stubs compiláveis > implementação parcial.

Alterações que exigem explicação de impacto **antes** de qualquer código:
- nova pasta de feature ou subpasta estrutural
- nova camada (ex: usecases, domain, entities)
- nova dependência externa
- refactor que toca mais de uma feature

---

## Atualização de documentação

| Evento | Ação obrigatória |
|---|---|
| Nova feature criada | Criar `features/{feature}/README.md` |
| Nova regra arquitetural | Atualizar seção relevante neste arquivo |
| Nova subpasta estrutural | README ou nota no README da pasta pai |
| README já existe | Atualizar — nunca duplicar |
| Arquivo órfão removido | Registrar motivo no commit ou no README da feature |

---

## Fases — status atual

> ✅ = código existe, compila e foi revisado. ⬜ = não iniciado. 🔄 = em andamento.

| # | Conteúdo | Status |
|---|---|---|
| 1 | Fundação: main, app, routes, theme, core/network | ✅ |
| 2 | Models + Storage: Canal, ConsoleConfig, AppSettings, prefs, storage | ✅ |
| 3 | Providers + Notifiers: SettingsNotifier, CanaisNotifier, ConsolesNotifier | ✅ |
| 4 | Conectividade: `conectadoProvider` (StreamProvider, poll 15 s) | ✅ |
| 5 | Shared widgets: ConsoleCard, ConsoleGrid, AppBottomNavBar, Header | ✅ |
| 6 | Telas completas: Home, Cadastro, NovoConsole, Config | ✅ |
| 7 | Voz: `speech_to_text` + VoiceControlNotifier | ⬜ |
| 8 | mDNS: `multicast_dns` + MdnsService | ⬜ |

Não avance de fase sem sinal explícito.

---

## Nota: `features/auth/` é órfã

Criada em sessão exploratória. Não faz parte da arquitetura.
Pode ser removida com segurança quando conveniente.
