// Monitora a conectividade com o ESP32 via polling periódico.
//
// Emite true se o dispositivo respondeu ao /ping com "pong", false caso contrário.
// Erros de rede são tratados internamente por RelayApiService — nunca chegam aqui.
//
// Por que StreamProvider e não StateNotifierProvider?
//   O polling é inerentemente um stream de eventos no tempo. StreamProvider
//   modela isso com mais clareza do que um notifier com Timer.
//
// Por que sem classe auxiliar?
//   A lógica é um único loop com duas responsabilidades (ping + delay).
//   Uma classe adicionaria indireção sem benefício real.
//
// Consumo:
//   ref.watch(conectadoProvider) retorna AsyncValue<bool>.
//   Use .valueOrNull ?? false para exibir o indicador no bottom nav.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/relay_api_service.dart';
import '../presentation/config_notifier.dart';

final conectadoProvider = StreamProvider<bool>((ref) async* {
  final apiService = ref.read(relayApiServiceProvider);

  // Assume desconectado até o primeiro ping confirmar.
  // Evita que a UI fique em AsyncValue.loading() enquanto aguarda o timeout.
  yield false;

  while (true) {
    // Relê o IP a cada iteração para capturar mudanças feitas em Config.
    final ip = ref.read(settingsProvider).ip;
    yield await apiService.testarConexao(ip);
    await Future.delayed(
      const Duration(seconds: AppConstants.connectivityPollSeconds),
    );
  }
});
