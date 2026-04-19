# CLAUDE.md — retro_relay_app_flutter

> Regras gerais de trabalho estão em `../CLAUDE.md` (workspace).
> Este arquivo cobre apenas o que é específico do projeto Flutter.

---

## Arquitetura obrigatória

```
lib/
  main.dart               # ProviderScope + init SharedPreferences
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

## Contratos que não se quebram

| Regra | Motivo |
|---|---|
| UI não acessa Dio | Fluxo: Screen → Notifier → Repository → Service |
| `core/` não importa `features/` | Evita acoplamento circular |
| Feature não importa outra feature | Isolamento — exceto se documentado |
| `shared/widgets/` só para 2+ features | Evita over-sharing prematuro |
| Models imutáveis com `copyWith` | Compatibilidade com Riverpod |
| IP do ESP32 como parâmetro no service | IP muda em runtime (mDNS / config) |
| `sharedPreferencesProvider` declarado em `prefs_service.dart` | Override em `main.dart` — não importar `main` de features |

---

## Antes de alterar estrutura

Se a mudança envolve:
- nova pasta de feature
- nova camada (ex: usecases)
- nova dependência
- refactor cross-feature

→ **Explique o impacto e aguarde confirmação antes de criar código.**

---

## Ao criar novos arquivos

- Nova feature → README em `features/{feature}/README.md`
- Nova subpasta estrutural → README ou nota no README pai
- Não criar README onde já existe — atualizar o existente

---

## Fases — status atual

| # | Conteúdo | Status |
|---|---|---|
| 1 | Fundação: main, app, routes, theme, core/network | ✅ |
| 2 | Models + Storage: Canal, ConsoleConfig, AppSettings, prefs, storage | ✅ |
| 3 | Providers + Notifiers: SettingsNotifier, CanaisNotifier, ConsolesNotifier | ⬜ próxima |
| 4 | Conectividade: `conectadoProvider` (StreamProvider, poll 15 s) | ⬜ |
| 5 | Shared widgets: ConsoleCard, ConsoleGrid, AppBottomNavBar, Header | ⬜ |
| 6 | Telas completas: Home, Cadastro, NovoConsole, Config | ⬜ |
| 7 | Voz: `speech_to_text` + VoiceControlNotifier | ⬜ |
| 8 | mDNS: `multicast_dns` + MdnsService | ⬜ |

Não avance de fase sem sinal explícito.

---

## Nota: `features/auth/` é órfã

Criada em sessão exploratória. Não faz parte da arquitetura.
Pode ser removida com segurança quando conveniente.
