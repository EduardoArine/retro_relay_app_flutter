// Repository de consoles cadastrados.
//
// Responsabilidades:
//   - Ser a interface entre providers/notifiers e o ConsoleStorageService
//   - Ponto de extensão para: validação de nome, cópia de imagem local,
//     migração de formato de storage
//
// Nota sobre imagem local:
//   A cópia de arquivo (XFile → filesDir) será implementada aqui na fase de
//   UI do NovoConsoleScreen, junto com o image_picker. Por ora, o repository
//   aceita apenas paths/URLs já resolvidos.
//
// O que NÃO fica aqui:
//   - Acesso direto ao SharedPreferences
//   - Lógica de toggle ou modo único (fica no CanaisNotifier)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/console_config.dart';
import 'console_storage_service.dart';

final consoleRepositoryProvider = Provider<ConsoleRepository>((ref) {
  return ConsoleRepository(ref.read(consoleStorageServiceProvider));
});

class ConsoleRepository {
  final ConsoleStorageService _storage;

  const ConsoleRepository(this._storage);

  /// Retorna todos os consoles cadastrados indexados por canal.
  Map<int, ConsoleConfig> getAll() => _storage.loadAll();

  /// Salva ou atualiza o console de um canal.
  Future<void> save(int canal, ConsoleConfig config) =>
      _storage.save(canal, config);

  /// Remove o console de um canal.
  Future<void> remove(int canal) => _storage.remove(canal);
}
