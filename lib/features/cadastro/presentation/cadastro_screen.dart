// Cadastro, no visual da página do aparelho:
//   - "Consoles · N de 16": lista dos canais usados, com editar e remover
//   - "Canais livres": atalhos para cadastrar em cada saída vazia
//
// Dependências cross-feature (por provider): consolesProvider (novo_console)
// e conectadoProvider (config).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/network_exception.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/borda_tracejada.dart';
import '../../../shared/widgets/console_card.dart';
import '../../../shared/widgets/grupo.dart';
import '../../../shared/widgets/pixel_icon.dart';
import '../../config/data/connectivity_provider.dart';
import '../../novo_console/models/console_config.dart';
import '../../novo_console/presentation/novo_console_notifier.dart';

class CadastroScreen extends ConsumerWidget {
  const CadastroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consoles = ref.watch(consolesProvider);
    final conectado = ref.watch(conectadoProvider).valueOrNull ?? false;

    final usados = [
      for (var i = 0; i < AppConstants.totalCanais; i++)
        if (consoles.containsKey(i)) i,
    ];
    final livres = [
      for (var i = 0; i < AppConstants.totalCanais; i++)
        if (!consoles.containsKey(i)) i,
    ];
    void editar(int i) => Navigator.pushNamed(context, AppRoutes.novoConsole, arguments: i);

    return Scaffold(
      appBar: AppHeader(title: 'Cadastro', conectado: conectado),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (usados.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 10),
              child: Text('CONSOLES · 0 DE ${AppConstants.totalCanais}', style: estiloRotulo),
            ),
            const Text(
              'Nenhum console cadastrado ainda. Escolha abaixo a saída do Retro Relay em que o console está ligado.',
              style: TextStyle(fontSize: 14, color: AppCores.apagado),
            ),
          ] else
            Grupo(
              titulo: 'Consoles · ${usados.length} de ${AppConstants.totalCanais}',
              linhas: [
                for (final i in usados)
                  _ItemConsole(
                    index: i,
                    config: consoles[i]!,
                    onEditar: () => editar(i),
                    onRemover: () => _confirmarRemocao(context, ref, i, consoles[i]!.nome),
                  ),
              ],
            ),
          if (livres.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 24, bottom: 10),
              child: Text('CANAIS LIVRES', style: estiloRotulo),
            ),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
              children: [
                for (final i in livres) _CanalLivre(index: i, onTap: () => editar(i)),
              ],
            ),
          ],
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 1,
        conectado: conectado,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    const routes = [AppRoutes.home, AppRoutes.cadastro, AppRoutes.config];
    if (index != 1) Navigator.pushReplacementNamed(context, routes[index]);
  }

  Future<void> _confirmarRemocao(
    BuildContext context,
    WidgetRef ref,
    int index,
    String nome,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('REMOVER CONSOLE'),
        content: Text(
          'Remover "$nome" do canal ${index + 1}?',
          style: const TextStyle(color: AppCores.texto2),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppCores.perigo,
              foregroundColor: AppCores.texto,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await ref.read(consolesProvider.notifier).remove(index);
    } on NetworkException catch (e) {
      // ESP32 recusou a alteração — sem conexão não cai aqui (remove e envia depois)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível remover: ${e.message}')),
        );
      }
    }
  }
}

class _ItemConsole extends StatelessWidget {
  final int index;
  final ConsoleConfig config;
  final VoidCallback onEditar;
  final VoidCallback onRemover;

  const _ItemConsole({
    required this.index,
    required this.config,
    required this.onEditar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEditar,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 68),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  rotuloCanal(index),
                  style: const TextStyle(
                    fontFamily: fontePixel,
                    fontSize: 12,
                    letterSpacing: 1,
                    fontVariations: [FontVariation.weight(500)],
                    color: AppCores.apagado,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _Miniatura(imagem: config.imagem, local: config.isLocalImage),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  config.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const PixelIcon(PixelIcone.editar),
                tooltip: 'Editar ${config.nome}',
                onPressed: onEditar,
              ),
              IconButton(
                icon: const PixelIcon(PixelIcone.remover, color: AppCores.perigoTexto),
                tooltip: 'Remover ${config.nome}',
                onPressed: onRemover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  final String imagem;
  final bool local;

  const _Miniatura({required this.imagem, required this.local});

  @override
  Widget build(BuildContext context) {
    const semImagem = PixelIcon(PixelIcone.console, size: 28, color: AppCores.bordaForte);
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          radius: 0.5,
          colors: [Color(0x1AF3E9D2), Color(0x00F3E9D2)],
        ),
      ),
      child: imagem.isEmpty
          ? semImagem
          : local
              ? Image.file(File(imagem), fit: BoxFit.contain, errorBuilder: (_, _, _) => semImagem)
              : Image.network(
                  imagem,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (_, _, _) => semImagem,
                ),
    );
  }
}

/// Atalho tracejado "+ CH 07" para cadastrar numa saída vazia.
class _CanalLivre extends StatelessWidget {
  final int index;
  final VoidCallback onTap;

  const _CanalLivre({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Cadastrar no canal ${index + 1}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(raio),
        child: CustomPaint(
          painter: const BordaTracejada(traco: 4, espaco: 3),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PixelIcon(PixelIcone.mais, size: 12, color: AppCores.texto2),
                const SizedBox(width: 6),
                Text(
                  rotuloCanal(index),
                  style: const TextStyle(
                    fontFamily: fontePixel,
                    fontSize: 14,
                    letterSpacing: 0.8,
                    fontVariations: [FontVariation.weight(500)],
                    color: AppCores.texto2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
