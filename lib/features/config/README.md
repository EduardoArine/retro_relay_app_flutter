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
    mdns_service.dart       # (Fase 8) Descoberta automática via multicast_dns
  presentation/
    config_screen.dart      # UI: campos IP, toggle modo, botão mDNS
    config_notifier.dart    # (Fase 6) SettingsNotifier: carrega e salva AppSettings
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

## Fase futura: mDNS

`MdnsService` usará o package `multicast_dns` para descobrir o ESP32 na rede local.
Ao encontrar, atualizará o IP via `SettingsNotifier.updateIp()`.
