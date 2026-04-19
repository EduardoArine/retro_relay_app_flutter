// Tela de configurações — IP do ESP32, modo de operação, mDNS.
// STUB: implementação completa na Fase 6.
import 'package:flutter/material.dart';
import '../../../app/routes.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: const Center(
        child: Text('ConfigScreen — em construção'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
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
