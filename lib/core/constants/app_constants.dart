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

  /// Pings seguidos sem resposta antes de procurar o ESP32 via mDNS (IP pode ter mudado).
  static const int falhasAntesDeRedescobrir = 2;

  /// Intervalo mínimo entre buscas mDNS automáticas (em segundos).
  static const int redescobertaIntervaloSeconds = 60;

  /// Intervalo da leitura do estado dos relés com o app aberto (mesmo da interface web).
  static const int estadoPollSeconds = 5;

  /// Nome anunciado pelo firmware via mDNS (MDNS.begin("retrorelay") → retrorelay.local).
  static const String mdnsName = 'retrorelay';

  // ─── Endpoints ───────────────────────────────────────────────────────────
  static const String endpointPing = '/ping';
  static const String endpointToggle = '/ligar';
  static const String endpointMode = '/modo';

  /// Estado real dos relés: {"estado": bitmask, "modo": "unico"|"multi", "versao": "..."}
  static const String endpointEstado = '/estado';

  /// Cadastro de consoles salvo no ESP32 (GET lê, POST grava a lista inteira).
  static const String endpointConsoles = '/consoles';

  // ─── SharedPreferences keys ──────────────────────────────────────────────
  static const String prefsKeyIp = 'ip_relay';
  static const String prefsKeyModoUnico = 'modo_unico';
  static const String prefsKeyConsoles = 'consoles_config';

  /// true = cadastro alterado sem conexão, precisa ser enviado ao ESP32.
  static const String prefsKeyConsolesPendente = 'consoles_pendente';

  /// true = já houve a primeira sincronização com o ESP32.
  static const String prefsKeyConsolesMigrado = 'consoles_migrado';

  // ─── Consoles ────────────────────────────────────────────────────────────
  /// Limite do nome do console (o firmware aceita até 96 bytes UTF-8).
  static const int nomeConsoleMaxLength = 32;

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

  /// Imagens da escolha de imagem: (arquivo no CDN sem .png, nome sugerido).
  /// Mesma lista e ordem da página do aparelho (web/index.html no firmware).
  static const List<(String, String)> imagensConsoles = [
    ('atari_2600', 'Atari 2600'), ('atari_7800', 'Atari 7800'), ('atari_jaguar', 'Jaguar'),
    ('odyssey_2', 'Odyssey²'), ('intellivision', 'Intellivision'), ('colecovision', 'ColecoVision'),
    ('nes', 'NES'), ('famicom', 'Famicom'), ('phantom_system', 'Phantom System'),
    ('snes', 'Super Nintendo'), ('super_famicom', 'Super Famicom'), ('n64', 'Nintendo 64'), ('game_cube', 'GameCube'),
    ('nintendo_wii', 'Wii'), ('nintendo_wii_u', 'Wii U'), ('nintendo_switch', 'Switch'), ('nintendo_switch_2', 'Switch 2'),
    ('master_system', 'Master System'), ('mega_drive', 'Mega Drive'), ('sega_cd', 'Sega CD'), ('sega_32x', '32X'),
    ('sega_saturn', 'Saturn'), ('sega_dreamcast', 'Dreamcast'),
    ('ps1', 'PlayStation'), ('ps2', 'PlayStation 2'), ('ps3', 'PlayStation 3'), ('ps4', 'PlayStation 4'), ('ps5', 'PlayStation 5'),
    ('xbox', 'Xbox'), ('xbox_360', 'Xbox 360'), ('xbox_one', 'Xbox One'), ('xbox_series_s', 'Xbox Series S'), ('xbox_series_x', 'Xbox Series X'),
    ('neogeo', 'Neo Geo'), ('neogeo_cd', 'Neo Geo CD'),
    ('pc_engine', 'PC Engine'), ('turbo_grafx', 'TurboGrafx-16'),
    ('3do', '3DO'), ('cdi', 'CD-i'),
    ('msx', 'MSX'), ('mister', 'MiSTer'), ('raspberry_pi', 'Raspberry Pi'),
  ];

  /// O que mais costuma ficar ligado junto: telas, vídeo, áudio, jogos e ambiente.
  static const List<(String, String)> imagensAcessorios = [
    ('tv_crt', 'TV de tubo'), ('tv_moderna', 'TV'), ('monitor_pvm', 'Monitor PVM'),
    ('upscaler', 'Upscaler'), ('chaveador_hdmi', 'Chaveador HDMI'), ('chaveador_av', 'Chaveador AV'),
    ('receiver', 'Receiver'), ('soundbar', 'Soundbar'), ('caixas_som', 'Caixas de som'),
    ('fliperama', 'Fliperama'), ('bartop', 'Bartop'), ('pc_gamer', 'PC gamer'), ('carregador_controles', 'Carregador de controles'),
    ('fita_led', 'Fita LED'), ('neon', 'Neon'), ('ventilador', 'Ventilador'),
  ];

  static String cdnImageUrl(String arquivo) => '$cdnBaseUrl$arquivo.png';
}
