// Cliente HTTP centralizado com Dio. Todas as features usam esta instância.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _baseUrl = 'https://api.retrorelay.com';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Interceptor de log para desenvolvimento
  dio.interceptors.add(LogInterceptor(responseBody: true));

  return dio;
});
