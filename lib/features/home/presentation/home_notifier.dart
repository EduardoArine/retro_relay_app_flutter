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
// A chamada ao ESP32 é fire-and-forget — sem aguardar confirmação.
//
// Dependência cross-feature:
//   Lê settingsProvider (features/config) via ref.read para obter IP e modoUnico.
//   Uso de ref.read (não watch) — leitura pontual no momento da ação,
//   sem reconstrução reativa da lista de canais quando o IP muda.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/relay_api_service.dart';
import '../../config/presentation/config_notifier.dart';
import '../models/canal.dart';

final canaisProvider = NotifierProvider<CanaisNotifier, List<Canal>>(
  CanaisNotifier.new,
);

class CanaisNotifier extends Notifier<List<Canal>> {
  @override
  List<Canal> build() {
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

    ref.read(relayApiServiceProvider).toggleCanal(settings.ip, index).ignore();
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
