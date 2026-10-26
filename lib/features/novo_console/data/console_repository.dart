// Repository de consoles cadastrados.
//
// Responsabilidades:
//   - Ser a interface entre providers/notifiers e as fontes de dados
//   - Sincronizar o cadastro local (ConsoleStorageService) com o ESP32
//     (RelayApiService → /consoles), que é compartilhado com a interface web
//
// Regras de sincronização:
//   - O ESP32 é a fonte da verdade quando está acessível
//   - O celular guarda uma cópia local para funcionar sem conexão
//   - Salvar/remover sem conexão grava localmente e marca como pendente;
//     a próxima sincronização envia o cadastro do celular
//   - Primeira sincronização com o ESP32 vazio envia o cadastro do celular
//     (migração de quem cadastrou antes de existir o /consoles)
//
// O que NÃO fica aqui:
//   - Acesso direto ao SharedPreferences ou ao Dio
//   - Quando sincronizar (fica no ConsolesNotifier)
//   - Lógica de toggle ou modo único (fica no CanaisNotifier)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_exception.dart';
import '../../../core/network/relay_api_service.dart';
import '../models/console_config.dart';
import 'console_storage_service.dart';

final consoleRepositoryProvider = Provider<ConsoleRepository>((ref) {
  return ConsoleRepository(
    ref.read(consoleStorageServiceProvider),
    ref.read(relayApiServiceProvider),
  );
});

class ConsoleRepository {
  final ConsoleStorageService _storage;
  final RelayApiService _api;

  const ConsoleRepository(this._storage, this._api);

  /// Retorna todos os consoles cadastrados localmente, indexados por canal.
  Map<int, ConsoleConfig> getAll() => _storage.loadAll();

  /// Salva ou atualiza o console de um canal. Retorna o cadastro resultante.
  /// [online] = false pula a tentativa de envio (evita esperar o timeout).
  Future<Map<int, ConsoleConfig>> save(
    String ip,
    int canal,
    ConsoleConfig config, {
    required bool online,
  }) =>
      _salvar(ip, {..._storage.loadAll(), canal: config}, online: online);

  /// Remove o console de um canal. Retorna o cadastro resultante.
  /// [online] = false pula a tentativa de envio (evita esperar o timeout).
  Future<Map<int, ConsoleConfig>> remove(
    String ip,
    int canal, {
    required bool online,
  }) =>
      _salvar(ip, Map.of(_storage.loadAll())..remove(canal), online: online);

  /// Sincroniza com o ESP32 e retorna o cadastro resultante.
  /// Lança [NetworkException] se o ESP32 não responder.
  Future<Map<int, ConsoleConfig>> sincronizar(String ip) async {
    final local = _storage.loadAll();

    if (_storage.pendente) {
      await _enviar(ip, local);
      return local;
    }

    final remoto = ConsoleStorageService.fromJsonList(
      await _api.getConsoles(ip),
    );

    if (!_storage.migrado && remoto.isEmpty && local.isNotEmpty) {
      await _enviar(ip, local);
      return local;
    }

    await _storage.setMigrado();
    await _storage.saveAll(remoto);
    return remoto;
  }

  // Envia ao ESP32 e grava localmente. Se o ESP32 recusar os dados (HTTP 400),
  // propaga a exceção sem gravar nada. Qualquer outra falha — sem conexão ou
  // firmware anterior ao /consoles (404) — grava localmente e marca como
  // pendente, para enviar na próxima sincronização.
  Future<Map<int, ConsoleConfig>> _salvar(
    String ip,
    Map<int, ConsoleConfig> consoles, {
    required bool online,
  }) async {
    if (online) {
      try {
        await _enviar(ip, consoles);
      } on NetworkException catch (e) {
        if (e.statusCode == 400) rethrow;
        await _storage.setPendente(true);
      }
    } else {
      await _storage.setPendente(true);
    }
    await _storage.saveAll(consoles);
    return consoles;
  }

  Future<void> _enviar(String ip, Map<int, ConsoleConfig> consoles) async {
    await _api.saveConsoles(ip, ConsoleStorageService.toJsonList(consoles));
    await _storage.setPendente(false);
    await _storage.setMigrado();
  }
}
