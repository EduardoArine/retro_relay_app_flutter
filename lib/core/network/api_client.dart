// Instância Dio compartilhada. Sem base URL — IP do ESP32 é dinâmico.
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: AppConstants.connectionTimeoutSeconds),
      receiveTimeout: Duration(seconds: AppConstants.receiveTimeoutSeconds),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => debugPrint('[Dio] $obj'),
    ));
  }

  return dio;
});
