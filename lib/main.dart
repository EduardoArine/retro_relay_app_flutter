// Ponto de entrada do app.
//
// Responsabilidades:
//   - Inicializar SharedPreferences de forma assíncrona ANTES do primeiro frame
//   - Injetar a instância real via ProviderScope.overrides
//   - Delegar todo o resto para RetroRelayApp
//
// Por que inicializar aqui?
//   SharedPreferences.getInstance() é async. O Riverpod não suporta providers
//   verdadeiramente assíncronos na raiz. A solução padrão é: inicializar no main(),
//   passar a instância pronta via override, e declarar o provider com UnimplementedError
//   como guard de segurança.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/config/data/prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const RetroRelayApp(),
    ),
  );
}
