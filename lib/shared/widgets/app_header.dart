// AppBar padrão do app.
//
// [title]          — texto do título
// [showMicButton]  — exibe botão de microfone (usado na HomeScreen)
// [onMicTap]       — callback do botão mic; obrigatório se showMicButton = true
//
// Implementa PreferredSizeWidget para uso direto em Scaffold.appBar.
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMicButton;
  final VoidCallback? onMicTap;

  const AppHeader({
    super.key,
    required this.title,
    this.showMicButton = false,
    this.onMicTap,
  }) : assert(
          !showMicButton || onMicTap != null,
          'onMicTap é obrigatório quando showMicButton = true',
        );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (showMicButton)
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Controle por voz',
            onPressed: onMicTap,
          ),
      ],
    );
  }
}
