// Repository de configurações do app.
//
// Responsabilidades:
//   - Ser a interface entre providers/notifiers e o PrefsService
//   - Ponto de extensão para futuras regras (ex: validar IP, migrar formato)
//
// Por que existe se PrefsService já é simples?
//   Segue o contrato da arquitetura: providers não chamam services diretamente.
//   Se futuramente houver validação de IP ou múltiplas fontes (prefs + remoto),
//   apenas este arquivo muda — sem impactar os notifiers.
//
// O que NÃO fica aqui:
//   - Estado reativo (fica no SettingsNotifier)
//   - Acesso a SharedPreferences (fica no PrefsService)
//   - Descoberta mDNS (ficará em MdnsService, fase futura)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import 'prefs_service.dart';

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepository(ref.read(prefsServiceProvider));
});

class ConfigRepository {
  final PrefsService _prefs;

  const ConfigRepository(this._prefs);

  /// Carrega configurações salvas. Nunca lança exceção — retorna defaults em caso de falha.
  AppSettings loadSettings() => _prefs.load();

  /// Persiste as configurações. Propaga erros de I/O para o notifier tratar.
  Future<void> saveSettings(AppSettings settings) => _prefs.save(settings);
}
