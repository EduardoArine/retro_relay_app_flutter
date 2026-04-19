// Card de um canal de relé.
//
// Parâmetros:
//   canal   — dados do canal (índice, nome, estado ativo)
//   config  — configuração visual do console (null = slot vazio)
//   onTap   — callback de toggle — quem chama decide o que fazer
//
// Não acessa providers — recebe tudo por parâmetro.
import 'dart:io';

import 'package:flutter/material.dart';

import '../../features/home/models/canal.dart';
import '../../features/novo_console/models/console_config.dart';

class ConsoleCard extends StatelessWidget {
  final Canal canal;
  final ConsoleConfig? config;
  final VoidCallback onTap;

  const ConsoleCard({
    super.key,
    required this.canal,
    required this.config,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAtivo = canal.ativo;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isAtivo
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surface,
          border: Border.all(
            color: isAtivo ? colorScheme.primary : colorScheme.outline,
            width: isAtivo ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildImage(colorScheme),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Text(
                canal.isEmpty ? 'Slot ${canal.index + 1}' : canal.nome,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: canal.isEmpty
                          ? colorScheme.onSurface.withValues(alpha: 0.4)
                          : colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ColorScheme colorScheme) {
    if (config == null) {
      return Icon(
        Icons.videogame_asset_outlined,
        size: 40,
        color: colorScheme.onSurface.withValues(alpha: 0.2),
      );
    }

    final errorWidget = Icon(
      Icons.broken_image_outlined,
      color: colorScheme.onSurface.withValues(alpha: 0.3),
    );

    if (config!.isLocalImage) {
      return Image.file(
        File(config!.imagem),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => errorWidget,
      );
    }

    return Image.network(
      config!.imagem,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => errorWidget,
    );
  }
}
