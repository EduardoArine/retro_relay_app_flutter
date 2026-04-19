// Widget raiz do app.
//
// Responsabilidades:
//   - Conectar tema (theme.dart) e navegação (routes.dart)
//   - Ser o ponto de montagem do MaterialApp
//
// Não contém lógica de negócio. Se no futuro precisar reagir a estado global
// (ex: tema dinâmico, locale), use ref.watch aqui.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes.dart';
import 'theme.dart';

class RetroRelayApp extends ConsumerWidget {
  const RetroRelayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Retro Relay',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
