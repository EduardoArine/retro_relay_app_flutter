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

  // Estado real dos relés: bit N de [estado] = canal N ligado.
  // Firmware anterior ao /estado responde 404 (NetworkException com statusCode).
  Future<({int estado, bool modoUnico})> getEstado(String ip) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'http://$ip${AppConstants.endpointEstado}',
      );
      final data = response.data;
      final estado = data?['estado'];
      if (estado is! int) {
        throw const NetworkException(message: 'Resposta inválida do servidor');
      }
      return (estado: estado, modoUnico: data!['modo'] != 'multi');
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  // Cadastro de consoles salvo no ESP32, compartilhado com a interface web.
  // Formato: [{"canal": 0, "nome": "...", "imagem": "..."}]
  Future<List<Map<String, dynamic>>> getConsoles(String ip) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        'http://$ip${AppConstants.endpointConsoles}',
      );
      return (response.data ?? []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    }
  }

  // Substitui o cadastro inteiro no ESP32. O firmware valida e responde 400 se inválido.
  Future<void> saveConsoles(
    String ip,
    List<Map<String, dynamic>> consoles,
  ) async {
    try {
      await _dio.post(
        'http://$ip${AppConstants.endpointConsoles}',
        data: consoles,
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
