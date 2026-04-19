# CLAUDE.md — Retro Relay Flutter

Instruções persistentes para o Claude Code neste projeto.
Leia este arquivo antes de qualquer ação. Atualize-o quando a arquitetura evoluir.

---

## Contexto do projeto

App Flutter que replica o app Android Kotlin `retro-relay-app`.
Controla 16 relés físicos em um ESP32 via HTTP local (rede Wi-Fi).
Não há backend externo, autenticação ou banco de dados — apenas HTTP direto ao ESP32.

Workspace: `retro-relay-app-workspace/`
- `retro-relay-app/` — Android Kotlin (fonte de verdade funcional)
- `retro_relay_app_flutter/` — este projeto Flutter

---

## Arquitetura

```
lib/
  main.dart               # ProviderScope + init SharedPreferences
  app/                    # Widget raiz, rotas, tema
  core/                   # Infraestrutura compartilhada (HTTP, constantes, utils)
  features/               # Uma pasta por feature (home, cadastro, novo_console, config, voice_control)
    feature/
      data/               # Services + Repositories
      models/             # Classes de domínio imutáveis
      presentation/       # Screens + Notifiers
  shared/
    widgets/              # Widgets reutilizáveis entre features
```

Stack: `flutter_riverpod`, `dio`, `shared_preferences`.
Dependências novas requerem justificativa explícita antes de serem adicionadas.

---

## Regras de arquitetura — não viole sem justificar

1. **UI não chama Dio diretamente.** Fluxo: Screen → Notifier → Repository → Service.
2. **Services** fazem I/O (HTTP, SharedPreferences). Sem estado, sem regras de negócio.
3. **Repositories** fazem a ponte entre services e notifiers. Ponto de extensão para validação futura.
4. **Notifiers** concentram estado e regras de interface/fluxo de cada feature.
5. **Models são imutáveis** com `copyWith`. Sem `freezed` por ora.
6. **`core/` não importa de `features/`.**
7. **Features não importam de outras features** exceto quando explicitamente documentado.
8. **`shared/widgets/`** só recebe widgets usados por 2+ features.
9. **`sharedPreferencesProvider`** é declarado em `prefs_service.dart`, sobrescrito em `main.dart`.
10. **IP do ESP32 é parâmetro** em `RelayApiService` — não é estado interno do service.

---

## Regras de comportamento do Claude

### Antes de gerar código
- Resuma o que será criado e por quê.
- Liste decisões arquiteturais adotadas.
- Aponte ambiguidades antes de seguir.

### Ao criar código
- Comente apenas o WHY não-óbvio — nunca o WHAT.
- Prefira código simples e legível a abstrações prematuras.
- Não crie camadas extras (usecases, entities, domain) sem solicitação explícita.
- Não adicione dependências sem justificar.
- Não avance para a próxima fase sem sinal do usuário.

### Ao finalizar uma etapa
- Sempre sugira uma mensagem de commit no padrão: `tipo(scope): descrição curta`.
- Se criou nova subpasta estrutural, crie (ou atualize) o README dela.
- Aponte o que ficou fora do escopo e o que vem a seguir.

### Economia de tokens
- Resposta curta se a pergunta for pontual.
- Não repita código já existente ao explicar — referencie o arquivo e linha.
- Não gere código de telas completas em uma única resposta — use stubs e itere.
- Não documente o que já está nos READMEs — referencie-os.

---

## Fases de implementação

| Fase | Conteúdo | Status |
|------|----------|--------|
| 1 | Fundação: main, app, routes, theme, core/network | ✅ Concluída |
| 2 | Models + Storage: Canal, ConsoleConfig, AppSettings, PrefsService, ConsoleStorage | ✅ Concluída |
| 3 | Providers + Notifiers: SettingsNotifier, CanaisNotifier, ConsolesNotifier | ⬜ Próxima |
| 4 | Conectividade: conectadoProvider (StreamProvider, polling 15s) | ⬜ |
| 5 | Shared widgets: ConsoleCard, ConsoleGrid, AppBottomNavBar, Header | ⬜ |
| 6 | Telas completas: Home, Cadastro, NovoConsole, Config | ⬜ |
| 7 | Voz: speech_to_text + VoiceControlNotifier | ⬜ |
| 8 | mDNS: multicast_dns + MdnsService + ConfigNotifier | ⬜ |

---

## Mapeamento Kotlin → Flutter (referência)

| Kotlin | Flutter |
|---|---|
| `RelayViewModel` | `CanaisNotifier` + `SettingsNotifier` + `ConsolesNotifier` |
| `ApiService` (Ktor) | `RelayApiService` (Dio) |
| `ConsoleStorage` (DataStore) | `ConsoleStorageService` (SharedPreferences) |
| `PrefsManager` (SharedPreferences) | `PrefsService` (SharedPreferences) |
| `MdnsHelper` (NsdManager) | `MdnsService` (multicast_dns) — Fase 8 |
| `VoiceControlScreen` (SpeechRecognizer) | `VoiceControlScreen` (speech_to_text) — Fase 7 |

---

## Nota sobre a pasta `features/auth/`

Criada em sessão exploratória. **Não faz parte da arquitetura atual.**
O app não possui fluxo de autenticação. Pode ser removida com segurança.

---

## Agentes e subagentes

Claude Code suporta subagentes via ferramenta `Agent`. Tipos disponíveis no ambiente:
`Explore`, `Plan`, `general-purpose`, `claude-code-guide`.

Usos sugeridos neste projeto:
- **Explore** — para analisar o projeto Kotlin antes de migrar uma feature.
- **Plan** — para planejar a implementação de uma fase antes de codificar.
- **general-purpose** — para pesquisas cross-codebase ou buscas complexas.

Não é possível definir tipos de agentes customizados via CLAUDE.md.
Para roles específicas (ex: "arquiteto Flutter", "migrador Kotlin→Flutter"),
instrua o Claude no início da sessão com o contexto desejado.
