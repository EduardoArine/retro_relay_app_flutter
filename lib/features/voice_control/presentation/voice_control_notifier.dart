// Gerencia o estado do reconhecimento de voz e o parsing de comandos.
//
// Fluxo:
//   1. iniciar()  → pede permissão (se necessário), começa a escutar
//   2. SpeechToText reconhece fala → _processarComando() interpreta o texto
//   3. _processarComando() chama canaisProvider.notifier.toggleCanal() conforme o comando
//   4. parar() ou resultado final → isListening = false
//
// Comandos reconhecidos (case-insensitive, correspondência parcial):
//   "ligar canal X"   / "desligar canal X"  → toggle do canal X (1-indexado)
//   "ligar todos"     / "desligar todos"    → toggle em todos os 16 canais
//
// Por que autoDispose?
//   Quando o usuário sai de VoiceControlScreen, o microfone é liberado
//   automaticamente via ref.onDispose — sem risco de ficar gravando em background.
//
// Cross-feature: acessa canaisProvider (features/home).
// Uso de ref.read — ação pontual, sem dependência reativa.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/constants/app_constants.dart';
import '../../home/presentation/home_notifier.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class VoiceState {
  final bool isListening;
  final bool disponivel; // false se permissão negada ou device sem suporte
  final String textoReconhecido;
  final String feedback;

  const VoiceState({
    this.isListening = false,
    this.disponivel = true,
    this.textoReconhecido = '',
    this.feedback = '',
  });

  VoiceState copyWith({
    bool? isListening,
    bool? disponivel,
    String? textoReconhecido,
    String? feedback,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      disponivel: disponivel ?? this.disponivel,
      textoReconhecido: textoReconhecido ?? this.textoReconhecido,
      feedback: feedback ?? this.feedback,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final voiceControlProvider =
    NotifierProvider.autoDispose<VoiceControlNotifier, VoiceState>(
  VoiceControlNotifier.new,
);

// ─── Notifier ─────────────────────────────────────────────────────────────────

class VoiceControlNotifier extends AutoDisposeNotifier<VoiceState> {
  final _speech = SpeechToText();
  bool _initialized = false;

  @override
  VoiceState build() {
    ref.onDispose(() => _speech.stop());
    return const VoiceState();
  }

  Future<void> iniciar() async {
    if (!_initialized) {
      _initialized = await _speech.initialize(
        onError: (_) => state = state.copyWith(isListening: false),
      );
    }

    if (!_initialized) {
      state = state.copyWith(
        disponivel: false,
        feedback: 'Reconhecimento de voz indisponível neste dispositivo.',
      );
      return;
    }

    state = state.copyWith(
      isListening: true,
      textoReconhecido: '',
      feedback: 'Ouvindo...',
    );

    await _speech.listen(
      onResult: _onResult,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'pt_BR',
    );
  }

  Future<void> parar() async {
    await _speech.stop();
    state = state.copyWith(isListening: false);
  }

  void _onResult(SpeechRecognitionResult result) {
    state = state.copyWith(textoReconhecido: result.recognizedWords);

    if (result.finalResult) {
      _processarComando(result.recognizedWords);
      state = state.copyWith(isListening: false);
    }
  }

  void _processarComando(String texto) {
    final lower = texto.toLowerCase().trim();
    if (lower.isEmpty) {
      state = state.copyWith(feedback: 'Nenhum comando detectado.');
      return;
    }

    if (lower.contains('ligar todos') || lower.contains('desligar todos')) {
      for (var i = 0; i < AppConstants.totalCanais; i++) {
        ref.read(canaisProvider.notifier).toggleCanal(i);
      }
      state = state.copyWith(feedback: 'Todos os canais acionados.');
      return;
    }

    final match = RegExp(r'canal\s+(\d+)').firstMatch(lower);
    if (match != null) {
      final numero = int.tryParse(match.group(1)!);
      if (numero != null &&
          numero >= 1 &&
          numero <= AppConstants.totalCanais) {
        ref.read(canaisProvider.notifier).toggleCanal(numero - 1);
        state = state.copyWith(feedback: 'Canal $numero acionado.');
        return;
      }
    }

    state = state.copyWith(
      feedback: 'Comando não reconhecido: "$texto"',
    );
  }
}
