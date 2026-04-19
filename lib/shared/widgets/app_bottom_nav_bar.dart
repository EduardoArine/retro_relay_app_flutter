// Bottom navigation bar com indicador de conectividade.
//
// [selectedIndex] — índice da aba atual (0=Home, 1=Cadastro, 2=Config)
// [conectado]     — exibe badge vermelho no ícone Config quando false
// [onTap]         — callback com o índice selecionado
//
// A tela obtém [conectado] via:
//   ref.watch(conectadoProvider).valueOrNull ?? false
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Icons.list_outlined),
          selectedIcon: Icon(Icons.list),
          label: 'Cadastro',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: !conectado,
            backgroundColor: Colors.red,
            child: const Icon(Icons.settings_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: !conectado,
            backgroundColor: Colors.red,
            child: const Icon(Icons.settings),
          ),
          label: 'Config',
        ),
      ],
    );
  }
}
