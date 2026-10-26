// Testes da redescoberta automática do ESP32 quando o IP salvo para de responder.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retro_relay_app_flutter/core/network/mdns_service.dart';
import 'package:retro_relay_app_flutter/core/network/relay_api_service.dart';
import 'package:retro_relay_app_flutter/features/config/data/connectivity_provider.dart';

/// Rede simulada: só os IPs em [respondem] atendem o /ping.
class FakeRelayApi extends RelayApiService {
  FakeRelayApi() : super(Dio());

  Set<String> respondem = {};

  @override
  Future<bool> testarConexao(String ip) async => respondem.contains(ip);
}

class FakeMdns extends MdnsService {
  String? encontrado;
  int buscas = 0;

  @override
  Future<String?> discover({
    String serviceType = '_http._tcp',
    String hostname = 'retrorelay.local',
    Duration timeout = const Duration(seconds: 5),
  }) async {
    buscas++;
    return encontrado;
  }
}

void main() {
  late FakeRelayApi api;
  late FakeMdns mdns;
  late String ipSalvo;
  late DateTime relogio;
  late VerificadorConexao verificador;

  setUp(() {
    api = FakeRelayApi();
    mdns = FakeMdns();
    ipSalvo = '192.168.0.105';
    relogio = DateTime(2026, 10, 26, 12);
    verificador = VerificadorConexao(
      api: api,
      mdns: mdns,
      lerIp: () => ipSalvo,
      salvarIp: (ip) async => ipSalvo = ip,
      agora: () => relogio,
    );
  });

  test('IP salvo responde: conectado, sem buscar na rede', () async {
    api.respondem = {'192.168.0.105'};

    expect(await verificador.verificar(), isTrue);
    expect(mdns.buscas, 0);
  });

  test('primeira falha não busca (pode ser instabilidade momentânea)', () async {
    expect(await verificador.verificar(), isFalse);
    expect(mdns.buscas, 0);
  });

  test('IP mudou no DHCP: encontra via mDNS e salva o novo IP', () async {
    api.respondem = {'192.168.0.112'};
    mdns.encontrado = '192.168.0.112';

    expect(await verificador.verificar(), isFalse);
    expect(await verificador.verificar(), isTrue);

    expect(ipSalvo, '192.168.0.112');
    expect(mdns.buscas, 1);
  });

  test('dispositivo desligado: busca no máximo uma vez por minuto', () async {
    await verificador.verificar();
    await verificador.verificar(); // 2ª falha: busca
    await verificador.verificar(); // dentro do intervalo: não busca
    expect(mdns.buscas, 1);

    relogio = relogio.add(const Duration(seconds: 61));
    await verificador.verificar();
    expect(mdns.buscas, 2);
    expect(ipSalvo, '192.168.0.105');
  });

  test('mDNS acha um IP que não responde ao ping: não salva', () async {
    mdns.encontrado = '192.168.0.200';

    await verificador.verificar();
    expect(await verificador.verificar(), isFalse);

    expect(ipSalvo, '192.168.0.105');
  });

  test('volta a responder no mesmo IP: zera a contagem de falhas', () async {
    await verificador.verificar(); // 1 falha
    api.respondem = {'192.168.0.105'};
    expect(await verificador.verificar(), isTrue);

    api.respondem = {};
    await verificador.verificar(); // 1ª falha de novo: ainda não busca
    expect(mdns.buscas, 0);
  });
}
