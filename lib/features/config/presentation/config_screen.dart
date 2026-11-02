import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/network/mdns_service.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/grupo.dart';
import '../../config/data/connectivity_provider.dart';
import '../../home/presentation/home_notifier.dart';
import 'config_notifier.dart';

class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  late final TextEditingController _ipController;
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    // ref.read — leitura pontual; não recriar controller a cada rebuild
    _ipController = TextEditingController(text: ref.read(settingsProvider).ip);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _buscarNaRede() async {
    setState(() => _buscando = true);
    final ip = await ref.read(mdnsServiceProvider).discover();
    if (!mounted) return;
    setState(() => _buscando = false);

    if (ip != null) {
      _ipController.text = ip;
      await _salvarIp();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispositivo não encontrado na rede')),
      );
    }
  }

  Future<void> _salvarIp() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) return;
    await ref.read(settingsProvider.notifier).updateIp(ip);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IP salvo')),
      );
    }
  }

  Future<void> _alterarModo(bool modoUnico) async {
    await ref.read(settingsProvider.notifier).updateModoUnico(modoUnico);

    // Ao ativar modo único: mantém apenas o primeiro canal ativo
    if (modoUnico) {
      ref.read(canaisProvider.notifier).applyModoUnico();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final conectado = ref.watch(conectadoProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppHeader(title: 'Ajustes', conectado: conectado),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Grupo(
            titulo: 'Aparelho',
            linhas: [
              LinhaGrupo(
                titulo: 'Retro Relay',
                subtitulo: 'http://${settings.ip}',
                trailing: _EstadoConexao(conectado: conectado),
              ),
              LinhaGrupo(
                titulo: 'Modo único',
                subtitulo: 'Ligar um console desliga o que estiver ligado',
                trailing: Switch(value: settings.modoUnico, onChanged: _alterarModo),
                onTap: () => _alterarModo(!settings.modoUnico),
              ),
            ],
          ),
          Grupo(
            titulo: 'Conexão',
            linhas: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Endereço do aparelho', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    const Text(
                      'Normalmente é encontrado sozinho. Use se o app não achar o Retro Relay.',
                      style: TextStyle(fontSize: 14, color: AppCores.apagado),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ipController,
                            decoration: const InputDecoration(
                              hintText: '192.168.4.1',
                              prefixText: 'http://',
                              isDense: true,
                            ),
                            keyboardType: TextInputType.number,
                            onSubmitted: (_) => _salvarIp(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _salvarIp,
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              LinhaGrupo(
                titulo: 'Procurar na rede',
                subtitulo: 'Acha o Retro Relay no Wi-Fi e salva o endereço',
                trailing: OutlinedButton(
                  onPressed: _buscando ? null : _buscarNaRede,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: _buscando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Buscar'),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 2,
        conectado: conectado,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    const routes = [AppRoutes.home, AppRoutes.cadastro, AppRoutes.config];
    if (index != 2) Navigator.pushReplacementNamed(context, routes[index]);
  }
}

/// LED e texto do estado da conexão, como na página.
class _EstadoConexao extends StatelessWidget {
  final bool conectado;

  const _EstadoConexao({required this.conectado});

  @override
  Widget build(BuildContext context) {
    final cor = conectado ? AppCores.ok : AppCores.perigoTexto;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, color: cor),
        const SizedBox(width: 6),
        Text(
          conectado ? 'CONECTADO' : 'SEM CONEXÃO',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: cor),
        ),
      ],
    );
  }
}
