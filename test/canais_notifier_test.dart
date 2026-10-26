// Testes da leitura do estado real dos relés (GET /estado) no CanaisNotifier.
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retro_relay_app_flutter/core/network/network_exception.dart';
import 'package:retro_relay_app_flutter/core/network/relay_api_service.dart';
import 'package:retro_relay_app_flutter/features/config/data/connectivity_provider.dart';
import 'package:retro_relay_app_flutter/features/config/data/prefs_service.dart';
import 'package:retro_relay_app_flutter/features/config/presentation/config_notifier.dart';
import 'package:retro_relay_app_flutter/features/home/presentation/home_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simula o ESP32. O toggle só termina quando o teste completar [toggleEmAndamento].
class FakeRelayApi extends RelayApiService {
  FakeRelayApi() : super(Dio());

  int estado = 0;
  bool modoUnico = true;
  NetworkException? erro;
  Completer<void>? toggleEmAndamento;

  @override
  Future<({int estado, bool modoUnico})> getEstado(String ip) async {
    if (erro != null) throw erro!;
    return (estado: estado, modoUnico: modoUnico);
  }

  @override
  Future<void> toggleCanal(String ip, int canal) {
    toggleEmAndamento = Completer<void>();
    return toggleEmAndamento!.future;
  }

  @override
  Future<List<Map<String, dynamic>>> getConsoles(String ip) async => [];

  @override
  Future<void> saveConsoles(String ip, List<Map<String, dynamic>> c) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeRelayApi api;
  late ProviderContainer container;

  List<int> ativos() => [
        for (final c in container.read(canaisProvider))
          if (c.ativo) c.index,
      ];

  setUp(() async {
    // O notifier atualiza o widget Android; nos testes o canal nativo não existe
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (_) async => true,
    );

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    api = FakeRelayApi();
    container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      relayApiServiceProvider.overrideWithValue(api),
      conectadoProvider.overrideWith((ref) => const Stream.empty()),
    ]);
    container.read(canaisProvider);
  });

  tearDown(() => container.dispose());

  test('aplica o bitmask do ESP32 nos canais', () async {
    api.estado = 0x0005; // canais 0 e 2

    await container.read(canaisProvider.notifier).sincronizarEstado();

    expect(ativos(), [0, 2]);
  });

  test('aplica o modo do ESP32 nas configurações locais', () async {
    api.modoUnico = false;

    await container.read(canaisProvider.notifier).sincronizarEstado();

    expect(container.read(settingsProvider).modoUnico, isFalse);
  });

  test('não desfaz o toggle otimista enquanto o ESP32 não responde', () async {
    final notifier = container.read(canaisProvider.notifier);

    notifier.toggleCanal(3);
    expect(ativos(), [3]);

    // ESP32 ainda não processou o toggle: a leitura traria tudo desligado
    api.estado = 0;
    await notifier.sincronizarEstado();
    expect(ativos(), [3]);

    // Toggle concluído: a leitura seguinte vale
    api.estado = 1 << 3;
    api.toggleEmAndamento!.complete();
    await pumpEventQueue();
    expect(ativos(), [3]);

    api.estado = 1 << 5; // alguém ligou outro canal pela web
    await notifier.sincronizarEstado();
    expect(ativos(), [5]);
  });

  test('firmware sem /estado (404): mantém o estado local', () async {
    final notifier = container.read(canaisProvider.notifier);
    api.erro = const NetworkException(message: 'Not found', statusCode: 404);

    notifier.toggleCanal(1);
    api.toggleEmAndamento!.complete();
    await pumpEventQueue();
    await notifier.sincronizarEstado();

    expect(ativos(), [1]);
  });
}
