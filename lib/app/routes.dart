// Mapeamento de rotas do app.
//
// Usa onGenerateRoute (em vez de routes fixas) para suportar rotas com
// argumentos tipados — ex: NovoConsoleScreen recebe um int via settings.arguments.
//
// Convenção:
//   - Constantes de nome ficam aqui (AppRoutes.home, AppRoutes.novoConsole)
//   - A UI usa Navigator.pushNamed(context, AppRoutes.novoConsole, arguments: index)
//   - Nunca use strings literais de rota fora deste arquivo

import 'package:flutter/material.dart';

import '../features/home/presentation/home_screen.dart';
import '../features/cadastro/presentation/cadastro_screen.dart';
import '../features/novo_console/presentation/novo_console_screen.dart';
import '../features/config/presentation/config_screen.dart';
import '../features/voice_control/presentation/voice_control_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String cadastro = '/cadastro';
  static const String novoConsole = '/novo-console'; // arguments: int (índice do canal)
  static const String config = '/config';
  static const String voiceControl = '/voice-control';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case cadastro:
        return MaterialPageRoute(builder: (_) => const CadastroScreen());

      case novoConsole:
        final index = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => NovoConsoleScreen(canalIndex: index),
        );

      case config:
        return MaterialPageRoute(builder: (_) => const ConfigScreen());

      case voiceControl:
        return MaterialPageRoute(builder: (_) => const VoiceControlScreen());

      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
