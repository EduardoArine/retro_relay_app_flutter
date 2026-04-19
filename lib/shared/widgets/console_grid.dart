// Grid 2 colunas de ConsoleCard.
//
// Recebe a lista completa de canais e o mapa de configs.
// Não sabe de onde vieram os dados — isso é responsabilidade da tela.
import 'package:flutter/material.dart';

import '../../features/home/models/canal.dart';
import '../../features/novo_console/models/console_config.dart';
import 'console_card.dart';

class ConsoleGrid extends StatelessWidget {
  final List<Canal> canais;
  final Map<int, ConsoleConfig> consoles;
  final void Function(int canalIndex) onToggle;

  const ConsoleGrid({
    super.key,
    required this.canais,
    required this.consoles,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: canais.length,
      itemBuilder: (_, i) {
        final canal = canais[i];
        return ConsoleCard(
          canal: canal,
          config: consoles[canal.index],
          onTap: () => onToggle(canal.index),
        );
      },
    );
  }
}
