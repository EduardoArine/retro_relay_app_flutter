// Grade de ConsoleCard: 2 colunas no celular, mais colunas em telas largas
// (cards de no mínimo 180 px, como a página do aparelho).
//
// Recebe a lista completa de canais e o mapa de configs.
// Não sabe de onde vieram os dados — isso é responsabilidade da tela.
// Não rola sozinha: fica dentro da lista da tela, abaixo do painel "Ligado agora".
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
    return LayoutBuilder(
      builder: (_, restricoes) {
        const espaco = 12.0;
        final largura = restricoes.maxWidth;
        final colunas = largura < 600 ? 2 : ((largura + espaco) / (180 + espaco)).floor();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colunas,
            mainAxisSpacing: espaco,
            crossAxisSpacing: espaco,
            childAspectRatio: 0.82,
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
      },
    );
  }
}
