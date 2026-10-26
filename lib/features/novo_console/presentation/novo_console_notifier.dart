// Gerencia o mapa de consoles cadastrados (canal → ConsoleConfig).
//
// Carregamento inicial síncrono — SharedPreferences já está carregado em main().
// Depois disso, sincroniza com o ESP32 (ver regras em ConsoleRepository):
//   - quando a conexão com o ESP32 volta (inclusive a primeira, logo após abrir o app)
//   - quando o app volta para o primeiro plano
//
// Este provider é consumido por:
//   - novo_console: para salvar e remover consoles (dono dos dados)
//   - home: para exibir imagem e nome de cada canal no grid
//     (via ref.watch(consolesProvider) — dependência cross-feature por provider,
//      permitida pelas regras do projeto)
//
// Dependências cross-feature (por provider):
//   - settingsProvider (config): IP do ESP32, lido no momento de cada operação
//   - conectadoProvider (config): gatilho de sincronização ao reconectar
//
// Escrita: persiste primeiro, depois atualiza estado local.
// Se a persistência falhar, o estado não é atualizado — sem risco de divergência.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_exception.dart';
import '../../config/data/connectivity_provider.dart';
import '../../config/presentation/config_notifier.dart';
import '../../novo_console/data/console_repository.dart';
import '../../novo_console/models/console_config.dart';

final consolesProvider =
    NotifierProvider<ConsolesNotifier, Map<int, ConsoleConfig>>(
  ConsolesNotifier.new,
);

class ConsolesNotifier extends Notifier<Map<int, ConsoleConfig>> {
  // Salvamentos e sincronizações rodam em fila: uma resposta antiga do ESP32
  // não pode sobrescrever uma alteração recém-feita.
  Future<void> _fila = Future.value();

  @override
  Map<int, ConsoleConfig> build() {
    ref.listen(conectadoProvider, (anterior, atual) {
      final reconectou =
          atual.valueOrNull == true && anterior?.valueOrNull != true;
      if (reconectou) sincronizar();
    }, fireImmediately: true);

    final lifecycle = AppLifecycleListener(onResume: sincronizar);
    ref.onDispose(lifecycle.dispose);

    return ref.read(consoleRepositoryProvider).getAll();
  }

  /// Lança [NetworkException] se o ESP32 recusar os dados.
  /// Sem conexão, salva localmente e envia na próxima sincronização.
  Future<void> save(int canal, ConsoleConfig config) => _enfileirar(() async {
        state = await ref
            .read(consoleRepositoryProvider)
            .save(_ip, canal, config, online: _online);
      });

  /// Lança [NetworkException] se o ESP32 recusar os dados.
  /// Sem conexão, remove localmente e envia na próxima sincronização.
  Future<void> remove(int canal) => _enfileirar(() async {
        state = await ref
            .read(consoleRepositoryProvider)
            .remove(_ip, canal, online: _online);
      });

  /// Nunca lança: em qualquer falha mantém o cadastro local até a próxima tentativa.
  Future<void> sincronizar() => _enfileirar(() async {
        try {
          state = await ref.read(consoleRepositoryProvider).sincronizar(_ip);
        } catch (_) {
          // Sem conexão, firmware sem /consoles ou resposta inesperada
        }
      });

  String get _ip => ref.read(settingsProvider).ip;

  bool get _online => ref.read(conectadoProvider).valueOrNull ?? false;

  Future<void> _enfileirar(Future<void> Function() operacao) {
    final resultado = _fila.then((_) => operacao());
    _fila = resultado.catchError((_) {});
    return resultado;
  }
}
