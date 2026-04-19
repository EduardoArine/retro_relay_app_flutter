# features/config/

Configurações do app: endereço IP do ESP32 e modo de operação dos relés.

## Responsabilidade

Permitir ao usuário configurar o IP manualmente ou descobri-lo via mDNS, e escolher entre modo único ou multi-canal.

## Estrutura

```
config/
  models/
    app_settings.dart       # AppSettings(ip, modoUnico) — imutável
  data/
    prefs_service.dart      # Leitura/escrita no SharedPreferences
    config_repository.dart  # Ponte entre PrefsService e os notifiers
    connectivity_provider.dart  # StreamProvider<bool> poll 15 s via /ping
  presentation/
    config_screen.dart      # UI: campos IP, toggle modo, botão "Buscar na rede"
    config_notifier.dart    # SettingsNotifier: carrega e salva AppSettings
```

## Model principal: `AppSettings`

```dart
AppSettings(ip: '192.168.4.1', modoUnico: true)
```

## Fluxo de dados

```
ConfigScreen
  → ref.watch(settingsProvider)         # lê AppSettings atual
  → ref.read(settingsProvider.notifier) # dispara saveSettings()
    → ConfigRepository.saveSettings()
      → PrefsService.save()
        → SharedPreferences
```

## Chave especial: `sharedPreferencesProvider`

Declarado em `prefs_service.dart`, sobrescrito em `main.dart`.
Qualquer provider que precisar de `SharedPreferences` deve usar:

```dart
final prefs = ref.read(sharedPreferencesProvider);
```

## mDNS — descoberta automática

`MdnsService` (em `core/network/mdns_service.dart`) descobre o ESP32 na rede local.

Estratégia em duas etapas:
1. Resolve `retro-relay.local` via `IPAddressResourceRecord` (hostname direto)
2. Fallback: busca serviços `_http._tcp` via `PtrResourceRecord` → `SrvResourceRecord` → IP

O botão "Buscar na rede" em `ConfigScreen` chama `MdnsService.discover()`, preenche o
campo IP e chama `_salvarIp()` automaticamente se encontrar.

Timeout padrão: 5 s para hostname, 2 s por etapa do fallback.
