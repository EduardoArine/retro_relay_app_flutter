// Constantes globais do app.
//
// Responsabilidades:
//   - Centralizar strings, números e configurações que aparecem em múltiplos arquivos
//   - Ser a única fonte de verdade para valores como IP padrão, endpoints e chaves de prefs
//
// Regras:
//   - Apenas constantes puras aqui (sem lógica, sem instâncias)
//   - Use abstract final class para impedir instanciação acidental

abstract final class AppConstants {
  // ─── Rede ────────────────────────────────────────────────────────────────
  /// IP padrão do ESP32 em modo AP (Access Point). Usado antes de o usuário configurar.
  static const String defaultIp = '192.168.4.1';
  static const int connectionTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 10;

  /// Intervalo do polling de conectividade (em segundos).
  static const int connectivityPollSeconds = 15;

  // ─── Endpoints ───────────────────────────────────────────────────────────
  static const String endpointPing = '/ping';
  static const String endpointToggle = '/ligar';
  static const String endpointMode = '/modo';

  // ─── SharedPreferences keys ──────────────────────────────────────────────
  static const String prefsKeyIp = 'ip_relay';
  static const String prefsKeyModoUnico = 'modo_unico';
  static const String prefsKeyConsoles = 'consoles_config';

  // ─── Canais ──────────────────────────────────────────────────────────────
  static const int totalCanais = 16;

  /// Nomes padrão dos 16 canais. Índices 8–15 ficam sem nome (string vazia).
  static const List<String> defaultCanalNames = [
    'Super Nintendo',
    'Mega Drive',
    'PlayStation',
    'Nintendo 64',
    'Saturn',
    'Dreamcast',
    'GameCube',
    'Atari 2600',
    '', '', '', '', '', '', '', '',
  ];

  // ─── CDN de imagens ──────────────────────────────────────────────────────
  static const String cdnBaseUrl =
      'https://raw.githubusercontent.com/EduardoArine/retro-relay-images/refs/heads/main/';

  static const List<String> cdnImageNames = [
    // Atari
    'atari_2600.png',
    // Nintendo
    'nes.png',
    'snes.png',
    'n64.png',
    'game_cube.png',
    'nintendo_wii.png',
    'nintendo_switch.png',
    // Sega
    'master_system.png',
    'mega_drive.png',
    'sega_saturn.png',
    'sega_dreamcast.png',
    // Sony PlayStation
    'ps1.png',
    'ps2.png',
    'ps3.png',
    'ps4.png',
    'ps5.png',
    // Microsoft Xbox
    'xbox.png',
    'xbox_360.png',
    'xbox_one.png',
    'xbox_series_s.png',
    'xbox_series_x.png',
    // SNK Neo Geo
    'neogeo.png',
    'neogeo_cd.png',
    // PC Engine / TurboGrafx
    'pc_engine.png',
    'turbo_grafx.png',
    // 3DO
    '3do.png',
  ];

  static String cdnImageUrl(String fileName) => '$cdnBaseUrl$fileName';
}
