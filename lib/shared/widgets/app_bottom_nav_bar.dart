// Barra de abas inferior, no visual da página do aparelho.
//
// [selectedIndex] — índice da aba atual (0=Consoles, 1=Cadastro, 2=Ajustes)
// [conectado]     — acende um LED vermelho em Ajustes quando false
// [onTap]         — callback com o índice selecionado
//
// A tela obtém [conectado] via:
//   ref.watch(conectadoProvider).valueOrNull ?? false
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'pixel_icon.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool conectado;
  final void Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.conectado,
    required this.onTap,
  });

  static const _abas = [
    (PixelIcone.console, 'Consoles'),
    (PixelIcone.lista, 'Cadastro'),
    (PixelIcone.ajustes, 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppCores.superficie,
        border: Border(top: BorderSide(color: AppCores.borda)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _abas.length; i++)
                Expanded(
                  child: _Aba(
                    icone: _abas[i].$1,
                    rotulo: _abas[i].$2,
                    selecionada: i == selectedIndex,
                    alerta: i == 2 && !conectado,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Aba extends StatelessWidget {
  final PixelIcone icone;
  final String rotulo;
  final bool selecionada;
  final bool alerta;
  final VoidCallback onTap;

  const _Aba({
    required this.icone,
    required this.rotulo,
    required this.selecionada,
    required this.alerta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = selecionada ? AppCores.destaque : AppCores.apagado;
    return Semantics(
      selected: selecionada,
      button: true,
      label: alerta ? '$rotulo, sem conexão' : rotulo,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Traço laranja em cima da aba atual
            if (selecionada)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(height: 2, color: AppCores.destaque),
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      PixelIcon(icone, color: cor),
                      if (alerta)
                        Positioned(
                          top: -2,
                          right: -6,
                          child: Container(width: 6, height: 6, color: AppCores.perigo),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rotulo.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      color: cor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
