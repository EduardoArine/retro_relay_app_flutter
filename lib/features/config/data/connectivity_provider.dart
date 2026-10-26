// Monitora a conectividade com o ESP32 via polling periódico.
//
// Emite true se o dispositivo respondeu ao /ping com "pong", false caso contrário.
// Erros de rede são tratados internamente por RelayApiService — nunca chegam aqui.
//
// Redescoberta automática:
//   O IP do ESP32 pode mudar quando o roteador reinicia (DHCP). Se o IP salvo
//   parar de responder, VerificadorConexao procura o dispositivo via mDNS e,
//   se ele estiver em outro IP, salva o novo IP nas configurações.
//
// Por que StreamProvider e não StateNotifierProvider?
//   O polling é inerentemente um stream de eventos no tempo. StreamProvider
//   modela isso com mais clareza do que um notifier com Timer.
//
// Consumo:
//   ref.watch(conectadoProvider) retorna AsyncValue<bool>.
//   Use .valueOrNull ?? false para exibir o indicador no bottom nav.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/mdns_service.dart';
import '../../../core/network/relay_api_service.dart';
import '../presentation/config_notifier.dart';

final conectadoProvider = StreamProvider<bool>((ref) async* {
  final verificador = VerificadorConexao(
    api: ref.read(relayApiServiceProvider),
    mdns: ref.read(mdnsServiceProvider),
    // Relê o IP a cada verificação para capturar mudanças feitas em Config.
    lerIp: () => ref.read(settingsProvider).ip,
    salvarIp: (ip) => ref.read(settingsProvider.notifier).updateIp(ip),
  );

  // Assume desconectado até o primeiro ping confirmar.
  // Evita que a UI fique em AsyncValue.loading() enquanto aguarda o timeout.
  yield false;

  while (true) {
    yield await verificador.verificar();
    await Future.delayed(
      const Duration(seconds: AppConstants.connectivityPollSeconds),
    );
  }
});

/// Testa a conexão com o ESP32 e, quando o IP salvo para de responder,
/// procura o dispositivo via mDNS.
///
/// Só procura depois de [AppConstants.falhasAntesDeRedescobrir] falhas seguidas
/// e no máximo uma vez a cada [AppConstants.redescobertaIntervaloSeconds]:
/// com o dispositivo desligado, não fica varrendo a rede a cada ping.
class VerificadorConexao {
  final RelayApiService api;
  final MdnsService mdns;
  final String Function() lerIp;
  final Future<void> Function(String ip) salvarIp;
  final DateTime Function() agora;

  int _falhasSeguidas = 0;
  DateTime? _ultimaBusca;

  VerificadorConexao({
    required this.api,
    required this.mdns,
    required this.lerIp,
    required this.salvarIp,
    this.agora = DateTime.now,
  });

  Future<bool> verificar() async {
    final ip = lerIp();
    if (await api.testarConexao(ip)) {
      _falhasSeguidas = 0;
      return true;
    }

    _falhasSeguidas++;
    if (_falhasSeguidas < AppConstants.falhasAntesDeRedescobrir) return false;

    final momento = agora();
    final ultima = _ultimaBusca;
    if (ultima != null &&
        momento.difference(ultima) <
            const Duration(seconds: AppConstants.redescobertaIntervaloSeconds)) {
      return false;
    }
    _ultimaBusca = momento;

    final novoIp = await mdns.discover();
    if (novoIp == null || novoIp == ip) return false;
    if (!await api.testarConexao(novoIp)) return false;

    await salvarIp(novoIp);
    _falhasSeguidas = 0;
    return true;
  }
}
