// Camada entre a UI e o AuthService. Centraliza regras de negócio de auth.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<AuthModel> login(String email, String password) async {
    // Aqui podem entrar validações, cache de token, etc.
    return _service.login(email, password);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(authServiceProvider));
});

// Provider de estado do login (AsyncValue para tratar loading/error/data)
final loginProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<AuthModel?>>((ref) {
  return LoginNotifier(ref.read(authRepositoryProvider));
});

class LoginNotifier extends StateNotifier<AsyncValue<AuthModel?>> {
  final AuthRepository _repo;

  LoginNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.login(email, password));
  }
}
