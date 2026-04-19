import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/console_grid.dart';
import '../../config/data/connectivity_provider.dart';
import '../../novo_console/presentation/novo_console_notifier.dart';
import '../presentation/home_notifier.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canais = ref.watch(canaisProvider);
    final consoles = ref.watch(consolesProvider);
    final conectado = ref.watch(conectadoProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppHeader(
        title: 'Retro Relay',
        showMicButton: true,
        onMicTap: () => Navigator.pushNamed(context, AppRoutes.voiceControl),
      ),
      body: ConsoleGrid(
        canais: canais,
        consoles: consoles,
        onToggle: (index) => ref.read(canaisProvider.notifier).toggleCanal(index),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 0,
        conectado: conectado,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    const routes = [AppRoutes.home, AppRoutes.cadastro, AppRoutes.config];
    if (index != 0) Navigator.pushReplacementNamed(context, routes[index]);
  }
}
