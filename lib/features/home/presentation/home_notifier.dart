// Gerencia a lista de 16 canais e a lógica de toggle.
//
// Regras de toggle (espelho do RelayViewModel.kt):
//   modoUnico = true:
//     - Clicar em canal inativo → ativa só ele, desativa todos os outros
//     - Clicar em canal ativo  → desativa todos (nenhum ativo)
//   modoUnico = false:
//     - Toggle simples — múltiplos canais simultâneos
//
// Estado local é atualizado imediatamente (otimista).
// A chamada ao ESP32 roda em background; ao terminar, o estado é conferido.
//
// Estado real (GET /estado):
//   Os relés também mudam pela interface web, pelo widget Android e por outros
//   celulares. O notifier lê o estado real ao reconectar, ao voltar ao app,
//   a cada AppConstants.estadoPollSeconds com o app aberto e após cada toggle.
//   Enquanto houver toggle sem resposta, a leitura é ignorada para não desfazer
//   a atualização otimista. O modo (único/multi) do ESP32 também é aplicado
//   nas configurações locais.
//
// Dependência cross-feature:
//   Lê settingsProvider (features/config) via ref.read para obter IP e modoUnico.
//   Uso de ref.read (não watch) — leitura pontual no momento da ação,
//   sem reconstrução reativa da lista de canais quando o IP muda.
//   Escuta conectadoProvider (features/config) para ler o estado ao reconectar.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/relay_api_service.dart';
import '../../config/data/connectivity_provider.dart';
import '../../config/presentation/config_notifier.dart';
import '../../novo_console/presentation/novo_console_notifier.dart';
import '../models/canal.dart';

final canaisProvider = NotifierProvider<CanaisNotifier, List<Canal>>(
  CanaisNotifier.new,
);

class CanaisNotifier extends Notifier<List<Canal>> {
  // Toggles enviados ao ESP32 ainda sem resposta.
  int _togglesPendentes = 0;
  bool _lendoEstado = false;

  @override
  List<Canal> build() {
    ref.listen(conectadoProvider, (anterior, atual) {
      final reconectou =
          atual.valueOrNull == true && anterior?.valueOrNull != true;
      if (reconectou) sincronizarEstado();
    }, fireImmediately: true);

    Timer? polling;
    void iniciarPolling() {
      polling?.cancel();
      polling = Timer.periodic(
        const Duration(seconds: AppConstants.estadoPollSeconds),
        (_) {
          // Sem conexão não tenta: cada tentativa esperaria o timeout do Dio
          if (ref.read(conectadoProvider).valueOrNull == true) {
            sincronizarEstado();
          }
        },
      );
    }

    final lifecycle = AppLifecycleListener(
      onResume: () {
        sincronizarEstado();
        iniciarPolling();
      },
      onPause: () => polling?.cancel(),
    );
    iniciarPolling();

    ref.onDispose(() {
      polling?.cancel();
      lifecycle.dispose();
    });

    return List.generate(
      AppConstants.totalCanais,
      (i) => Canal(index: i, nome: ''),
    );
  }

  void toggleCanal(int index) {
    final settings = ref.read(settingsProvider);

    if (settings.modoUnico) {
      _toggleModoUnico(index);
    } else {
      _toggleModoMulti(index);
    }

    _togglesPendentes++;
    ref
        .read(relayApiServiceProvider)
        .toggleCanal(settings.ip, index)
        .whenComplete(() {
          _togglesPendentes--;
          sincronizarEstado();
        })
        .ignore();
    _syncWidget();
  }

  /// Lê o estado real dos relés no ESP32 e aplica na lista de canais.
  /// Nunca lança: sem conexão ou com firmware anterior ao /estado, mantém o estado local.
  Future<void> sincronizarEstado() async {
    if (_lendoEstado || _togglesPendentes > 0) return;
    _lendoEstado = true;
    try {
      final settings = ref.read(settingsProvider);
      final remoto =
          await ref.read(relayApiServiceProvider).getEstado(settings.ip);

      // Um toggle ou troca de modo feitos durante a leitura valem mais que a
      // resposta antiga; a próxima leitura já traz o estado atualizado
      if (_togglesPendentes > 0 || ref.read(settingsProvider) != settings) {
        return;
      }

      if (remoto.modoUnico != settings.modoUnico) {
        await ref
            .read(settingsProvider.notifier)
            .save(settings.copyWith(modoUnico: remoto.modoUnico));
      }

      final atualizado = [
        for (final c in state)
          c.copyWith(ativo: (remoto.estado & (1 << c.index)) != 0),
      ];
      if (!listEquals(atualizado, state)) {
        state = atualizado;
        _syncWidget();
      }
    } catch (_) {
      // Sem conexão, firmware sem /estado ou resposta inesperada
    } finally {
      _lendoEstado = false;
    }
  }

  // Salva estado dos canais no SharedPreferences para o widget Android ler.
  Future<void> _syncWidget() async {
    final consoles = ref.read(consolesProvider);
    for (final canal in state) {
      await HomeWidget.saveWidgetData('canal_ativo_${canal.index}', canal.ativo);
      await HomeWidget.saveWidgetData(
          'canal_nome_${canal.index}', consoles[canal.index]?.nome ?? '');
    }
    await HomeWidget.updateWidget(
      androidName: 'RelayWidgetProvider',
    );
  }

  // Ao mudar para modo único: mantém no máximo o primeiro canal ativo.
  // Chamado pela UI (ConfigScreen) após salvar modoUnico = true.
  void applyModoUnico() {
    var firstActiveKept = false;
    final updated = <Canal>[];

    for (final canal in state) {
      if (canal.ativo && !firstActiveKept) {
        updated.add(canal);
        firstActiveKept = true;
      } else {
        updated.add(canal.copyWith(ativo: false));
      }
    }

    state = updated;
  }

  void _toggleModoUnico(int index) {
    final jaEstaAtivo = state[index].ativo;
    state = [
      for (final c in state)
        c.copyWith(ativo: jaEstaAtivo ? false : c.index == index),
    ];
  }

  void _toggleModoMulti(int index) {
    state = [
      for (final c in state)
        if (c.index == index) c.copyWith(ativo: !c.ativo) else c,
    ];
  }
}
