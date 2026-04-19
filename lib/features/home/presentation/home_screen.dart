// Tela principal do app — exibe o grid de consoles e seus toggles.
// STUB: implementação completa na Fase 6 (widgets + CanaisNotifier).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retro Relay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Controle por voz',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.voiceControl),
          ),
        ],
      ),
      body: const Center(
        child: Text('HomeScreen — em construção'),
      ),
      bottomNavigationBar: _BottomNav(current: 0),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  const _BottomNav({required this.current});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current,
      onDestinationSelected: (i) {
        final routes = [AppRoutes.home, AppRoutes.cadastro, AppRoutes.config];
        Navigator.pushReplacementNamed(context, routes[i]);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.list), label: 'Cadastro'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Config'),
      ],
    );
  }
}
