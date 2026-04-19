// Persistência dos consoles cadastrados no SharedPreferences.
//
// Responsabilidades:
//   - Serializar Map<int, ConsoleConfig> como lista JSON em uma única chave
//   - Deserializar de volta ao carregar
//   - Operações: loadAll, save(canal, config), remove(canal)
//
// Formato no SharedPreferences (chave: AppConstants.prefsKeyConsoles):
//   JSON string de List<PersistedConsole.toJson()>
//   Exemplo: [{"canal":0,"nome":"Super Nintendo","imagem":"https://..."}]
//
// O que NÃO fica aqui:
//   - Validação de dados
//   - Cópia de arquivos locais (fica em ConsoleRepository)
//   - Estado reativo

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../config/data/prefs_service.dart';
import '../models/console_config.dart';
import '../models/persisted_console.dart';

final consoleStorageServiceProvider = Provider<ConsoleStorageService>((ref) {
  return ConsoleStorageService(ref.read(sharedPreferencesProvider));
});

class ConsoleStorageService {
  final SharedPreferences _prefs;

  const ConsoleStorageService(this._prefs);

  /// Carrega todos os consoles salvos como `Map<canalIndex, ConsoleConfig>`.
  /// Retorna mapa vazio se não houver dados ou se houver erro de parsing.
  Map<int, ConsoleConfig> loadAll() {
    final raw = _prefs.getString(AppConstants.prefsKeyConsoles);
    if (raw == null || raw.isEmpty) return {};

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return {
        for (final item in list)
          (item as Map<String, dynamic>)['canal'] as int:
              PersistedConsole.fromJson(item).toConsoleConfig(),
      };
    } catch (_) {
      return {};
    }
  }

  /// Salva ou atualiza o console de um canal específico.
  Future<void> save(int canal, ConsoleConfig config) async {
    final current = loadAll();
    current[canal] = config;
    await _persist(current);
  }

  /// Remove o console de um canal. Não lança erro se o canal não existir.
  Future<void> remove(int canal) async {
    final current = loadAll();
    if (!current.containsKey(canal)) return;
    current.remove(canal);
    await _persist(current);
  }

  Future<void> _persist(Map<int, ConsoleConfig> consoles) async {
    final list = consoles.entries
        .map((e) => PersistedConsole.fromConsoleConfig(e.key, e.value).toJson())
        .toList();
    await _prefs.setString(AppConstants.prefsKeyConsoles, jsonEncode(list));
  }
}
