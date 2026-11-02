// AppBar padrão do app, no visual da página do aparelho.
//
// [title]          — texto do título (exibido em caixa alta, fonte pixel)
// [conectado]      — mostra o chip Online/Offline; null esconde o chip
// [destaque]       — título em laranja (usado na tela inicial)
// [onVoltar]       — mostra a seta de voltar no lugar da marca
// [showMicButton]  — exibe botão de microfone (usado na HomeScreen)
// [onMicTap]       — callback do botão mic; obrigatório se showMicButton = true
//
// Implementa PreferredSizeWidget para uso direto em Scaffold.appBar.
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'pixel_icon.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? conectado;
  final bool destaque;
  final VoidCallback? onVoltar;
  final bool showMicButton;
  final VoidCallback? onMicTap;

  const AppHeader({
    super.key,
    required this.title,
    this.conectado,
    this.destaque = false,
    this.onVoltar,
    this.showMicButton = false,
    this.onMicTap,
  }) : assert(
          !showMicButton || onMicTap != null,
          'onMicTap é obrigatório quando showMicButton = true',
        );

  @override
  Size get preferredSize => const Size.fromHeight(61);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      titleSpacing: onVoltar != null ? 4 : 16,
      shape: const Border(bottom: BorderSide(color: AppCores.borda)),
      title: Row(
        children: [
          if (onVoltar != null)
            IconButton(
              icon: const PixelIcon(PixelIcone.voltar),
              tooltip: 'Voltar',
              onPressed: onVoltar,
            )
          else
            const _Marca(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: fontePixel,
                fontSize: 20,
                fontVariations: const [FontVariation.weight(500)],
                letterSpacing: 0.8,
                color: destaque ? AppCores.destaque : AppCores.texto,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (showMicButton)
          IconButton(
            icon: const Icon(Icons.mic, size: 22),
            tooltip: 'Controle por voz',
            onPressed: onMicTap,
          ),
        if (conectado != null) _ChipConexao(conectado: conectado!),
        const SizedBox(width: 16),
      ],
    );
  }
}

/// Quadrado laranja com o console, como na página.
class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppCores.destaque,
        borderRadius: BorderRadius.circular(raio),
      ),
      child: const PixelIcon(PixelIcone.console, color: AppCores.fundo),
    );
  }
}

class _ChipConexao extends StatelessWidget {
  final bool conectado;

  const _ChipConexao({required this.conectado});

  @override
  Widget build(BuildContext context) {
    final cor = conectado ? AppCores.ok : AppCores.perigoTexto;
    return Semantics(
      liveRegion: true,
      label: conectado ? 'Conectado ao aparelho' : 'Sem conexão com o aparelho',
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: conectado ? AppCores.destaqueEscuro : AppCores.perigo),
          borderRadius: BorderRadius.circular(raio),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, color: cor),
            const SizedBox(width: 6),
            Text(
              conectado ? 'ONLINE' : 'OFFLINE',
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
    );
  }
}
