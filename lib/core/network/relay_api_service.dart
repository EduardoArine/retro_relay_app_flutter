// Service HTTP do ESP32 (Retro Relay).
//
// Responsabilidades:
//   - Encapsular as 3 chamadas à API do ESP32: toggle, modo e ping
//   - Construir URLs dinâmicas com o IP recebido como parâmetro
//   - Converter DioException em NetworkException antes de propagar
//
// Por que o IP é parâmetro e não estado interno?
//   O IP pode mudar em runtime (usuário edita em Config, ou mDNS descobre novo IP).
//   Manter o service stateless evita recriá-lo ou ter race conditions. O provider
//   do notifier lê o IP de settingsProvider e passa na chamada.
//
// O que NÃO fica aqui:
//   - Regras de negócio (ex: modo único → desativar outros canais)
//   - Estado de conectividade
//   - Retry logic

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import 'api_client.dart';
import 'network_exception.dart';

class RelayApiService {
  final Dio _dio;

  const RelayApiService(this._dio);

  // Liga ou desliga o canal no ESP32.
  // Fire-and-forget: a UI não aguarda confirmação — estado local é atualizado otimisticamente.
  Future<void> toggleCanal(String ip, int canal) async {
    try {
      await _dio.get(
        'http://$ip${AppConstants.endpointToggle}',
        queryParameters: {'canal': canal},
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  // Define o modo de operação no ESP32.
  // [valor] deve ser 'unico' ou 'multi'.
  Future<void> setModo(String ip, String valor) async {
    try {
      await _dio.get(
        'http://$ip${AppConstants.endpointMode}',
        queryParameters: {'valor': valor},
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  // Testa conectividade com o ESP32.
  // Retorna false (sem lançar exceção) se não houver conexão — ausência de conexão
  // é um estado esperado no app, não um erro excepcional.
  Future<bool> testarConexao(String ip) async {
    try {
      final response = await _dio.get('http://$ip${AppConstants.endpointPing}');
      return response.statusCode == 200 &&
          (response.data as String).toLowerCase().contains('pong');
    } on DioException {
      return false;
    }
  }
}

final relayApiServiceProvider = Provider<RelayApiService>((ref) {
  return RelayApiService(ref.read(dioProvider));
});
