// Responsável pelas chamadas HTTP relacionadas a autenticação.
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/auth_model.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<AuthModel> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthModel.fromJson(response.data as Map<String, dynamic>);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiClientProvider));
});
