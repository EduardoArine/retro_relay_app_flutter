// Chamadas HTTP ao ESP32. Stateless em relação ao IP — recebe por parâmetro.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import 'api_client.dart';
import 'network_exception.dart';

class RelayApiService {
  final Dio _dio;

  const RelayApiService(this._dio);

  // Liga ou desliga o canal. A UI atualiza o estado local antes de chamar — fire-and-forget.
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

  // Retorna false sem lançar exceção — ausência de conexão é estado esperado.
  Future<bool> testarConexao(String ip) async {
    try {
      final response = await _dio.get('http://$ip${AppConstants.endpointPing}');
      final body = response.data?.toString() ?? '';
      return response.statusCode == 200 && body.toLowerCase().contains('pong');
    } on DioException {
      return false;
    }
  }
}

final relayApiServiceProvider = Provider<RelayApiService>((ref) {
  return RelayApiService(ref.read(dioProvider));
});
