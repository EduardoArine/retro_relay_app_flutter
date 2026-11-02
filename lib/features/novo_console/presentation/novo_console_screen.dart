import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/network_exception.dart';
import '../../../shared/widgets/header_bar_with_back.dart';
import '../../../shared/widgets/pixel_icon.dart';
import '../../config/data/connectivity_provider.dart';
import '../models/console_config.dart';
import 'novo_console_notifier.dart';

/// Opção da escolha de imagem: url vazia = "Sem imagem".
typedef _Opcao = ({String url, String nome});

List<_Opcao> _opcoes(List<(String, String)> catalogo) => [
      for (final (arquivo, nome) in catalogo)
        (url: AppConstants.cdnImageUrl(arquivo), nome: nome),
    ];

final _consoles = _opcoes(AppConstants.imagensConsoles);
final _acessorios = _opcoes(AppConstants.imagensAcessorios);

class NovoConsoleScreen extends ConsumerStatefulWidget {
  final int canalIndex;

  const NovoConsoleScreen({super.key, required this.canalIndex});

  @override
  ConsumerState<NovoConsoleScreen> createState() => _NovoConsoleScreenState();
}

class _NovoConsoleScreenState extends ConsumerState<NovoConsoleScreen> {
  late final TextEditingController _nomeController;
  String _imagemSelecionada = '';

  /// Nome sugerido pela imagem escolhida: troca junto com a imagem enquanto
  /// a pessoa não escrever outro (mesma regra da página).
  String _sugerido = '';

  @override
  void initState() {
    super.initState();
    final config = ref.read(consolesProvider)[widget.canalIndex];
    _nomeController = TextEditingController(text: config?.nome ?? '');
    _imagemSelecionada = config?.imagem ?? '';
    _sugerido = [..._consoles, ..._acessorios]
            .where((o) => o.url == _imagemSelecionada)
            .firstOrNull
            ?.nome ??
        '';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _escolher(_Opcao opcao) {
    setState(() {
      _imagemSelecionada = opcao.url;
      final nome = _nomeController.text;
      if (opcao.url.isNotEmpty && (nome.trim().isEmpty || nome == _sugerido)) {
        _nomeController.text = opcao.nome;
      }
      _sugerido = opcao.url.isEmpty ? '' : opcao.nome;
    });
  }

  Future<void> _salvar() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    try {
      await ref.read(consolesProvider.notifier).save(
            widget.canalIndex,
            ConsoleConfig(nome: nome, imagem: _imagemSelecionada),
          );
    } on NetworkException catch (e) {
      // ESP32 recusou os dados — sem conexão não cai aqui (salva e envia depois)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível salvar: ${e.message}')),
        );
      }
      return;
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final conectado = ref.watch(conectadoProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: HeaderBarWithBack(
        title: 'Canal ${widget.canalIndex + 1}',
        conectado: conectado,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const Text('NOME', style: estiloRotulo),
                const SizedBox(height: 8),
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(hintText: 'Ex: Super Nintendo'),
                  style: const TextStyle(fontSize: 16),
                  textCapitalization: TextCapitalization.words,
                  maxLength: AppConstants.nomeConsoleMaxLength,
                  // O limite vale, mas sem o contador "0/32" (a página não mostra)
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ligue o aparelho na saída ${widget.canalIndex + 1} do Retro Relay.',
                  style: const TextStyle(fontSize: 14, color: AppCores.apagado),
                ),
                const SizedBox(height: 24),
                const Text('IMAGEM', style: estiloRotulo),
                const SizedBox(height: 10),
                const _Grupo('Consoles', primeiro: true),
                _GradeImagens(
                  opcoes: [(url: '', nome: 'Sem imagem'), ..._consoles],
                  selecionada: _imagemSelecionada,
                  onEscolher: _escolher,
                ),
                const _Grupo('Acessórios e aparelhos'),
                _GradeImagens(
                  opcoes: _acessorios,
                  selecionada: _imagemSelecionada,
                  onEscolher: _escolher,
                ),
              ],
            ),
          ),
          // Salvar sempre à vista, como a barra fixa da página
          Container(
            decoration: const BoxDecoration(
              color: AppCores.fundo,
              border: Border(top: BorderSide(color: AppCores.borda)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _nomeController.text.trim().isEmpty ? null : _salvar,
                  child: const Text('Salvar'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  final String titulo;
  final bool primeiro;

  const _Grupo(this.titulo, {this.primeiro = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: primeiro ? 0 : 16, bottom: 8),
      child: Text(titulo, style: const TextStyle(fontSize: 13, color: AppCores.texto2)),
    );
  }
}

/// Grade de opções: colunas de no mínimo 96 px, como a página.
class _GradeImagens extends StatelessWidget {
  final List<_Opcao> opcoes;
  final String selecionada;
  final void Function(_Opcao) onEscolher;

  const _GradeImagens({
    required this.opcoes,
    required this.selecionada,
    required this.onEscolher,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, restricoes) {
        const espaco = 8.0;
        final colunas = ((restricoes.maxWidth + espaco) / (96 + espaco)).floor().clamp(1, 8);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: opcoes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colunas,
            mainAxisSpacing: espaco,
            crossAxisSpacing: espaco,
            mainAxisExtent: 104,
          ),
          itemBuilder: (_, i) => _OpcaoImagem(
            opcao: opcoes[i],
            selecionada: opcoes[i].url == selecionada,
            onTap: () => onEscolher(opcoes[i]),
          ),
        );
      },
    );
  }
}

class _OpcaoImagem extends StatelessWidget {
  final _Opcao opcao;
  final bool selecionada;
  final VoidCallback onTap;

  const _OpcaoImagem({
    required this.opcao,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final semImagem = PixelIcon(PixelIcone.console, size: 28, color: AppCores.bordaForte);
    return Semantics(
      selected: selecionada,
      button: true,
      label: opcao.nome,
      excludeSemantics: true,
      child: Material(
        color: selecionada ? AppCores.painel : AppCores.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raio),
          side: BorderSide(
            color: selecionada ? AppCores.destaque : AppCores.borda,
            width: selecionada ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(raio),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Column(
              children: [
                Container(
                  height: 56,
                  alignment: Alignment.center,
                  // Halo claro: destaca os consoles pretos no card escuro
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.5,
                      colors: [Color(0x1AF3E9D2), Color(0x00F3E9D2)],
                    ),
                  ),
                  child: opcao.url.isEmpty
                      ? semImagem
                      : Image.network(
                          opcao.url,
                          height: 56,
                          width: 56,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none, // pixel art sem borrar
                          errorBuilder: (_, _, _) => semImagem,
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  opcao.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    color: selecionada ? AppCores.texto : AppCores.texto2,
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
