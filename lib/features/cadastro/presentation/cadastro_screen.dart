// Tela de cadastro de consoles — lista os 16 canais disponíveis.
// STUB: implementação completa na Fase 6.
import 'package:flutter/material.dart';
import '../../../app/routes.dart';

class CadastroScreen extends StatelessWidget {
  const CadastroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: const Center(
        child: Text('CadastroScreen — em construção'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (i) {
          final routes = [AppRoutes.home, AppRoutes.cadastro, AppRoutes.config];
          Navigator.pushReplacementNamed(context, routes[i]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Cadastro'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}
