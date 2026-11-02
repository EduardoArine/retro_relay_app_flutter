// Tela inicial, no visual da página do aparelho:
//   - aviso quando o ESP32 não responde (controles ficam apagados)
//   - painel "Ligado agora" com o que está ligado e o botão de desligar
//   - grade com os consoles cadastrados (toque liga/desliga)
//   - sem cadastro: convite para cadastrar o primeiro console
//
// Dependências cross-feature (por provider): consolesProvider (novo_console),
// conectadoProvider e settingsProvider (config).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/network_exception.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/console_grid.dart';
import '../../../shared/widgets/pixel_icon.dart';
import '../../config/data/connectivity_provider.dart';
import '../../config/presentation/config_notifier.dart';
import '../../novo_console/presentation/novo_console_notifier.dart';
import '../presentation/home_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canais = ref.watch(canaisProvider);
    final consoles = ref.watch(consolesProvider);
    final conectado = ref.watch(conectadoProvider).valueOrNull ?? false;
    final modoUnico = ref.watch(settingsProvider).modoUnico;

    final canaisConfigurados =
        canais.where((c) => consoles.containsKey(c.index)).toList();
    final ligados = [
      for (final c in canais)
        if (c.ativo) consoles[c.index]?.nome ?? 'Canal ${c.index + 1}',
    ];

    return Scaffold(
      appBar: AppHeader(
        title: 'Retro Relay',
        destaque: true,
        conectado: conectado,
        showMicButton: true,
        onMicTap: () => Navigator.pushNamed(context, AppRoutes.voiceControl),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (!conectado) const _AvisoOffline(),
          if (canaisConfigurados.isEmpty)
            _Vazio(onCadastrar: () => Navigator.pushNamed(
                  context,
                  AppRoutes.novoConsole,
                  arguments: _primeiroLivre(consoles.keys),
                ))
          else
            // Sem conexão o toque não chegaria ao aparelho: os controles ficam apagados
            IgnorePointer(
              ignoring: !conectado,
              child: AnimatedOpacity(
                opacity: conectado ? 1 : 0.45,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    _PainelAgora(
                      ligados: ligados,
                      modoUnico: modoUnico,
                      onDesligar: () => _desligarTudo(context, ref),
                    ),
                    const SizedBox(height: 16),
                    ConsoleGrid(
                      canais: canaisConfigurados,
                      consoles: consoles,
                      onToggle: (index) =>
                          ref.read(canaisProvider.notifier).toggleCanal(index),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 0,
        conectado: conectado,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }

  Future<void> _desligarTudo(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(canaisProvider.notifier).desligarTudo();
    } on NetworkException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao comunicar com o dispositivo')),
        );
      }
    }
  }

  static int _primeiroLivre(Iterable<int> usados) {
    for (var i = 0; i < AppConstants.totalCanais; i++) {
      if (!usados.contains(i)) return i;
    }
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    const routes = [AppRoutes.home, AppRoutes.cadastro, AppRoutes.config];
    if (index != 0) Navigator.pushReplacementNamed(context, routes[index]);
  }
}

class _AvisoOffline extends StatelessWidget {
  const _AvisoOffline();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: AppCores.painel,
          borderRadius: BorderRadius.circular(raio),
          border: const Border(left: BorderSide(color: AppCores.perigo, width: 3)),
        ),
        child: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Sem conexão com o Retro Relay\n',
                style: TextStyle(color: AppCores.texto, fontWeight: FontWeight.w600),
              ),
              TextSpan(text: 'Confira se o celular está no mesmo Wi-Fi. Tentando de novo…'),
            ],
          ),
          style: TextStyle(fontSize: 14, height: 1.5, color: AppCores.texto2),
        ),
      ),
    );
  }
}

class _PainelAgora extends StatelessWidget {
  final List<String> ligados;
  final bool modoUnico;
  final VoidCallback onDesligar;

  const _PainelAgora({
    required this.ligados,
    required this.modoUnico,
    required this.onDesligar,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = ligados.isEmpty
        ? 'Nenhum console'
        : ligados.length == 1
            ? ligados.first
            : '${ligados.length} consoles';

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppCores.superficie,
          borderRadius: BorderRadius.circular(raio),
          border: Border.all(color: AppCores.destaqueEscuro),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('LIGADO AGORA', style: estiloRotulo),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      fontFamily: fontePixel,
                      fontSize: 22,
                      height: 1.2,
                      fontVariations: const [FontVariation.weight(500)],
                      color: ligados.isEmpty ? AppCores.apagado : AppCores.destaque,
                    ),
                  ),
                ),
                if (ligados.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onDesligar,
                    icon: const PixelIcon(PixelIcone.energia, size: 16),
                    label: Text(ligados.length > 1 ? 'Desligar todos' : 'Desligar'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(fontFamily: fonteTexto, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              modoUnico
                  ? 'Modo único: ligar um console desliga o outro'
                  : 'Modo vários: os consoles podem ficar ligados juntos',
              style: const TextStyle(fontSize: 14, color: AppCores.apagado),
            ),
          ],
        ),
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  final VoidCallback onCadastrar;

  const _Vazio({required this.onCadastrar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: CustomPaint(
        painter: const _BordaTracejada(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
          child: Column(
            children: [
              const PixelIcon(PixelIcone.console, size: 48, color: AppCores.destaque),
              const SizedBox(height: 12),
              const Text(
                'NENHUM CONSOLE',
                style: TextStyle(
                  fontFamily: fontePixel,
                  fontSize: 20,
                  fontVariations: [FontVariation.weight(500)],
                  color: AppCores.texto,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cadastre os consoles ligados ao Retro Relay para controlá-los por aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppCores.texto2),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onCadastrar,
                icon: const PixelIcon(PixelIcone.mais, size: 16),
                label: const Text('Cadastrar console'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Borda tracejada do estado vazio (a página usa border: dashed).
class _BordaTracejada extends CustomPainter {
  const _BordaTracejada();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppCores.bordaForte
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final caminho = Path()
      ..addRRect(RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(0.5),
        const Radius.circular(raio),
      ));
    for (final metrica in caminho.computeMetrics()) {
      for (var d = 0.0; d < metrica.length; d += 9) {
        canvas.drawPath(metrica.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BordaTracejada old) => false;
}
