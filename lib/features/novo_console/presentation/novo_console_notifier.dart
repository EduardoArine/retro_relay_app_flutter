// Gerencia o mapa de consoles cadastrados (canal → ConsoleConfig).
//
// Carregamento inicial síncrono — SharedPreferences já está carregado em main().
//
// Este provider é consumido por:
//   - novo_console: para salvar e remover consoles (dono dos dados)
//   - home: para exibir imagem e nome de cada canal no grid
//     (via ref.watch(consolesProvider) — dependência cross-feature por provider,
//      permitida pelas regras do projeto)
//
// Escrita: persiste primeiro, depois atualiza estado local.
// Se a persistência falhar, o estado não é atualizado — sem risco de divergência.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../novo_console/data/console_repository.dart';
import '../../novo_console/models/console_config.dart';

final consolesProvider =
    NotifierProvider<ConsolesNotifier, Map<int, ConsoleConfig>>(
  ConsolesNotifier.new,
);

class ConsolesNotifier extends Notifier<Map<int, ConsoleConfig>> {
  @override
  Map<int, ConsoleConfig> build() {
    return ref.read(consoleRepositoryProvider).getAll();
  }

  Future<void> save(int canal, ConsoleConfig config) async {
    await ref.read(consoleRepositoryProvider).save(canal, config);
    state = {...state, canal: config};
  }

  Future<void> remove(int canal) async {
    await ref.read(consoleRepositoryProvider).remove(canal);
    state = Map.from(state)..remove(canal);
  }
}
