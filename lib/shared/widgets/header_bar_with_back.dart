// AppBar com botão de voltar explícito.
//
// Usado em telas que não fazem parte do fluxo principal da bottom nav,
// como NovoConsoleScreen e VoiceControlScreen.
import 'package:flutter/material.dart';

class HeaderBarWithBack extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const HeaderBarWithBack({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: BackButton(onPressed: () => Navigator.of(context).pop()),
    );
  }
}
