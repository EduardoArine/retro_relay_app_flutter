// Wrapper de erros de rede.
//
// Responsabilidades:
//   - Converter DioException (detalhe de implementação) em NetworkException (contrato público)
//   - Garantir que nenhum arquivo fora de core/network precise importar 'package:dio'
//     apenas para tratar erros
//
// Uso:
//   try {
//     await relayApiService.toggleCanal(ip, canal);
//   } on NetworkException catch (e) {
//     // e.message e e.statusCode disponíveis
//   }

import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({required this.message, this.statusCode});

  factory NetworkException.fromDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout =>
        const NetworkException(message: 'Tempo de conexão esgotado'),
      DioExceptionType.connectionError =>
        const NetworkException(message: 'Sem conexão com o dispositivo'),
      DioExceptionType.badResponse => NetworkException(
          message: 'Resposta inválida do servidor',
          statusCode: e.response?.statusCode,
        ),
      _ => const NetworkException(message: 'Erro de rede desconhecido'),
    };
  }

  @override
  String toString() =>
      'NetworkException: $message'
      '${statusCode != null ? " (HTTP $statusCode)" : ""}';
}
