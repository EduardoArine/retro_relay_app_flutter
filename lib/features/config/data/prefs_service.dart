// Acesso de baixo nível ao SharedPreferences para configurações do app.
//
// Responsabilidades:
//   - Ler e escrever IP e modoUnico diretamente no SharedPreferences
//   - Ser o único arquivo que conhece as chaves de prefs (via AppConstants)
//
// O que NÃO fica aqui:
//   - Regras de negócio (ex: validar IP)
//   - Lógica de fallback (fica no ConfigRepository)
//   - Estado reativo (fica no SettingsNotifier)
//
// Padrão de inicialização:
//   sharedPreferencesProvider é declarado aqui com UnimplementedError como guard.
//   O main.dart o sobrescreve com a instância real via ProviderScope.overrides.
//   Isso permite que qualquer provider que precise de SharedPreferences
//   use ref.read(sharedPreferencesProvider) sem importar main.dart.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../models/app_settings.dart';

/// Provider global da instância SharedPreferences.
/// Deve ser sobrescrito em main.dart via ProviderScope.overrides.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider não foi inicializado. '
    'Adicione o override em ProviderScope no main.dart.',
  );
});

final prefsServiceProvider = Provider<PrefsService>((ref) {
  return PrefsService(ref.read(sharedPreferencesProvider));
});

class PrefsService {
  final SharedPreferences _prefs;

  const PrefsService(this._prefs);

  /// Lê as configurações salvas. Retorna defaults se não houver dados.
  AppSettings load() {
    return AppSettings(
      ip: _prefs.getString(AppConstants.prefsKeyIp) ?? AppConstants.defaultIp,
      modoUnico: _prefs.getBool(AppConstants.prefsKeyModoUnico) ?? true,
    );
  }

  /// Persiste as configurações. Operação assíncrona — aguarde antes de continuar.
  Future<void> save(AppSettings settings) async {
    await Future.wait([
      _prefs.setString(AppConstants.prefsKeyIp, settings.ip),
      _prefs.setBool(AppConstants.prefsKeyModoUnico, settings.modoUnico),
    ]);
  }
}
