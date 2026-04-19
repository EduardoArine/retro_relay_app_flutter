import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/header_bar_with_back.dart';
import '../models/console_config.dart';
import 'novo_console_notifier.dart';

class NovoConsoleScreen extends ConsumerStatefulWidget {
  final int canalIndex;

  const NovoConsoleScreen({super.key, required this.canalIndex});

  @override
  ConsumerState<NovoConsoleScreen> createState() => _NovoConsoleScreenState();
}

class _NovoConsoleScreenState extends ConsumerState<NovoConsoleScreen> {
  late final TextEditingController _nomeController;
  String _imagemSelecionada = '';

  @override
  void initState() {
    super.initState();
    final config = ref.read(consolesProvider)[widget.canalIndex];
    _nomeController = TextEditingController(text: config?.nome ?? '');
    _imagemSelecionada = config?.imagem ?? '';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    await ref.read(consolesProvider.notifier).save(
          widget.canalIndex,
          ConsoleConfig(nome: nome, imagem: _imagemSelecionada),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderBarWithBack(title: 'Canal ${widget.canalIndex + 1}'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome do console',
              hintText: 'Ex: Super Nintendo',
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Text(
            'Imagem',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _ImagemSelector(
            selecionada: _imagemSelecionada,
            onSelecionada: (url) => setState(() => _imagemSelecionada = url),
          ),
          const SizedBox(height: 32),
          FilledButton(
            // Desabilita se nome vazio
            onPressed: _nomeController.text.trim().isEmpty ? null : _salvar,
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _ImagemSelector extends StatelessWidget {
  final String selecionada;
  final void Function(String url) onSelecionada;

  const _ImagemSelector({
    required this.selecionada,
    required this.onSelecionada,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.cdnImageNames.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final url = AppConstants.cdnImageUrl(AppConstants.cdnImageNames[i]);
          final isSelected = selecionada == url;

          return GestureDetector(
            onTap: () => onSelecionada(url),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 72,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
