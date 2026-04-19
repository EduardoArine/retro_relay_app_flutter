// Widget raiz. Conecta tema e roteamento. Sem lógica de negócio.
import 'package:flutter/material.dart';

import 'routes.dart';
import 'theme.dart';

class RetroRelayApp extends StatelessWidget {
  const RetroRelayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retro Relay',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
