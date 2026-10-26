// Testes das regras de sincronização do cadastro de consoles com o ESP32.
// Ver tabela em lib/features/novo_console/README.md.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retro_relay_app_flutter/core/constants/app_constants.dart';
import 'package:retro_relay_app_flutter/core/network/network_exception.dart';
import 'package:retro_relay_app_flutter/core/network/relay_api_service.dart';
import 'package:retro_relay_app_flutter/features/novo_console/data/console_repository.dart';
import 'package:retro_relay_app_flutter/features/novo_console/data/console_storage_service.dart';
import 'package:retro_relay_app_flutter/features/novo_console/models/console_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

const ip = '192.168.0.105';
const snes = ConsoleConfig(nome: 'Super Nintendo', imagem: 'https://cdn/snes.png');
const ps1 = ConsoleConfig(nome: 'PlayStation', imagem: 'https://cdn/ps1.png');

/// Simula o ESP32: guarda o cadastro em memória e pode falhar sob demanda.
class FakeRelayApi extends RelayApiService {
  FakeRelayApi() : super(Dio());

  List<Map<String, dynamic>> remoto = [];
  NetworkException? erro;
  int envios = 0;

  @override
  Future<List<Map<String, dynamic>>> getConsoles(String ip) async {
    if (erro != null) throw erro!;
    return remoto;
  }

  @override
  Future<void> saveConsoles(
    String ip,
    List<Map<String, dynamic>> consoles,
  ) async {
    if (erro != null) throw erro!;
    envios++;
    remoto = consoles;
  }
}

const semConexao = NetworkException(message: 'Sem conexão com o dispositivo');
const firmwareAntigo = NetworkException(message: 'Not found', statusCode: 404);
const recusado = NetworkException(message: 'Inválido', statusCode: 400);

void main() {
  late FakeRelayApi api;
  late ConsoleStorageService storage;
  late ConsoleRepository repo;

  Future<void> iniciar([Map<String, Object> prefs = const {}]) async {
    SharedPreferences.setMockInitialValues(prefs);
    storage = ConsoleStorageService(await SharedPreferences.getInstance());
    api = FakeRelayApi();
    repo = ConsoleRepository(storage, api);
  }

  Future<void> cadastroLocal(Map<int, ConsoleConfig> consoles) async {
    await storage.saveAll(consoles);
  }

  group('save/remove', () {
    setUp(iniciar);

    test('online: envia ao ESP32 e grava localmente', () async {
      final resultado = await repo.save(ip, 0, snes, online: true);

      expect(resultado, {0: snes});
      expect(storage.loadAll(), {0: snes});
      expect(ConsoleStorageService.fromJsonList(api.remoto), {0: snes});
      expect(storage.pendente, isFalse);
      expect(storage.migrado, isTrue);
    });

    test('offline: não tenta enviar, grava localmente e marca pendente',
        () async {
      await repo.save(ip, 0, snes, online: false);

      expect(api.envios, 0);
      expect(storage.loadAll(), {0: snes});
      expect(storage.pendente, isTrue);
    });

    test('falha de conexão: grava localmente e marca pendente', () async {
      api.erro = semConexao;

      await repo.save(ip, 0, snes, online: true);

      expect(storage.loadAll(), {0: snes});
      expect(storage.pendente, isTrue);
    });

    test('firmware sem /consoles (404): grava localmente e marca pendente',
        () async {
      api.erro = firmwareAntigo;

      await repo.save(ip, 0, snes, online: true);

      expect(storage.loadAll(), {0: snes});
      expect(storage.pendente, isTrue);
    });

    test('ESP32 recusa (400): lança e não grava nada', () async {
      api.erro = recusado;

      await expectLater(
        repo.save(ip, 0, snes, online: true),
        throwsA(isA<NetworkException>()),
      );
      expect(storage.loadAll(), isEmpty);
      expect(storage.pendente, isFalse);
    });

    test('remove: envia o cadastro sem o canal', () async {
      await repo.save(ip, 0, snes, online: true);
      await repo.save(ip, 2, ps1, online: true);

      final resultado = await repo.remove(ip, 0, online: true);

      expect(resultado, {2: ps1});
      expect(ConsoleStorageService.fromJsonList(api.remoto), {2: ps1});
    });
  });

  group('sincronizar', () {
    test('com pendência: envia o cadastro do celular', () async {
      await iniciar({AppConstants.prefsKeyConsolesPendente: true});
      await cadastroLocal({0: snes});
      api.remoto = ConsoleStorageService.toJsonList({2: ps1});

      final resultado = await repo.sincronizar(ip);

      expect(resultado, {0: snes});
      expect(ConsoleStorageService.fromJsonList(api.remoto), {0: snes});
      expect(storage.pendente, isFalse);
    });

    test('primeira vez, ESP32 vazio e celular com consoles: migra o celular',
        () async {
      await iniciar();
      await cadastroLocal({0: snes, 2: ps1});

      final resultado = await repo.sincronizar(ip);

      expect(resultado, {0: snes, 2: ps1});
      expect(ConsoleStorageService.fromJsonList(api.remoto), {0: snes, 2: ps1});
      expect(storage.migrado, isTrue);
    });

    test('primeira vez, ESP32 com cadastro: o ESP32 substitui o celular',
        () async {
      await iniciar();
      await cadastroLocal({0: snes});
      api.remoto = ConsoleStorageService.toJsonList({2: ps1});

      final resultado = await repo.sincronizar(ip);

      expect(resultado, {2: ps1});
      expect(storage.loadAll(), {2: ps1});
      expect(api.envios, 0);
    });

    test('depois da migração, ESP32 vazio limpa o celular', () async {
      await iniciar({AppConstants.prefsKeyConsolesMigrado: true});
      await cadastroLocal({0: snes});

      final resultado = await repo.sincronizar(ip);

      expect(resultado, isEmpty);
      expect(storage.loadAll(), isEmpty);
      expect(api.envios, 0);
    });

    test('sem conexão: lança e mantém o cadastro local', () async {
      await iniciar();
      await cadastroLocal({0: snes});
      api.erro = semConexao;

      await expectLater(
        repo.sincronizar(ip),
        throwsA(isA<NetworkException>()),
      );
      expect(storage.loadAll(), {0: snes});
    });

    test('pendência com firmware antigo: continua pendente', () async {
      await iniciar({AppConstants.prefsKeyConsolesPendente: true});
      await cadastroLocal({0: snes});
      api.erro = firmwareAntigo;

      await expectLater(
        repo.sincronizar(ip),
        throwsA(isA<NetworkException>()),
      );
      expect(storage.pendente, isTrue);
      expect(storage.loadAll(), {0: snes});
    });
  });
}
