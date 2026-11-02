// AppBar com botão de voltar explícito.
//
// Usado em telas que não fazem parte do fluxo principal da bottom nav,
// como NovoConsoleScreen e VoiceControlScreen. Mesmo visual do AppHeader,
// com a seta de voltar no lugar da marca.
import 'package:flutter/material.dart';

import 'app_header.dart';

class HeaderBarWithBack extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  /// Mostra o chip Online/Offline; null esconde o chip
  final bool? conectado;

  const HeaderBarWithBack({super.key, required this.title, this.conectado});

  @override
  Size get preferredSize => const Size.fromHeight(61);

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      title: title,
      conectado: conectado,
      onVoltar: () => Navigator.of(context).pop(),
    );
  }
}
