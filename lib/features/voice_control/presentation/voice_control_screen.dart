import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/header_bar_with_back.dart';
import 'voice_control_notifier.dart';

class VoiceControlScreen extends ConsumerStatefulWidget {
  const VoiceControlScreen({super.key});

  @override
  ConsumerState<VoiceControlScreen> createState() =>
      _VoiceControlScreenState();
}

class _VoiceControlScreenState extends ConsumerState<VoiceControlScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia o reconhecimento automaticamente ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(voiceControlProvider.notifier).iniciar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceControlProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const HeaderBarWithBack(title: 'Controle por Voz'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão principal do microfone
            _MicButton(
              isListening: state.isListening,
              disponivel: state.disponivel,
              onTap: () {
                if (state.isListening) {
                  ref.read(voiceControlProvider.notifier).parar();
                } else {
                  ref.read(voiceControlProvider.notifier).iniciar();
                }
              },
            ),
            const SizedBox(height: 32),

            // Texto reconhecido
            if (state.textoReconhecido.isNotEmpty) ...[
              Text(
                '"${state.textoReconhecido}"',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // Feedback do comando
            Text(
              state.feedback.isEmpty
                  ? 'Toque no microfone e diga um comando'
                  : state.feedback,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Guia de comandos
            _ComandosGuia(),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _MicButton extends StatelessWidget {
  final bool isListening;
  final bool disponivel;
  final VoidCallback onTap;

  const _MicButton({
    required this.isListening,
    required this.disponivel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: disponivel ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isListening ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          boxShadow: isListening
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          size: 44,
          color: isListening
              ? colorScheme.onPrimary
              : disponivel
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _ComandosGuia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        );

    return Column(
      children: [
        Text('Comandos disponíveis', style: style?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('"Ligar canal 1" · "Desligar canal 3"', style: style),
        Text('"Ligar todos" · "Desligar todos"', style: style),
      ],
    );
  }
}
