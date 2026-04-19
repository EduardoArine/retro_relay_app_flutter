// Configurações persistidas do app.
//
// Carregadas no boot via PrefsService/ConfigRepository e expostas pelo
// SettingsNotifier (a ser criado na Fase 3). A UI reage a mudanças
// via ref.watch(settingsProvider).
//
// Imutável por design: use copyWith ao salvar novas configurações.

import '../../../core/constants/app_constants.dart';

class AppSettings {
  /// Endereço IP do ESP32 na rede local.
  final String ip;

  /// true  = apenas um canal ativo por vez (modo exclusivo)
  /// false = múltiplos canais simultâneos
  final bool modoUnico;

  const AppSettings({
    required this.ip,
    required this.modoUnico,
  });

  /// Valores padrão usados na primeira execução ou se prefs estiver corrompido.
  const AppSettings.defaults()
      : ip = AppConstants.defaultIp,
        modoUnico = true;

  AppSettings copyWith({String? ip, bool? modoUnico}) {
    return AppSettings(
      ip: ip ?? this.ip,
      modoUnico: modoUnico ?? this.modoUnico,
    );
  }

  @override
  String toString() => 'AppSettings(ip: $ip, modoUnico: $modoUnico)';

  @override
  bool operator ==(Object other) =>
      other is AppSettings && other.ip == ip && other.modoUnico == modoUnico;

  @override
  int get hashCode => Object.hash(ip, modoUnico);
}
