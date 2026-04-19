# features/voice_control/

Controle dos canais de relé por comandos de voz.

## Responsabilidade

Reconhecer fala do usuário via `speech_to_text`, interpretar comandos em português e acionar os canais correspondentes chamando `canaisProvider`.

## Estrutura

```
voice_control/
  presentation/
    voice_control_screen.dart      # UI: botão mic + feedback + guia de comandos
    voice_control_notifier.dart    # VoiceState + VoiceControlNotifier (autoDispose)
```

## Comandos reconhecidos

| Fala | Ação |
|---|---|
| "ligar canal X" | `toggleCanal(X - 1)` |
| "desligar canal X" | `toggleCanal(X - 1)` |
| "ligar todos" | `toggleCanal` em todos os 16 canais |
| "desligar todos" | `toggleCanal` em todos os 16 canais |

Matching via `RegExp(r'canal\s+(\d+)')` — tolerante a variações de espaçamento.
"ligar" e "desligar" têm o mesmo efeito de API — o ESP32 gerencia o estado real.

## Cross-feature: `canaisProvider`

`VoiceControlNotifier` acessa `canaisProvider` (feature `home`) via `ref.read`.
Uso de `ref.read` (não `watch`) — ação pontual, sem dependência reativa.

## Por que `autoDispose`?

Quando o usuário sai da tela (back navigation), o provider é descartado e
`_speech.stop()` é chamado via `ref.onDispose`. O microfone nunca fica ativo
em background.

## Permissão necessária (passo manual)

Adicionar em `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

O package `speech_to_text` solicita a permissão em runtime na primeira chamada
a `initialize()`, mas a declaração no manifest é obrigatória.
