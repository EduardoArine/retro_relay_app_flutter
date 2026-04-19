// Define as rotas nomeadas do app.
import 'package:flutter/material.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/home/presentation/home_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginPage(),
        home: (_) => const HomePage(),
      };
}
