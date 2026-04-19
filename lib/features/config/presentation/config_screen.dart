import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../core/network/mdns_service.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_header.dart';
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
      appBar: const AppHeader(title: 'Configurações'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Endereço IP do dispositivo',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    hintText: '192.168.4.1',
                    prefixText: 'http://',
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
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                conectado ? Icons.wifi : Icons.wifi_off,
                size: 16,
                color: conectado ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                conectado ? 'Conectado' : 'Sem conexão',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: conectado ? Colors.green : Colors.red,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _buscando ? null : _buscarNaRede,
                icon: _buscando
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search, size: 16),
                label: const Text('Buscar na rede'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          SwitchListTile(
            title: const Text('Modo único'),
            subtitle: const Text('Apenas um console ativo por vez'),
            value: settings.modoUnico,
            onChanged: _alterarModo,
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
