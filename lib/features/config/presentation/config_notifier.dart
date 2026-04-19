// Gerencia o estado de AppSettings (IP do ESP32 e modo de operação).
//
// Leitura inicial é síncrona — SharedPreferences já está carregado em main().
// Escrita persiste via ConfigRepository antes de atualizar o estado local.
//
// Nota sobre modoUnico:
//   Ao salvar um novo modo, a UI deve também:
//   - Chamar relayApiServiceProvider.setModo() para sincronizar o ESP32
//   - Chamar canaisProvider.notifier.applyModoUnico() se mudou para true
//   Essa orquestração fica na tela (ConfigScreen), não aqui.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/relay_api_service.dart';
import '../../config/data/config_repository.dart';
import '../models/app_settings.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.read(configRepositoryProvider).loadSettings();
  }

  Future<void> save(AppSettings settings) async {
    await ref.read(configRepositoryProvider).saveSettings(settings);
    state = settings;
  }

  Future<void> updateIp(String novoIp) async {
    await save(state.copyWith(ip: novoIp));
  }

  Future<void> updateModoUnico(bool modoUnico) async {
    await save(state.copyWith(modoUnico: modoUnico));
    // Sincroniza o ESP32 com o novo modo
    final valor = modoUnico ? 'unico' : 'multi';
    ref.read(relayApiServiceProvider).setModo(state.ip, valor).ignore();
  }
}
