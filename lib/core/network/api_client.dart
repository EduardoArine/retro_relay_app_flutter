// Instância base do Dio compartilhada por todo o app.
//
// Por que sem base URL?
//   O IP do ESP32 é dinâmico: o usuário pode alterá-lo nas configurações ou
//   ele pode ser descoberto via mDNS. Por isso, cada chamada constrói a URL
//   completa (http://{ip}/endpoint) em vez de depender de uma base URL fixa.
//
// O que fica aqui:
//   - Timeouts globais
//   - Headers padrão
//   - Interceptors de log (desative em produção)
//
// O que NÃO fica aqui:
//   - Endpoints específicos (ficam em relay_api_service.dart)
//   - Lógica de retry ou autenticação (adicione como Interceptor separado quando necessário)

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout:
          Duration(seconds: AppConstants.connectionTimeoutSeconds),
      receiveTimeout:
          Duration(seconds: AppConstants.receiveTimeoutSeconds),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Em produção, remova ou condicionalize com kReleaseMode
  dio.interceptors.add(LogInterceptor(
    requestBody: false,
    responseBody: false,
    logPrint: (obj) => debugPrint('[Dio] $obj'),
  ));

  return dio;
});
