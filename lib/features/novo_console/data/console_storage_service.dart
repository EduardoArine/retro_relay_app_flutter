// Persistência dos consoles cadastrados no SharedPreferences.
//
// Responsabilidades:
//   - Serializar Map<int, ConsoleConfig> como lista JSON em uma única chave
//   - Deserializar de volta ao carregar
//   - Operações: loadAll, saveAll
//   - Flags de sincronização com o ESP32 (pendente / migrado)
//
// Formato no SharedPreferences (chave: AppConstants.prefsKeyConsoles):
//   JSON string de List<PersistedConsole.toJson()>
//   Exemplo: [{"canal":0,"nome":"Super Nintendo","imagem":"https://..."}]
//   É o mesmo formato do endpoint /consoles do ESP32 (ver toJsonList/fromJsonList).
//
// O que NÃO fica aqui:
//   - Validação de dados
//   - Regras de sincronização (ficam em ConsoleRepository)
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
      return fromJsonList(jsonDecode(raw) as List<dynamic>);
    } catch (_) {
      return {};
    }
  }

  /// Substitui o cadastro inteiro.
  Future<void> saveAll(Map<int, ConsoleConfig> consoles) async {
    await _prefs.setString(
      AppConstants.prefsKeyConsoles,
      jsonEncode(toJsonList(consoles)),
    );
  }

  /// true = há alterações locais que ainda não chegaram ao ESP32.
  bool get pendente =>
      _prefs.getBool(AppConstants.prefsKeyConsolesPendente) ?? false;

  Future<void> setPendente(bool valor) =>
      _prefs.setBool(AppConstants.prefsKeyConsolesPendente, valor);

  /// true = já houve a primeira sincronização com o ESP32.
  bool get migrado =>
      _prefs.getBool(AppConstants.prefsKeyConsolesMigrado) ?? false;

  Future<void> setMigrado() =>
      _prefs.setBool(AppConstants.prefsKeyConsolesMigrado, true);

  static List<Map<String, dynamic>> toJsonList(
    Map<int, ConsoleConfig> consoles,
  ) {
    final canais = consoles.keys.toList()..sort();
    return [
      for (final canal in canais)
        PersistedConsole.fromConsoleConfig(canal, consoles[canal]!).toJson(),
    ];
  }

  static Map<int, ConsoleConfig> fromJsonList(List<dynamic> list) {
    return {
      for (final item in list)
        (item as Map<String, dynamic>)['canal'] as int:
            PersistedConsole.fromJson(item).toConsoleConfig(),
    };
  }
}
