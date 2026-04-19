import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_header.dart';
import '../../config/data/connectivity_provider.dart';
import '../../home/presentation/home_notifier.dart';
import '../../novo_console/models/console_config.dart';
import '../../novo_console/presentation/novo_console_notifier.dart';

class CadastroScreen extends ConsumerWidget {
  const CadastroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canais = ref.watch(canaisProvider);
    final consoles = ref.watch(consolesProvider);
    final conectado = ref.watch(conectadoProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: const AppHeader(title: 'Cadastro'),
      body: ListView.builder(
        itemCount: AppConstants.totalCanais,
        itemBuilder: (_, i) {
          final canal = canais[i];
          final config = consoles[i];
          return _CanalTile(
            index: i,
            nome: canal.isEmpty ? 'Slot ${i + 1}' : canal.nome,
            config: config,
            onEdit: () => Navigator.pushNamed(
              context,
              AppRoutes.novoConsole,
              arguments: i,
            ),
            onDelete: config != null
                ? () => _confirmarRemocao(context, ref, i, canal.nome)
                : null,
          );
        },
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
      builder: (_) => AlertDialog(
        title: const Text('Remover console'),
        content: Text('Remover "$nome" do canal ${index + 1}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await ref.read(consolesProvider.notifier).remove(index);
    }
  }
}

class _CanalTile extends StatelessWidget {
  final int index;
  final String nome;
  final ConsoleConfig? config;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const _CanalTile({
    required this.index,
    required this.nome,
    required this.config,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildThumbnail(context),
      title: Text(nome),
      subtitle: config != null ? Text(config!.nome) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: onEdit,
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remover',
              onPressed: onDelete,
            ),
        ],
      ),
      onTap: onEdit,
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    if (config == null || config!.imagem.isEmpty) {
      return CircleAvatar(
        backgroundColor: color.surfaceContainerHighest,
        child: Icon(Icons.videogame_asset_outlined, color: color.onSurface),
      );
    }
    return CircleAvatar(
      backgroundImage: NetworkImage(config!.imagem),
      backgroundColor: color.surfaceContainerHighest,
    );
  }
}
